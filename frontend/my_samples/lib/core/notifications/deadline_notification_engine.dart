import 'package:flutter/foundation.dart';
import 'package:my_samples/core/database/app_database.dart';
import 'package:my_samples/core/notifications/local_notification_service.dart';
import 'package:my_samples/features/samples/data/models/notification_item.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';

/// Milestone definition model
class DeadlineMilestone {
  final String suffix;
  final int daysBeforeDeadline;
  final String title;
  final String type;
  final String Function(String sampleTitle) messageBuilder;

  const DeadlineMilestone({
    required this.suffix,
    required this.daysBeforeDeadline,
    required this.title,
    required this.type,
    required this.messageBuilder,
  });
}

/// Evaluates and pre-schedules sample review deadlines with dual-channel notification delivery:
/// - Channel A: In-App Notification Hub (saved to on-device SQLite 'notifications' table)
/// - Channel B: Android System Tray (dispatched or pre-scheduled via flutter_local_notifications & AlarmManager)
///
/// Milestones:
/// 1. Due before 5 days (5d left): Reminder (Pre-scheduled for 9:00 AM)
/// 2. Due before 3 days (3d left): Urgent (Pre-scheduled for 9:00 AM)
/// 3. Due before 1 day (1d left / critical): Final Warning (Pre-scheduled for 9:00 AM)
class DeadlineNotificationEngine {
  static final DeadlineNotificationEngine _instance =
      DeadlineNotificationEngine._internal();
  factory DeadlineNotificationEngine() => _instance;
  DeadlineNotificationEngine._internal();

  final AppDatabase _db = AppDatabase();
  final LocalNotificationService _localNotifs = LocalNotificationService();

  static const milestone5Days = DeadlineMilestone(
    suffix: '5d',
    daysBeforeDeadline: 5,
    title: 'Reminder: 5 days left to post',
    type: 'warning',
    messageBuilder: _milestone5Msg,
  );

  static const milestone3Days = DeadlineMilestone(
    suffix: '3d',
    daysBeforeDeadline: 3,
    title: 'Urgent: 3 days left to post',
    type: 'urgent',
    messageBuilder: _milestone3Msg,
  );

  static const milestone1Day = DeadlineMilestone(
    suffix: '1d',
    daysBeforeDeadline: 1,
    title: 'Critical: 1 day left to post!',
    type: 'critical',
    messageBuilder: _milestone1Msg,
  );

  static const List<DeadlineMilestone> allMilestones = [
    milestone5Days,
    milestone3Days,
    milestone1Day,
  ];

  static String _milestone5Msg(String title) =>
      '"$title" review video is due in 5 days!';
  static String _milestone3Msg(String title) =>
      'Only 3 days left to submit review video for "$title"!';
  static String _milestone1Msg(String title) =>
      'Final deadline! You have 1 day left to post review for "$title" to maintain creator standing!';

  /// Pre-schedules all 3 future milestone alarms into Android AlarmManager for a sample.
  /// Each alarm fires at 9:00 AM on the milestone date (5d, 3d, and 1d before deadline).
  /// Works 100% offline even if the app process is completely killed.
  Future<void> scheduleMilestoneAlarms(SampleItem sample) async {
    if (sample.status != SampleStatus.approved || sample.deadlineDate == null) {
      return;
    }

    final deadline = sample.deadlineDate!;
    final now = DateTime.now();

    for (final milestone in allMilestones) {
      final milestoneId = 'notif_${sample.id}_${milestone.suffix}';

      // Check if already notified in SQLite
      final alreadyNotified = await _db.hasNotification(milestoneId);
      if (alreadyNotified) continue;

      // Milestone date (e.g. deadline minus 5 days, at 9:00 AM)
      final rawDate = deadline.subtract(
        Duration(days: milestone.daysBeforeDeadline),
      );
      final scheduledAlarmTime = DateTime(
        rawDate.year,
        rawDate.month,
        rawDate.day,
        9,
        0,
        0,
      );

      // If scheduled time is in the future, register with Android AlarmManager
      if (scheduledAlarmTime.isAfter(now)) {
        await _localNotifs.scheduleZonedNotification(
          id: milestoneId.hashCode.abs(),
          title: milestone.title,
          body: milestone.messageBuilder(sample.title),
          scheduledDate: scheduledAlarmTime,
          payload: 'sample_${sample.id}',
        );
        debugPrint(
          '[DeadlineEngine] Pre-scheduled ${milestone.suffix} alarm for "${sample.title}" at $scheduledAlarmTime',
        );
      }
    }
  }

  /// Cancels all scheduled milestone alarms for a sample (e.g. when posted or deleted)
  Future<void> cancelMilestoneAlarms(String sampleId) async {
    for (final milestone in allMilestones) {
      final milestoneId = 'notif_${sampleId}_${milestone.suffix}';
      await _localNotifs.cancel(milestoneId.hashCode.abs());
    }
    debugPrint(
      '[DeadlineEngine] Cancelled scheduled alarms for sample $sampleId',
    );
  }

  /// Evaluates active approved samples and immediately triggers any milestone notifications
  /// that are due right now.
  ///
  /// [samples]: Optional list of samples. If null, loads all approved samples from SQLite.
  /// [now]: Optional mock reference date for time-travel unit testing.
  /// [dispatchSystemTray]: Whether to trigger Android system tray notifications.
  ///
  /// Returns list of newly created and delivered notifications.
  Future<List<NotificationItem>> evaluateDeadlines({
    List<SampleItem>? samples,
    DateTime? now,
    bool dispatchSystemTray = true,
  }) async {
    final currentRefTime = now ?? DateTime.now();

    List<SampleItem> targetSamples =
        samples ?? await _db.getAllSamples(status: SampleStatus.approved.name);

    // Filter to only approved items
    targetSamples = targetSamples
        .where((s) => s.status == SampleStatus.approved)
        .toList();

    final newlyTriggered = <NotificationItem>[];

    for (final sample in targetSamples) {
      // Calculate effective remaining days
      final int remainingDays;
      if (sample.deadlineDate != null) {
        final diff = sample.deadlineDate!.difference(currentRefTime);
        remainingDays = diff.isNegative
            ? 0
            : (diff.inMinutes / (24 * 60)).ceil();
      } else {
        remainingDays = sample.remainingDays;
      }

      // Check which milestone applies
      DeadlineMilestone? milestone;
      if (remainingDays <= 1 && remainingDays >= 0) {
        milestone = milestone1Day;
      } else if (remainingDays <= 3 && remainingDays > 1) {
        milestone = milestone3Days;
      } else if (remainingDays <= 5 && remainingDays > 3) {
        milestone = milestone5Days;
      }

      // If sample is > 5 days or out of range, no immediate milestone
      if (milestone == null) continue;

      final milestoneId = 'notif_${sample.id}_${milestone.suffix}';

      // 1. Milestone Deduplication Check
      final alreadyNotified = await _db.hasNotification(milestoneId);
      if (alreadyNotified) {
        continue;
      }

      final notification = NotificationItem(
        id: milestoneId,
        title: milestone.title,
        description: milestone.messageBuilder(sample.title),
        timeAgo: 'Just now',
        type: milestone.type,
        isRead: false,
      );

      // Channel A: In-App Notification Hub (Persist to SQLite)
      await _db.insertNotification(notification);

      // Channel B: Android System Tray Push/Local Notification
      if (dispatchSystemTray) {
        try {
          await _localNotifs.showSystemNotification(
            id: milestoneId.hashCode.abs(),
            title: notification.title,
            body: notification.description,
            payload: 'sample_${sample.id}',
          );
        } catch (e) {
          debugPrint(
            '[DeadlineEngine] System tray notification error for $milestoneId: $e',
          );
        }
      }

      newlyTriggered.add(notification);
      debugPrint(
        '[DeadlineEngine] Triggered ${milestone.suffix} milestone for sample "${sample.title}" (Remaining: $remainingDays days)',
      );
    }

    return newlyTriggered;
  }
}
