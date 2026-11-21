import 'package:flutter/material.dart';
import 'package:my_samples/features/samples/data/utils/sample_utils.dart';
import 'sample_status.dart';

class SampleItem {
  final String id;
  final String title;
  final String category;
  int remainingDays;
  int totalDays;
  final DateTime? deadlineDate;
  final IconData icon;
  SampleStatus status;

  SampleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.remainingDays,
    required this.totalDays,
    this.deadlineDate,
    IconData? icon,
    this.status = SampleStatus.pendingApproval,
  }) : icon = icon ?? SampleUtils.getCategoryIcon(category);

  /// Dynamically calculated remaining days based on calendar deadline
  int get calculatedRemainingDays {
    if (deadlineDate != null) {
      final diff = deadlineDate!.difference(DateTime.now());
      if (diff.isNegative) return 0;
      return (diff.inMinutes / (24 * 60)).ceil();
    }
    return remainingDays;
  }

  /// Helper copyWith if needed for immutable updates
  SampleItem copyWith({
    String? id,
    String? title,
    String? category,
    int? remainingDays,
    int? totalDays,
    DateTime? deadlineDate,
    bool clearDeadlineDate = false,
    IconData? icon,
    SampleStatus? status,
  }) {
    return SampleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      remainingDays: remainingDays ?? this.remainingDays,
      totalDays: totalDays ?? this.totalDays,
      deadlineDate: clearDeadlineDate ? null : (deadlineDate ?? this.deadlineDate),
      icon: icon ?? this.icon,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'remainingDays': remainingDays,
      'totalDays': totalDays,
      'deadlineDate': deadlineDate?.toIso8601String(),
      'status': status.name,
    };
  }

  factory SampleItem.fromJson(Map<String, dynamic> json) {
    SampleStatus status = SampleStatus.pendingApproval;
    final statusStr = json['status']?.toString();
    if (statusStr != null) {
      for (var s in SampleStatus.values) {
        if (s.name.toLowerCase() == statusStr.toLowerCase() ||
            s.label.toLowerCase() == statusStr.toLowerCase()) {
          status = s;
          break;
        }
      }
    }

    final category = json['category'] as String? ?? 'Electronics & Audio';
    DateTime? deadlineDate;
    final dStr = json['deadlineDate'] ?? json['deadline_date'];
    if (dStr != null) {
      deadlineDate = DateTime.tryParse(dStr.toString());
    }

    return SampleItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      category: category,
      remainingDays: json['remainingDays'] is int
          ? json['remainingDays'] as int
          : int.tryParse(json['remainingDays']?.toString() ?? '0') ?? 0,
      totalDays: json['totalDays'] is int
          ? json['totalDays'] as int
          : int.tryParse(json['totalDays']?.toString() ?? '0') ?? 0,
      deadlineDate: deadlineDate,
      icon: SampleUtils.getCategoryIcon(category),
      status: status,
    );
  }
}
