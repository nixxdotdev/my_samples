import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';

class SampleUtils {
  static const List<String> categories = [
    'Electronics & Audio',
    'Beauty & Skincare',
    'Apparel & Fashion',
    'Home & Kitchen',
    'Gadgets & Fitness',
    'Computer & Office',
    'Creator Studio Gear',
    'Accessories & Travel',
    'Mobile & Tech',
    'Personal Care',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics & Audio':
        return LucideIcons.headphones;
      case 'Beauty & Skincare':
        return LucideIcons.sparkles;
      case 'Apparel & Fashion':
        return LucideIcons.shirt;
      case 'Home & Kitchen':
        return LucideIcons.coffee;
      case 'Gadgets & Fitness':
        return LucideIcons.watch;
      case 'Computer & Office':
        return LucideIcons.keyboard;
      case 'Creator Studio Gear':
        return LucideIcons.camera;
      case 'Accessories & Travel':
        return LucideIcons.wallet;
      case 'Mobile & Tech':
        return LucideIcons.smartphone;
      case 'Personal Care':
        return LucideIcons.droplets;
      default:
        return LucideIcons.package;
    }
  }

  static Color getSampleStatusColor(SampleStatus status) {
    switch (status) {
      case SampleStatus.pendingApproval:
        return AppColors.pending;
      case SampleStatus.approved:
        return AppColors.approved;
      case SampleStatus.pendingCriteria:
        return AppColors.posting;
    }
  }
}
