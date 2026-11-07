import 'package:flutter/material.dart';
import 'package:sample_flow/core/constants/app_colors.dart';
import 'package:sample_flow/features/about/presentation/screens/about_screen.dart';
import 'package:sample_flow/features/navigation/presentation/widgets/app_bottom_nav.dart';
import 'package:sample_flow/features/samples/presentation/screens/home_tab_screen.dart';
import 'package:sample_flow/features/samples/presentation/screens/your_samples_screen.dart';
import 'package:sample_flow/features/samples/presentation/widgets/add_sample_bottom_sheet.dart';
import 'package:sample_flow/features/samples/presentation/widgets/add_sample_fab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;
  int _selectedSampleStatusFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildCurrentTabContent()),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
      floatingActionButton: _currentTabIndex == 1
          ? AddSampleFab(
              onPressed: () {
                AddSampleBottomSheet.show(
                  context,
                  onSampleAdded: (newSample) {
                    setState(() {
                      _selectedSampleStatusFilter = newSample.status.index;
                      _currentTabIndex = 1;
                    });
                  },
                );
              },
            )
          : null,
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTabIndex) {
      case 1:
        return YourSamplesScreen(
          key: ValueKey('your_samples_$_selectedSampleStatusFilter'),
          initialStatusIndex: _selectedSampleStatusFilter,
          onBackToHome: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 2:
        return const AboutScreen();
      case 0:
      default:
        return HomeTabScreen(
          onNavigateToSamples: () {
            setState(() {
              _currentTabIndex = 1;
            });
          },
          onNavigateToSamplesWithStatus: (status) {
            setState(() {
              _selectedSampleStatusFilter = status;
              _currentTabIndex = 1;
            });
          },
        );
    }
  }
}
