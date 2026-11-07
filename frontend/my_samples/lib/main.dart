import 'package:flutter/material.dart';
import 'package:sample_flow/core/notifications/local_notification_service.dart';
import 'package:sample_flow/core/theme/app_theme.dart';
import 'package:sample_flow/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:sample_flow/features/samples/data/api/sample_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize System Tray Notification Service & request permissions
  final notifService = LocalNotificationService();
  await notifService.init();
  await notifService.requestPermissions();

  // 2. Initialize local persistence, SQLite database & deadline evaluation
  await SampleApi().init();

  runApp(const SampleFlowApp());
}

class SampleFlowApp extends StatelessWidget {
  const SampleFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SampleFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
