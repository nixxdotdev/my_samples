import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sample_flow/core/database/app_database.dart';
import 'package:sample_flow/core/notifications/deadline_notification_engine.dart';
import 'package:sample_flow/core/notifications/local_notification_service.dart';
import 'package:sample_flow/features/samples/data/api/sample_api.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late AppDatabase database;
  late DeadlineNotificationEngine engine;
  late LocalNotificationService localNotifs;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sampleflow_notif_test_');
    final dbPath = p.join(tempDir.path, 'test_notifs.db');

    database = AppDatabase();
    database.setCustomFactory(databaseFactoryFfi, path: dbPath);
    await database.clearAll();

    localNotifs = LocalNotificationService();
    localNotifs.enableMockMode();

    engine = DeadlineNotificationEngine();
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Milestone Deadline Notification Engine Suite', () {
    test(
      'Sample with 7 days remaining does not trigger any deadline notifications',
      () async {
        final now = DateTime(2026, 11, 1, 10, 0);
        final deadline7Days = now.add(const Duration(days: 7));

        final sample = SampleItem(
          id: 'smp-7d',
          title: 'Wireless Earbuds Pro',
          category: 'Electronics & Audio',
          remainingDays: 7,
          totalDays: 7,
          deadlineDate: deadline7Days,
          status: SampleStatus.approved,
        );
        await database.insertSample(sample);

        final triggered = await engine.evaluateDeadlines(
          samples: [sample],
          now: now,
        );

        expect(triggered, isEmpty);
        expect(localNotifs.mockDispatchedNotifications, isEmpty);

        final inAppNotifs = await database.getAllNotifications();
        expect(inAppNotifs, isEmpty);
      },
    );

    test(
      'Sample with 5 days remaining triggers dual-channel 5-day milestone',
      () async {
        final now = DateTime(2026, 11, 1, 10, 0);
        final deadline5Days = now.add(const Duration(days: 5));

        final sample = SampleItem(
          id: 'smp-5d',
          title: 'Ultra Fast Charger 65W',
          category: 'Electronics & Audio',
          remainingDays: 5,
          totalDays: 7,
          deadlineDate: deadline5Days,
          status: SampleStatus.approved,
        );
        await database.insertSample(sample);

        final triggered = await engine.evaluateDeadlines(
          samples: [sample],
          now: now,
        );

        // 1. Returned notification check
        expect(triggered.length, 1);
        final notif = triggered.first;
        expect(notif.id, 'notif_smp-5d_5d');
        expect(notif.title, 'Reminder: 5 days left to post');
        expect(
          notif.description,
          contains('"Ultra Fast Charger 65W" review video is due in 5 days!'),
        );
        expect(notif.type, 'warning');

        // 2. Channel A: In-App SQLite verification
        final inAppNotifs = await database.getAllNotifications();
        expect(inAppNotifs.length, 1);
        expect(inAppNotifs.first.id, 'notif_smp-5d_5d');
        expect(inAppNotifs.first.isRead, isFalse);

        // 3. Channel B: System Tray dispatch verification
        expect(localNotifs.mockDispatchedNotifications.length, 1);
        final trayNotif = localNotifs.mockDispatchedNotifications.first;
        expect(trayNotif['title'], 'Reminder: 5 days left to post');
        expect(trayNotif['payload'], 'sample_smp-5d');
      },
    );

    test(
      'Deduplication: Running evaluate repeatedly never duplicates existing milestone notification',
      () async {
        final now = DateTime(2026, 11, 1, 10, 0);
        final deadline5Days = now.add(const Duration(days: 5));

        final sample = SampleItem(
          id: 'smp-dedup',
          title: 'Mechanical Gaming Keyboard',
          category: 'Computer & Office',
          remainingDays: 5,
          totalDays: 7,
          deadlineDate: deadline5Days,
          status: SampleStatus.approved,
        );
        await database.insertSample(sample);

        // First evaluation: fires notification
        final firstRun = await engine.evaluateDeadlines(
          samples: [sample],
          now: now,
        );
        expect(firstRun.length, 1);
        expect(localNotifs.mockDispatchedNotifications.length, 1);

        // Second evaluation at same time: must NOT fire duplicate
        final secondRun = await engine.evaluateDeadlines(
          samples: [sample],
          now: now,
        );
        expect(secondRun, isEmpty);
        expect(localNotifs.mockDispatchedNotifications.length, 1);

        // Third evaluation: still strictly 1 in-app notification in SQLite
        final allInApp = await database.getAllNotifications();
        expect(allInApp.length, 1);
      },
    );

    test(
      'Sample progressing to 3 days remaining triggers 3-day milestone',
      () async {
        final day1 = DateTime(2026, 11, 1, 10, 0);
        final deadline = day1.add(const Duration(days: 5));

        final sample = SampleItem(
          id: 'smp-prog',
          title: 'Hydration Face Serum',
          category: 'Beauty & Personal Care',
          remainingDays: 5,
          totalDays: 7,
          deadlineDate: deadline,
          status: SampleStatus.approved,
        );
        await database.insertSample(sample);

        // Day 1: 5 days left -> triggers 5d milestone
        final run1 = await engine.evaluateDeadlines(
          samples: [sample],
          now: day1,
        );
        expect(run1.length, 1);
        expect(run1.first.id, 'notif_smp-prog_5d');

        // Day 3: now 3 days left -> triggers 3d milestone
        final day3 = DateTime(2026, 11, 3, 10, 0);
        final run2 = await engine.evaluateDeadlines(
          samples: [sample],
          now: day3,
        );
        expect(run2.length, 1);
        expect(run2.first.id, 'notif_smp-prog_3d');
        expect(run2.first.title, 'Urgent: 3 days left to post');

        // SQLite now holds both 5d and 3d notifications
        final allNotifs = await database.getAllNotifications();
        expect(allNotifs.length, 2);
        expect(
          allNotifs.map((n) => n.id),
          containsAll(['notif_smp-prog_5d', 'notif_smp-prog_3d']),
        );
      },
    );

    test(
      'Sample progressing to 1 day remaining triggers Critical 1-day milestone',
      () async {
        final day5 = DateTime(2026, 11, 5, 10, 0);
        final deadline = day5.add(const Duration(days: 1)); // 1 day left

        final sample = SampleItem(
          id: 'smp-critical',
          title: 'Silk Sleep Mask',
          category: 'Beauty & Personal Care',
          remainingDays: 1,
          totalDays: 7,
          deadlineDate: deadline,
          status: SampleStatus.approved,
        );
        await database.insertSample(sample);

        final run = await engine.evaluateDeadlines(
          samples: [sample],
          now: day5,
        );
        expect(run.length, 1);
        expect(run.first.id, 'notif_smp-critical_1d');
        expect(run.first.title, 'Critical: 1 day left to post!');
        expect(run.first.type, 'critical');

        expect(localNotifs.mockDispatchedNotifications.length, 1);
        expect(
          localNotifs.mockDispatchedNotifications.first['title'],
          'Critical: 1 day left to post!',
        );
      },
    );

    test(
      'Pending approval and posted samples do not trigger deadline notifications',
      () async {
        final now = DateTime(2026, 11, 1, 10, 0);

        final pendingSample = SampleItem(
          id: 'smp-pending',
          title: 'Matte Lip Tint',
          category: 'Beauty & Personal Care',
          remainingDays: 1,
          totalDays: 7,
          status: SampleStatus.pendingApproval,
        );
        final postedSample = SampleItem(
          id: 'smp-posted',
          title: 'Hydra Mist',
          category: 'Beauty & Personal Care',
          remainingDays: 1,
          totalDays: 7,
          status: SampleStatus.pendingCriteria,
        );

        final triggered = await engine.evaluateDeadlines(
          samples: [pendingSample, postedSample],
          now: now,
        );

        expect(triggered, isEmpty);
        expect(localNotifs.mockDispatchedNotifications, isEmpty);
      },
    );

    test(
      'SampleApi integration: updating sample to Approved evaluates deadlines and updates unread badge',
      () async {
        final sampleApi = SampleApi();
        sampleApi.resetForTesting();

        final pendingSample = SampleItem(
          id: 'smp-flow-1',
          title: 'Studio Condenser Mic',
          category: 'Electronics & Audio',
          remainingDays: 0,
          totalDays: 0,
          status: SampleStatus.pendingApproval,
        );
        await sampleApi.addSample(pendingSample);

        // Initially no notifications
        expect(sampleApi.getNotifications(), isEmpty);
        expect(sampleApi.hasUnreadNotifications(), isFalse);

        // Move to Approved with 5 days
        await sampleApi.updateSampleStatus(
          'smp-flow-1',
          SampleStatus.approved,
          remainingDays: 5,
          totalDays: 5,
        );

        // Notifications should now contain 5d reminder
        final notifs = sampleApi.getNotifications();
        expect(notifs.length, 1);
        expect(notifs.first.id, 'notif_smp-flow-1_5d');
        expect(sampleApi.hasUnreadNotifications(), isTrue);

        // Marking as read updates state
        sampleApi.markNotificationAsRead('notif_smp-flow-1_5d');
        expect(sampleApi.hasUnreadNotifications(), isFalse);
      },
    );

    test(
      'scheduleMilestoneAlarms pre-schedules future alarms into OS AlarmManager for 9:00 AM on milestone days',
      () async {
        final now = DateTime.now();
        final deadline10Days = now.add(const Duration(days: 10));

        final sample = SampleItem(
          id: 'smp-sched-1',
          title: 'Mechanical Numpad RGB',
          category: 'Computer & Office',
          remainingDays: 10,
          totalDays: 10,
          deadlineDate: deadline10Days,
          status: SampleStatus.approved,
        );

        await engine.scheduleMilestoneAlarms(sample);

        // Expect 3 future alarms scheduled: 5d, 3d, 1d before deadline
        expect(localNotifs.mockScheduledNotifications.length, 3);

        final titles = localNotifs.mockScheduledNotifications
            .map((n) => n['title'])
            .toList();
        expect(
          titles,
          containsAll([
            'Reminder: 5 days left to post',
            'Urgent: 3 days left to post',
            'Critical: 1 day left to post!',
          ]),
        );

        // Verify scheduled for 9:00 AM
        for (final item in localNotifs.mockScheduledNotifications) {
          final scheduledDate = item['scheduledDate'] as DateTime;
          expect(scheduledDate.hour, 9);
          expect(scheduledDate.minute, 0);
          expect(scheduledDate.isAfter(now), isTrue);
        }

        // When sample is cancelled/posted, alarms are cleared
        await engine.cancelMilestoneAlarms(sample.id);
        expect(localNotifs.mockScheduledNotifications, isEmpty);
      },
    );
  });
}
