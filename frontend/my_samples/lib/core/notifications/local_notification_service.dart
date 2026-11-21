import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service managing on-device System Tray Push/Local Notifications
/// via flutter_local_notifications for TikTok Shop sample deadlines.
/// Supports both instant dispatch and OS AlarmManager pre-scheduling (zonedSchedule).
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Test harness support for unit/integration tests running on headless host VM
  @visibleForTesting
  bool isMockMode = false;

  @visibleForTesting
  final List<Map<String, dynamic>> mockDispatchedNotifications = [];

  @visibleForTesting
  final List<Map<String, dynamic>> mockScheduledNotifications = [];

  @visibleForTesting
  void enableMockMode() {
    isMockMode = true;
    mockDispatchedNotifications.clear();
    mockScheduledNotifications.clear();
  }

  @visibleForTesting
  void clearMockDispatches() {
    mockDispatchedNotifications.clear();
    mockScheduledNotifications.clear();
  }

  static const String channelId = 'sample_deadlines';
  static const String channelName = 'Sample Review Deadlines';
  static const String channelDesc =
      'Alerts for TikTok Shop affiliate sample review deadlines';

  /// Initialize local notification plugin, timezone database & create Android notification channel
  Future<void> init() async {
    if (_isInitialized || isMockMode) return;

    try {
      // 1. Initialize Timezone database for zoned scheduling
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
            '[LocalNotificationService] Notification tapped: ${response.payload}',
          );
        },
      );

      // Create high-importance notification channel for Android
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        const androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(androidChannel);
      }

      _isInitialized = true;
      debugPrint('[LocalNotificationService] Initialized successfully.');
    } catch (e) {
      debugPrint('[LocalNotificationService] Host VM init skipped: $e');
    }
  }

  /// Request notification permissions (POST_NOTIFICATIONS on Android 13+)
  Future<bool> requestPermissions() async {
    if (isMockMode) return true;

    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[LocalNotificationService] Request permission skipped: $e');
    }

    return true;
  }

  /// Dispatches immediate system tray notification (Channel B) with custom silhouette icon, brand color & large icon banner
  Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (isMockMode) {
      mockDispatchedNotifications.add({
        'id': id,
        'title': title,
        'body': body,
        'payload': payload,
      });
      debugPrint(
        '[LocalNotificationService:Mock] Dispatched system tray notification #$id: "$title"',
      );
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Sample Deadline',
        icon: 'ic_stat_sample_flow',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color(0xFF215B63),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'MySample Deadline Alert',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint(
        '[LocalNotificationService] System tray notification dispatched #$id: "$title"',
      );
    } catch (e) {
      debugPrint(
        '[LocalNotificationService] Error showing system notification: $e',
      );
    }
  }

  /// Pre-schedules a future alarm into the Android OS AlarmManager (even if app is closed/killed)
  Future<void> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (isMockMode) {
      mockScheduledNotifications.add({
        'id': id,
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate,
        'payload': payload,
      });
      debugPrint(
        '[LocalNotificationService:Mock] Pre-scheduled alarm #$id at $scheduledDate: "$title"',
      );
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Sample Deadline',
        icon: 'ic_stat_sample_flow',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color(0xFF215B63),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'MySample Deadline Alert',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint(
        '[LocalNotificationService] Pre-scheduled OS alarm #$id for $scheduledDate ($tzDateTime): "$title"',
      );
    } catch (e) {
      debugPrint('[LocalNotificationService] Error scheduling alarm: $e');
    }
  }

  /// Cancel specific notification or scheduled alarm
  Future<void> cancel(int id) async {
    if (isMockMode) {
      mockDispatchedNotifications.removeWhere((n) => n['id'] == id);
      mockScheduledNotifications.removeWhere((n) => n['id'] == id);
      return;
    }
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  /// Cancel all notifications and alarms
  Future<void> cancelAll() async {
    if (isMockMode) {
      mockDispatchedNotifications.clear();
      mockScheduledNotifications.clear();
      return;
    }
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
