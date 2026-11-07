import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';
import 'package:sample_flow/features/samples/data/api/sample_api.dart';
import 'package:sample_flow/core/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('LocalStorageService & SampleApi Clean State Flow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SampleApi().resetForTesting();
    });

    test('SampleApi initializes cleanly without hardcoded mock data', () async {
      final api = SampleApi();
      await api.init();

      // Starts empty since no mock data is hardcoded in the frontend
      expect(api.getSamples().isEmpty, true);
      expect(api.getNotifications().isEmpty, true);
    });

    test('Adding a sample immediately reflects in memory and updates persistent cache', () async {
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

      // Verify disk cache updated
      final storage = LocalStorageService();
      final cached = storage.getCachedSamples();
      expect(cached?.first['id'], 'new-999');
    });

    test('Restores previously cached items on cold launch', () async {
      final storage = LocalStorageService();
      await storage.saveSamples([
        {
          'id': 'cached-1',
          'title': 'RGB Light Panel',
          'category': 'Creator Studio Gear',
          'remainingDays': 5,
          'totalDays': 14,
          'status': 'approved',
        }
      ]);

      final api = SampleApi();
      await api.init();

      expect(api.getSamples().length, 1);
      expect(api.getSamples().first.id, 'cached-1');
      expect(api.getSamples().first.title, 'RGB Light Panel');
    });
  });
}
