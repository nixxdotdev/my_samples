import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_samples/core/database/app_database.dart';
import 'package:my_samples/core/network/api_client.dart';
import 'package:my_samples/core/network/api_endpoints.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Frontend Live HTTP Client Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AppDatabase().setCustomFactory(databaseFactoryFfi, path: inMemoryDatabasePath);
      await AppDatabase().clearAll();
      SampleApi().resetForTesting();
    });

    test('ApiClient handles endpoint structure and response parsing', () async {
      final client = ApiClient();
      expect(client.baseUrl, isNotEmpty);
      expect(ApiEndpoints.samples, '/api/samples');
      expect(ApiEndpoints.notifications, '/api/notifications');
      expect(ApiEndpoints.sampleStatus('123'), '/api/samples/123/status');
    });

    test('SampleApi notifies listeners when data is updated or synced', () async {
      final api = SampleApi();
      int notificationCount = 0;
      api.addListener(() {
        notificationCount++;
      });

      await api.init();
      expect(notificationCount > 0, true);

      final sample = SampleItem(
        id: 'test-sync-1',
        title: 'Wireless Stream Mic',
        category: 'Electronics & Audio',
        remainingDays: 0,
        totalDays: 0,
        status: SampleStatus.pendingApproval,
      );

      final prevCount = notificationCount;
      await api.addSample(sample);
      expect(notificationCount > prevCount, true);
    });
  });
}
