import 'package:flutter/material.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/about/presentation/screens/about_screen.dart';
import 'package:my_samples/features/guide/presentation/widgets/interactive_tour_overlay.dart';
import 'package:my_samples/features/guide/services/guide_controller.dart';
import 'package:my_samples/features/navigation/presentation/widgets/app_bottom_nav.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';
import 'package:my_samples/features/samples/presentation/screens/home_tab_screen.dart';
import 'package:my_samples/features/samples/presentation/screens/your_samples_screen.dart';
import 'package:my_samples/features/samples/presentation/widgets/add_sample_bottom_sheet.dart';
import 'package:my_samples/features/samples/presentation/widgets/add_sample_fab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;
  int _selectedSampleStatusFilter = 0;

  void _triggerTour() {
    GuideController().startTour(
      onTabSwitch: (tab) {
        setState(() {
          _currentTabIndex = tab;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(child: _buildCurrentTabContent()),
          ListenableBuilder(
            listenable: GuideController(),
            builder: (context, _) {
              final guide = GuideController();
              if (!guide.isTourActive) return const SizedBox.shrink();
              return InteractiveTourOverlay(
                currentStep: guide.currentStep,
                onNext: () {
                  guide.nextStep(
                    onTabSwitch: (tab) {
                      setState(() {
                        _currentTabIndex = tab;
                      });
                    },
                  );
                },
                onPrevious: () {
                  guide.previousStep(
                    onTabSwitch: (tab) {
                      setState(() {
                        _currentTabIndex = tab;
                      });
                    },
                  );
                },
                onDismiss: () => guide.dismissTour(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: SampleApi(),
        builder: (context, _) => AppBottomNav(
          currentIndex: _currentTabIndex,
          hasNotification: SampleApi().hasUnreadNotifications(),
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
        ),
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
        return AboutScreen(onStartGuide: _triggerTour);
      case 0:
      default:
        return HomeTabScreen(
          onStartGuide: _triggerTour,
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
