import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sample_flow/core/database/app_database.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for running SQLite tests on host machine
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('AppDatabase SQLite Offline CRUD Suite', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase();
      db.setCustomFactory(databaseFactoryFfi, path: inMemoryDatabasePath);
      await db.clearAll();
    });

    tearDown(() async {
      await db.close();
    });

    test('Insert and query sample in local SQLite', () async {
      final sample = SampleItem(
        id: 'sql-1',
        title: 'Wireless Gaming Mouse RGB',
        category: 'Electronics & Audio',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      );

      await db.insertSample(sample);

      final samples = await db.getAllSamples();
      expect(samples.length, 1);
      expect(samples.first.id, 'sql-1');
      expect(samples.first.title, 'Wireless Gaming Mouse RGB');
      expect(samples.first.status, SampleStatus.pendingApproval);
    });

    test('Update sample status and remaining days in SQLite', () async {
      final sample = SampleItem(
        id: 'sql-2',
        title: 'Mechanical Numpad',
        category: 'Computer & Office',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      );

      await db.insertSample(sample);

      // Transition to approved with 14 days
      await db.updateSampleStatus(
        'sql-2',
        SampleStatus.approved,
        remainingDays: 14,
        totalDays: 14,
      );

      final updated = await db.getSampleById('sql-2');
      expect(updated, isNotNull);
      expect(updated!.status, SampleStatus.approved);
      expect(updated.remainingDays, 14);
      expect(updated.totalDays, 14);
    });

    test('Filter samples by status and search keyword', () async {
      await db.insertSample(SampleItem(
        id: 's-1',
        title: 'Ergonomic Desk Chair Pad',
        category: 'Home & Kitchen',
        remainingDays: 5,
        totalDays: 14,
        status: SampleStatus.approved,
      ));
      await db.insertSample(SampleItem(
        id: 's-2',
        title: 'USB-C Fast Charger 65W',
        category: 'Electronics & Audio',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      ));

      final approved = await db.getAllSamples(status: 'approved');
      expect(approved.length, 1);
      expect(approved.first.id, 's-1');

      final searched = await db.getAllSamples(search: 'Charger');
      expect(searched.length, 1);
      expect(searched.first.id, 's-2');
    });

    test('Delete sample removes record from SQLite', () async {
      await db.insertSample(SampleItem(
        id: 's-delete',
        title: 'Sample to Remove',
        category: 'Beauty & Skincare',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      ));

      expect((await db.getAllSamples()).length, 1);

      await db.deleteSample('s-delete');
      expect((await db.getAllSamples()).isEmpty, true);
    });

    test('Calculate sample counts metrics', () async {
      await db.insertSample(SampleItem(
        id: 'c1',
        title: 'Item 1',
        category: 'Beauty & Skincare',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      ));
      await db.insertSample(SampleItem(
        id: 'c2',
        title: 'Item 2',
        category: 'Beauty & Skincare',
        remainingDays: 10,
        totalDays: 14,
        status: SampleStatus.approved,
      ));
      await db.insertSample(SampleItem(
        id: 'c3',
        title: 'Item 3',
        category: 'Beauty & Skincare',
        remainingDays: 12,
        totalDays: 14,
        status: SampleStatus.pendingCriteria,
      ));

      final counts = await db.getSampleCounts();
      expect(counts['pending'], 1);
      expect(counts['approved'], 1);
      expect(counts['posted'], 1);
      expect(counts['total'], 3);
    });

    test('Notifications CRUD and mark as read in SQLite', () async {
      final notif = NotificationItem(
        id: 'n-sql-1',
        title: 'Video review deadline',
        description: 'Post before tomorrow',
        timeAgo: '10m ago',
        type: 'urgent',
      );

      await db.insertNotification(notif);
      expect(await db.hasUnreadNotifications(), true);

      await db.markNotificationAsRead('n-sql-1');
      expect(await db.hasUnreadNotifications(), false);

      final all = await db.getAllNotifications();
      expect(all.first.isRead, true);
    });
  });
}
