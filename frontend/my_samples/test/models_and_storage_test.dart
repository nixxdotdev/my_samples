import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sample_flow/core/database/app_database.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';
import 'package:sample_flow/features/samples/data/api/sample_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SampleItem Serialization', () {
    test('toJson and fromJson preserve sample properties correctly', () {
      final sample = SampleItem(
        id: 'test-101',
        title: 'Studio Microphone USB-C',
        category: 'Electronics & Audio',
        remainingDays: 4,
        totalDays: 14,
        status: SampleStatus.approved,
      );

      final json = sample.toJson();
      expect(json['id'], 'test-101');
      expect(json['title'], 'Studio Microphone USB-C');
      expect(json['remainingDays'], 4);
      expect(json['status'], 'approved');

      final deserialized = SampleItem.fromJson(json);
      expect(deserialized.id, sample.id);
      expect(deserialized.title, sample.title);
      expect(deserialized.remainingDays, sample.remainingDays);
      expect(deserialized.status, SampleStatus.approved);
    });
  });

  group('NotificationItem Serialization', () {
    test('toJson and fromJson preserve notification details', () {
      final notif = NotificationItem(
        id: 'n-test',
        title: 'Review Due Reminder',
        description: 'Please post video before deadline.',
        timeAgo: '1h ago',
        icon: LucideIcons.alertCircle,
        iconColor: const Color(0xFF000000),
        iconBgColor: const Color(0x11000000),
        type: 'urgent',
      );

      final json = notif.toJson();
      expect(json['id'], 'n-test');
      expect(json['type'], 'urgent');

      final deserialized = NotificationItem.fromJson(json);
      expect(deserialized.id, 'n-test');
      expect(deserialized.title, 'Review Due Reminder');
    });
  });

  group('SQLite & SampleApi Clean State Flow', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AppDatabase().setCustomFactory(databaseFactoryFfi, path: inMemoryDatabasePath);
      await AppDatabase().clearAll();
      SampleApi().resetForTesting();
    });

    test('SampleApi initializes cleanly without hardcoded mock data', () async {
      final api = SampleApi();
      await api.init();

      // Starts empty since no mock data is hardcoded in the frontend
      expect(api.getSamples().isEmpty, true);
      expect(api.getNotifications().isEmpty, true);
    });

    test('Adding a sample immediately reflects in memory and persists to SQLite', () async {
      final api = SampleApi();
      await api.init();

      final newSample = SampleItem(
        id: 'new-999',
        title: 'Ultra Wide 4K Monitor',
        category: 'Computer & Office',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      );

      await api.addSample(newSample);

      expect(api.getSamples().length, 1);
      expect(api.getSamples().first.id, 'new-999');

      // Verify SQLite row exists
      final sqliteRow = await AppDatabase().getSampleById('new-999');
      expect(sqliteRow, isNotNull);
      expect(sqliteRow!.title, 'Ultra Wide 4K Monitor');
    });

    test('Restores previously stored items from SQLite on launch', () async {
      final db = AppDatabase();
      await db.insertSample(
        SampleItem(
          id: 'sqlite-1',
          title: 'RGB Light Panel',
          category: 'Creator Studio Gear',
          remainingDays: 5,
          totalDays: 14,
          status: SampleStatus.approved,
        ),
      );

      final api = SampleApi();
      await api.init();

      expect(api.getSamples().length, 1);
      expect(api.getSamples().first.id, 'sqlite-1');
      expect(api.getSamples().first.title, 'RGB Light Panel');
    });
  });
}
