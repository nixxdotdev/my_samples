import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';

class AnalyticsCard extends StatelessWidget {
  final String pendingCount;
  final String approvedCount;
  final String postedCount;
  final VoidCallback? onHeaderAction;
  final ValueChanged<int>? onSelectStatus;

  const AnalyticsCard({
    super.key,
    required this.pendingCount,
    required this.approvedCount,
    required this.postedCount,
    this.onHeaderAction,
    this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.analyticsGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Title + Arrow icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Analytics",
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: onHeaderAction,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.chevronRight,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 3 Metric columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalyticsMetric(
                number: pendingCount,
                label: 'Pending\nApproval',
                onTap: () => onSelectStatus?.call(0),
              ),
              _buildMetricDivider(),
              _buildAnalyticsMetric(
                number: approvedCount,
                label: 'Approved\nSample',
                onTap: () => onSelectStatus?.call(1),
              ),
              _buildMetricDivider(),
              _buildAnalyticsMetric(
                number: postedCount,
                label: 'Posted\nSample',
                onTap: () => onSelectStatus?.call(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _buildAnalyticsMetric({
    required String number,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
