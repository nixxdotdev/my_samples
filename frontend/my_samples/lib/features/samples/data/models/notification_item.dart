import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sample_flow/core/constants/app_colors.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isRead;
  final String? type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRead = false,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeAgo': timeAgo,
      'isRead': isRead,
      'type': type ?? 'info',
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? 'info').toLowerCase();
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case 'critical':
      case 'urgent':
      case 'deadline':
        icon = LucideIcons.alertCircle;
        iconColor = AppColors.critical;
        iconBgColor = AppColors.critical.withValues(alpha: 0.12);
        break;
      case 'approved':
      case 'success':
        icon = LucideIcons.checkCircle;
        iconColor = AppColors.approved;
        iconBgColor = AppColors.approved.withValues(alpha: 0.12);
        break;
      case 'shipping':
      case 'dispatched':
      case 'package':
        icon = LucideIcons.package;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primary.withValues(alpha: 0.12);
        break;
      case 'guidelines':
      case 'pending':
        icon = LucideIcons.fileText;
        iconColor = AppColors.pending;
        iconBgColor = AppColors.pending.withValues(alpha: 0.12);
        break;
      case 'offer':
      case 'collaboration':
      default:
        icon = LucideIcons.sparkles;
        iconColor = AppColors.primaryLight;
        iconBgColor = AppColors.primaryLight.withValues(alpha: 0.15);
        break;
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Just now',
      isRead: json['isRead'] as bool? ?? false,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      type: type,
    );
  }
}
