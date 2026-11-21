import 'package:flutter/foundation.dart';
import 'package:my_samples/core/database/app_database.dart';
import 'package:my_samples/core/network/api_client.dart';
import 'package:my_samples/core/network/api_endpoints.dart';
import 'package:my_samples/core/network/api_exception.dart';
import 'package:my_samples/core/notifications/deadline_notification_engine.dart';
import 'package:my_samples/core/storage/local_storage_service.dart';
import 'package:my_samples/features/samples/data/models/notification_item.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';

/// Offline-First Sample & Notification Repository.
/// All CRUD operations are executed directly against the local on-device
/// SQLite database ('sample_flow.db') for instant 0ms offline capabilities.
///
/// Default Mode: 100% Offline (Standalone SQLite).
/// Remote sync is commented out and reserved for the next stage (Online Mode).
class SampleApi extends ChangeNotifier {
  static final SampleApi _instance = SampleApi._internal();
  factory SampleApi() => _instance;
  SampleApi._internal();

  // =========================================================================
  // [OFFLINE-FIRST DEPLOYMENT TOGGLE]
  // Default: false (100% Offline SQLite mode upon install).
  //
  // NEXT STAGE OF DEVELOPMENT (ONLINE MODE):
  // Set enableOnlineSync = true to enable background REST synchronization
  // with the remote cloud backend.
  // =========================================================================
  static const bool enableOnlineSync = false;

  final AppDatabase _db = AppDatabase();
  final LocalStorageService _storage = LocalStorageService();
  final ApiClient _client = ApiClient();
  final DeadlineNotificationEngine _deadlineEngine =
      DeadlineNotificationEngine();

  bool _isInitialized = false;
  bool _isOffline = true;

  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _storage.getLastSync();
  String get currentBaseUrl => _storage.getBackendUrl();

  Future<void> updateBackendUrl(String newUrl) async {
    await _storage.saveBackendUrl(newUrl);
    _client.updateBaseUrl(newUrl);
    if (enableOnlineSync) {
      await syncWithBackend();
    }
    notifyListeners();
  }

  // In-memory active stores (hydrated from local SQLite database)
  final List<SampleItem> _samples = [];
  final List<NotificationItem> _notifications = [];

  /// Initialize SQLite database and hydrate in-memory stores.
  /// Runs 100% offline without remote network dependencies.
  Future<void> init() async {
    if (_isInitialized) return;

    await _storage.init();

    // 1. Load Samples from local SQLite database
    final localSamples = await _db.getAllSamples();
    _samples.clear();
    _samples.addAll(localSamples);

    // 2. Load Notifications from local SQLite database
    final localNotifs = await _db.getAllNotifications();
    _notifications.clear();
    _notifications.addAll(localNotifs);

    // 3. Evaluate immediate milestone notifications for approved samples
    await _evaluateDeadlines();

    // 4. Pre-schedule future OS AlarmManager alarms for approved samples (offline background)
    for (final s in _samples.where((s) => s.status == SampleStatus.approved)) {
      _deadlineEngine.scheduleMilestoneAlarms(s);
    }

    _isInitialized = true;
    notifyListeners();

    // =======================================================================
    // NEXT STAGE OF DEVELOPMENT (ONLINE MODE):
    // Uncomment the background sync below when deploying the cloud backend:
    //
    // if (enableOnlineSync) {
    //   syncWithBackend();
    // }
    // =======================================================================
  }

  /// Internal helper to evaluate deadlines and reload notifications if newly triggered
  Future<void> _evaluateDeadlines({
    DateTime? now,
    bool dispatchSystemTray = true,
  }) async {
    try {
      final newlyTriggered = await _deadlineEngine.evaluateDeadlines(
        samples: _samples,
        now: now,
        dispatchSystemTray: dispatchSystemTray,
      );
      if (newlyTriggered.isNotEmpty) {
        final freshNotifs = await _db.getAllNotifications();
        _notifications.clear();
        _notifications.addAll(freshNotifs);
      }
    } catch (e) {
      debugPrint('[SampleApi] Deadline evaluation error: $e');
    }
  }

  /// Manually trigger a deadline evaluation check (e.g., from pull-to-refresh or resume)
  Future<void> checkDeadlines({
    DateTime? now,
    bool dispatchSystemTray = true,
  }) async {
    await _evaluateDeadlines(now: now, dispatchSystemTray: dispatchSystemTray);
    notifyListeners();
  }

  /// Synchronize both samples and notifications with remote backend (Online mode only)
  Future<void> syncWithBackend() async {
    if (!enableOnlineSync) {
      _isOffline = true;
      return;
    }

    try {
      await Future.wait([
        fetchSamplesFromRemote(),
        fetchNotificationsFromRemote(),
      ]);
      _isOffline = false;
      await _storage.setLastSync(DateTime.now());
      debugPrint('[SampleApi] Synchronized successfully with remote backend.');
    } catch (e) {
      _isOffline = true;
      debugPrint(
        '[SampleApi] Remote backend unreachable, operating in offline SQLite mode: $e',
      );
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _samples.clear();
    _notifications.clear();
    notifyListeners();
  }

  // ================= SAMPLES CRUD (OFFLINE SQLITE) =================

  /// Synchronous getter returning in-memory samples for instant UI rendering
  List<SampleItem> getSamples() => List.unmodifiable(_samples);

  /// Fetch latest samples from remote backend and upsert into SQLite (Online mode only)
  Future<List<SampleItem>> fetchSamplesFromRemote() async {
    if (!enableOnlineSync) return _samples;

    final response = await _client.get(ApiEndpoints.samples);
    if (response.statusCode == 200 && response.data is List) {
      final remoteItems = (response.data as List)
          .map((e) => SampleItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      for (var item in remoteItems) {
        await _db.insertSample(item);
      }

      final fresh = await _db.getAllSamples();
      _samples.clear();
      _samples.addAll(fresh);
      _isOffline = false;
      await _evaluateDeadlines();
      notifyListeners();
      return _samples;
    }
    throw ApiException(message: 'Invalid response from samples endpoint');
  }

  /// Add a new sample: immediately saves to SQLite and in-memory list
  Future<void> addSample(SampleItem item) async {
    SampleItem effectiveItem = item;
    if (item.status == SampleStatus.approved &&
        item.deadlineDate == null &&
        item.remainingDays > 0) {
      effectiveItem = item.copyWith(
        deadlineDate: DateTime.now().add(Duration(days: item.remainingDays)),
      );
    }

    _samples.insert(0, effectiveItem);
    await _db.insertSample(effectiveItem);

    if (effectiveItem.status == SampleStatus.approved) {
      await _evaluateDeadlines();
      await _deadlineEngine.scheduleMilestoneAlarms(effectiveItem);
    }
    notifyListeners();

    // =======================================================================
    // NEXT STAGE (ONLINE MODE):
    // if (enableOnlineSync) {
    //   _syncAddSampleRemote(item);
    // }
    // =======================================================================
  }

  /// Update sample status & days: immediately updates SQLite
  Future<void> updateSampleStatus(
    String id,
    SampleStatus status, {
    int? remainingDays,
    int? totalDays,
    DateTime? deadlineDate,
  }) async {
    final index = _samples.indexWhere((item) => item.id == id);
    if (index != -1) {
      _samples[index].status = status;
      if (remainingDays != null) {
        _samples[index].remainingDays = remainingDays;
      }
      if (totalDays != null) {
        _samples[index].totalDays = totalDays;
      }

      DateTime? effectiveDeadline = deadlineDate;
      if (status == SampleStatus.approved &&
          effectiveDeadline == null &&
          remainingDays != null) {
        effectiveDeadline = DateTime.now().add(Duration(days: remainingDays));
      }

      await _db.updateSampleStatus(
        id,
        status,
        remainingDays: remainingDays,
        totalDays: totalDays,
        deadlineDate: effectiveDeadline,
      );

      // Evaluate and manage scheduled alarms
      if (status == SampleStatus.approved) {
        await _evaluateDeadlines();
        final updatedSample = _samples[index].copyWith(
          status: status,
          remainingDays: remainingDays,
          totalDays: totalDays,
          deadlineDate: effectiveDeadline,
        );
        await _deadlineEngine.scheduleMilestoneAlarms(updatedSample);
      } else {
        // If moved to posted or pending, cancel any scheduled alarms
        await _deadlineEngine.cancelMilestoneAlarms(id);
      }

      notifyListeners();

      // =====================================================================
      // NEXT STAGE (ONLINE MODE):
      // if (enableOnlineSync) {
      //   _syncUpdateSampleStatusRemote(_samples[index]);
      // }
      // =====================================================================
    }
  }

  /// Delete a sample by ID from local SQLite database and in-memory list
  Future<void> deleteSample(String id) async {
    _samples.removeWhere((item) => item.id == id);
    await _db.deleteSample(id);
    await _deadlineEngine.cancelMilestoneAlarms(id);
    notifyListeners();

    // =======================================================================
    // NEXT STAGE (ONLINE MODE):
    // if (enableOnlineSync) {
    //   _syncDeleteSampleRemote(id);
    // }
    // =======================================================================
  }

  int get pendingCount =>
      _samples.where((s) => s.status == SampleStatus.pendingApproval).length;
  int get approvedCount =>
      _samples.where((s) => s.status == SampleStatus.approved).length;
  int get postedCount =>
      _samples.where((s) => s.status == SampleStatus.pendingCriteria).length;

  // ================= NOTIFICATIONS CRUD (OFFLINE SQLITE) =================

  /// Synchronous getter returning local notifications
  List<NotificationItem> getNotifications() =>
      List.unmodifiable(_notifications);

  /// Fetch latest notifications from remote backend and upsert into SQLite (Online mode only)
  Future<List<NotificationItem>> fetchNotificationsFromRemote() async {
    if (!enableOnlineSync) return _notifications;

    final response = await _client.get(ApiEndpoints.notifications);
    if (response.statusCode == 200 && response.data is List) {
      final remoteNotifs = (response.data as List)
          .map(
            (e) => NotificationItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      for (var n in remoteNotifs) {
        await _db.insertNotification(n);
      }

      final fresh = await _db.getAllNotifications();
      _notifications.clear();
      _notifications.addAll(fresh);
      _isOffline = false;
      notifyListeners();
      return _notifications;
    }
    throw ApiException(message: 'Invalid response from notifications endpoint');
  }

  bool hasUnreadNotifications() =>
      _notifications.any((item) => !item.isRead);

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _db.markAllNotificationsAsRead();
    notifyListeners();

    // =======================================================================
    // NEXT STAGE (ONLINE MODE):
    // if (enableOnlineSync) {
    //   _syncMarkAllReadRemote();
    // }
    // =======================================================================
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      _db.markNotificationAsRead(id);
      notifyListeners();

      // =====================================================================
      // NEXT STAGE (ONLINE MODE):
      // if (enableOnlineSync) {
      //   _syncMarkReadRemote(id);
      // }
      // =====================================================================
    }
  }

  /// Insert a local notification directly into SQLite (e.g. system alert, deadline notice)
  Future<void> addNotification(NotificationItem item) async {
    _notifications.insert(0, item);
    await _db.insertNotification(item);
    notifyListeners();
  }
}
