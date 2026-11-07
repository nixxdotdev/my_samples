import 'package:flutter/material.dart';
import 'sample_status.dart';

class SampleItem {
  final String id;
  final String title;
  final String category;
  int remainingDays;
  int totalDays;
  final IconData icon;
  SampleStatus status;

  SampleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.remainingDays,
    required this.totalDays,
    required this.icon,
    this.status = SampleStatus.pendingApproval,
  });

  /// Helper copyWith if needed for immutable updates
  SampleItem copyWith({
    String? id,
    String? title,
    String? category,
    int? remainingDays,
    int? totalDays,
    IconData? icon,
    SampleStatus? status,
  }) {
    return SampleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      remainingDays: remainingDays ?? this.remainingDays,
      totalDays: totalDays ?? this.totalDays,
      icon: icon ?? this.icon,
      status: status ?? this.status,
    );
  }
}
