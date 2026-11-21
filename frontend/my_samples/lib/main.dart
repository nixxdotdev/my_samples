import 'package:flutter/material.dart';
import 'package:my_samples/core/notifications/local_notification_service.dart';
import 'package:my_samples/core/theme/app_theme.dart';
import 'package:my_samples/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize System Tray Notification Service & request permissions
  final notifService = LocalNotificationService();
  await notifService.init();
  await notifService.requestPermissions();

  // 2. Initialize local persistence, SQLite database & deadline evaluation
  await SampleApi().init();

  runApp(const MySampleApp());
}

class MySampleApp extends StatelessWidget {
  const MySampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySample',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
