import 'package:flutter/foundation.dart';
import 'package:my_samples/core/storage/local_storage_service.dart';
import 'package:my_samples/features/guide/presentation/widgets/interactive_tour_overlay.dart';

class GuideController extends ChangeNotifier {
  static final GuideController _instance = GuideController._internal();
  factory GuideController() => _instance;
  GuideController._internal();

  final LocalStorageService _storage = LocalStorageService();

  bool _isTourActive = false;
  int _currentStep = 0;

  bool get isTourActive => _isTourActive;
  int get currentStep => _currentStep;

  /// Start or restart the tour from step 0
  void startTour({void Function(int tabIndex)? onTabSwitch}) {
    _currentStep = 0;
    _isTourActive = true;
    onTabSwitch?.call(InteractiveTourOverlay.steps[0].targetTabIndex);
    notifyListeners();
  }

  /// Move to the next step and automatically switch the screen tab if required
  void nextStep({void Function(int tabIndex)? onTabSwitch}) {
    if (_currentStep < InteractiveTourOverlay.steps.length - 1) {
      _currentStep++;
      final targetTab =
          InteractiveTourOverlay.steps[_currentStep].targetTabIndex;
      onTabSwitch?.call(targetTab);
      notifyListeners();
    } else {
      dismissTour();
    }
  }

  /// Move to the previous step and automatically switch the screen tab if required
  void previousStep({void Function(int tabIndex)? onTabSwitch}) {
    if (_currentStep > 0) {
      _currentStep--;
      final targetTab =
          InteractiveTourOverlay.steps[_currentStep].targetTabIndex;
      onTabSwitch?.call(targetTab);
      notifyListeners();
    }
  }

  /// Close / dismiss the tour and mark as seen
  void dismissTour() {
    _isTourActive = false;
    _storage.setSeenInteractiveTour(true);
    notifyListeners();
  }
}
