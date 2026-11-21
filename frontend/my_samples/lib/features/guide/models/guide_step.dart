import 'package:flutter/material.dart';

class GuideStep {
  final int stepIndex;
  final int totalSteps;
  final int targetTabIndex;
  final String title;
  final String section;
  final String description;
  final String? whatToFill;
  final String whichButtonToTap;
  final IconData icon;
  final Alignment cardAlignment;

  const GuideStep({
    required this.stepIndex,
    required this.totalSteps,
    required this.targetTabIndex,
    required this.title,
    required this.section,
    required this.description,
    this.whatToFill,
    required this.whichButtonToTap,
    required this.icon,
    this.cardAlignment = Alignment.center,
  });
}
