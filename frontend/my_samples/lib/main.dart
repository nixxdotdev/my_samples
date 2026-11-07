import 'package:flutter/material.dart';
import 'package:sample_flow/core/theme/app_theme.dart';
import 'package:sample_flow/features/navigation/presentation/screens/main_navigation_screen.dart';

void main() {
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
