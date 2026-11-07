import 'package:flutter/foundation.dart';
import 'package:sample_flow/core/network/api_client.dart';
import 'package:sample_flow/core/network/api_endpoints.dart';
import 'package:sample_flow/core/network/api_exception.dart';
import 'package:sample_flow/core/storage/local_storage_service.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';

/// Offline-First Sample & Notification API Repository.
/// Combines local persistent disk storage (via SharedPreferences) with
/// remote REST API synchronization (via Dio ApiClient).
/// All actual data is sourced from and synchronized with the backend API.
class SampleApi extends ChangeNotifier {
  static final SampleApi _instance = SampleApi._internal();
  factory SampleApi() => _instance;
  SampleApi._internal();

  final LocalStorageService _storage = LocalStorageService();
  final ApiClient _client = ApiClient();

  bool _isInitialized = false;
  bool _isOffline = false;

  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _storage.getLastSync();
  String get currentBaseUrl => _storage.getBackendUrl();

  Future<void> updateBackendUrl(String newUrl) async {
    await _storage.saveBackendUrl(newUrl);
    _client.updateBaseUrl(newUrl);
    await syncWithBackend();
    notifyListeners();
  }

  // In-memory active stores (populated from local disk cache or remote backend)
  final List<SampleItem> _samples = [];
  final List<NotificationItem> _notifications = [];

  /// Initialize local persistence and hydrate in-memory stores.
  /// Also triggers background sync if remote backend is accessible.
  Future<void> init() async {
    if (_isInitialized) return;

    await _storage.init();

    // 1. Load Samples from disk cache if present
    final cachedSamplesJson = _storage.getCachedSamples();
    if (cachedSamplesJson != null && cachedSamplesJson.isNotEmpty) {
      _samples.clear();
      _samples.addAll(
        cachedSamplesJson.map((json) => SampleItem.fromJson(json)),
      );
    } else {
      _samples.clear();
    }

    // 2. Load Notifications from disk cache if present
    final cachedNotifsJson = _storage.getCachedNotifications();
    if (cachedNotifsJson != null && cachedNotifsJson.isNotEmpty) {
      _notifications.clear();
      _notifications.addAll(
        cachedNotifsJson.map((json) => NotificationItem.fromJson(json)),
      );
    } else {
      _notifications.clear();
    }

    _isInitialized = true;
    notifyListeners();

    // 3. Background sync with remote backend (non-blocking)
    syncWithBackend();
  }

  /// Persist current samples to disk cache via SharedPreferences
  Future<void> _persistSamplesToDisk() async {
    final list = _samples.map((s) => s.toJson()).toList();
    await _storage.saveSamples(list);
  }

  /// Persist current notifications to disk cache via SharedPreferences
  Future<void> _persistNotificationsToDisk() async {
    final list = _notifications.map((n) => n.toJson()).toList();
    await _storage.saveNotifications(list);
  }

  /// Synchronize both samples and notifications with remote backend
  Future<void> syncWithBackend() async {
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
        '[SampleApi] Remote backend unreachable, operating in offline/cached mode: $e',
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

  // ================= SAMPLES API =================

  /// Synchronous getter returning local in-memory samples for instant UI rendering
  List<SampleItem> getSamples() => List.unmodifiable(_samples);

  /// Fetch latest samples from remote backend
  Future<List<SampleItem>> fetchSamplesFromRemote() async {
    final response = await _client.get(ApiEndpoints.samples);
    if (response.statusCode == 200 && response.data is List) {
      final remoteItems = (response.data as List)
          .map((e) => SampleItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      _samples.clear();
      _samples.addAll(remoteItems);
      await _persistSamplesToDisk();
      _isOffline = false;
      notifyListeners();
      return _samples;
    }
    throw ApiException(message: 'Invalid response from samples endpoint');
  }

  /// Add a new sample: immediately saves to local cache, then syncs with remote API
  Future<void> addSample(SampleItem item) async {
    _samples.insert(0, item);
    await _persistSamplesToDisk();
    notifyListeners();

    // Fire and forget remote POST
    _syncAddSampleRemote(item);
  }

  Future<void> _syncAddSampleRemote(SampleItem item) async {
    try {
      await _client.post(
        ApiEndpoints.samples,
        data: item.toJson(),
      );
      _isOffline = false;
    } catch (e) {
      debugPrint(
        '[SampleApi] Remote add sample failed (stored locally in cache): $e',
      );
      _isOffline = true;
    }
  }

  /// Update sample status & days: immediately saves to local cache, then syncs with remote API
  Future<void> updateSampleStatus(
    String id,
    SampleStatus status, {
    int? remainingDays,
    int? totalDays,
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
      await _persistSamplesToDisk();
      notifyListeners();

      // Fire and forget remote status update
      _syncUpdateSampleStatusRemote(_samples[index]);
    }
  }

  Future<void> _syncUpdateSampleStatusRemote(SampleItem item) async {
    try {
      await _client.patch(
        ApiEndpoints.sampleStatus(item.id),
        data: {
          'status': item.status.name,
          'remainingDays': item.remainingDays,
          'totalDays': item.totalDays,
        },
      );
      _isOffline = false;
    } catch (e) {
      debugPrint(
        '[SampleApi] Remote status update failed (saved locally): $e',
      );
      _isOffline = true;
    }
  }

  int get pendingCount =>
      _samples.where((s) => s.status == SampleStatus.pendingApproval).length;
  int get approvedCount =>
      _samples.where((s) => s.status == SampleStatus.approved).length;
  int get postedCount =>
      _samples.where((s) => s.status == SampleStatus.pendingCriteria).length;

  // ================= NOTIFICATIONS API =================

  /// Synchronous getter returning local notifications
  List<NotificationItem> getNotifications() =>
      List.unmodifiable(_notifications);

  /// Fetch latest notifications from remote backend
  Future<List<NotificationItem>> fetchNotificationsFromRemote() async {
    final response = await _client.get(ApiEndpoints.notifications);
    if (response.statusCode == 200 && response.data is List) {
      final remoteNotifs = (response.data as List)
          .map(
            (e) => NotificationItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      _notifications.clear();
      _notifications.addAll(remoteNotifs);
      await _persistNotificationsToDisk();
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
    _persistNotificationsToDisk();
    notifyListeners();

    // Sync with remote (fire and forget)
    () async {
      try {
        await _client.patch(ApiEndpoints.markAllNotificationsRead);
      } catch (e) {
        debugPrint('[SampleApi] Remote mark all read error: $e');
      }
    }();
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      _persistNotificationsToDisk();
      notifyListeners();

      // Sync with remote (fire and forget)
      () async {
        try {
          await _client.patch(ApiEndpoints.markNotificationRead(id));
        } catch (e) {
          debugPrint('[SampleApi] Remote mark notification read error: $e');
        }
      }();
    }
  }
}
