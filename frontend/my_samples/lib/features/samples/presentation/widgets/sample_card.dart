import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';

class SampleCard extends StatelessWidget {
  final SampleItem item;
  final VoidCallback onTap;

  const SampleCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color urgencyColor = AppColors.getUrgencyColor(item.remainingDays);
    final double progress = item.totalDays > 0
        ? (item.remainingDays / item.totalDays).clamp(0.05, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Product Thumbnail Placeholder
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primary.withValues(alpha: 0.75),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                // Product Name and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category,
                              style: GoogleFonts.dmSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Remaining Days Indicator (Approved Samples only)
                if (item.status == SampleStatus.approved)
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Track
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              urgencyColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        // Dynamic Urgency Progress Arc
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              urgencyColor,
                            ),
                          ),
                        ),
                        // Center Numbers & Label
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${item.remainingDays}',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: urgencyColor,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Days Left',
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (item.status == SampleStatus.pendingApproval
                                  ? AppColors.pending
                                  : AppColors.posting)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status == SampleStatus.pendingApproval
                          ? 'Pending'
                          : 'Posted',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: item.status == SampleStatus.pendingApproval
                            ? AppColors.pending
                            : AppColors.posting,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
