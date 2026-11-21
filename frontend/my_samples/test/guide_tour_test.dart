import 'package:flutter_test/flutter_test.dart';
import 'package:my_samples/features/guide/presentation/widgets/interactive_tour_overlay.dart';
import 'package:my_samples/features/guide/services/guide_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GuideController Interactive Tour Suite', () {
    test('Starts tour at step 0 and notifies listeners with target tab 0', () {
      final controller = GuideController();
      int? switchedTab;

      controller.startTour(onTabSwitch: (tab) {
        switchedTab = tab;
      });

      expect(controller.isTourActive, isTrue);
      expect(controller.currentStep, 0);
      expect(switchedTab, 0);
    });

    test('Steps forward and transitions tabs in real time', () {
      final controller = GuideController();
      int? switchedTab;

      controller.startTour(onTabSwitch: (tab) => switchedTab = tab);

      // Step 0 -> 1 -> 2 -> 3 (Tab 0 -> Tab 1)
      while (controller.currentStep < 3) {
        controller.nextStep(onTabSwitch: (tab) => switchedTab = tab);
      }

      // Step 3 (index 3) is "Category Filter Tabs" on Tab 1
      expect(controller.currentStep, 3);
      expect(InteractiveTourOverlay.steps[3].targetTabIndex, 1);
      expect(switchedTab, 1);
    });

    test('Steps backward and updates currentStep', () {
      final controller = GuideController();
      controller.startTour();

      controller.nextStep();
      expect(controller.currentStep, 1);

      controller.previousStep();
      expect(controller.currentStep, 0);
    });

    test('Dismisses tour and sets isTourActive to false', () {
      final controller = GuideController();
      controller.startTour();
      expect(controller.isTourActive, isTrue);

      controller.dismissTour();
      expect(controller.isTourActive, isFalse);
    });
  });
}
