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
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    this.isRead = false,
    this.type,
  })  : icon = icon ?? _resolveIcon(type),
        iconColor = iconColor ?? _resolveColor(type),
        iconBgColor = iconBgColor ?? _resolveBgColor(type);

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
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Just now',
      isRead: json['isRead'] as bool? ?? false,
      type: type,
    );
  }

  static IconData _resolveIcon(String? type) {
    switch ((type ?? 'info').toLowerCase()) {
      case 'critical':
      case 'urgent':
      case 'deadline':
        return LucideIcons.alertCircle;
      case 'approved':
      case 'success':
        return LucideIcons.checkCircle;
      case 'shipping':
      case 'dispatched':
      case 'package':
        return LucideIcons.package;
      case 'guidelines':
      case 'pending':
        return LucideIcons.fileText;
      case 'offer':
      case 'collaboration':
      default:
        return LucideIcons.sparkles;
    }
  }

  static Color _resolveColor(String? type) {
    switch ((type ?? 'info').toLowerCase()) {
      case 'critical':
      case 'urgent':
      case 'deadline':
        return AppColors.critical;
      case 'approved':
      case 'success':
        return AppColors.approved;
      case 'shipping':
      case 'dispatched':
      case 'package':
        return AppColors.primary;
      case 'guidelines':
      case 'pending':
        return AppColors.pending;
      case 'offer':
      case 'collaboration':
      default:
        return AppColors.primaryLight;
    }
  }

  static Color _resolveBgColor(String? type) {
    final color = _resolveColor(type);
    return color.withValues(alpha: 0.12);
  }
}
