import 'package:flutter/material.dart';
import 'package:sample_flow/features/samples/data/utils/sample_utils.dart';
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
    IconData? icon,
    this.status = SampleStatus.pendingApproval,
  }) : icon = icon ?? SampleUtils.getCategoryIcon(category);

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'remainingDays': remainingDays,
      'totalDays': totalDays,
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
      icon: SampleUtils.getCategoryIcon(category),
      status: status,
    );
  }
}
