import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';

class SampleFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const SampleFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      SampleStatus.pendingApproval,
      SampleStatus.approved,
      SampleStatus.pendingCriteria,
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Subtle base divider track
        Container(
          height: 1.5,
          width: double.infinity,
          color: AppColors.border.withValues(alpha: 0.5),
        ),
        // Responsive, shrinkable tabs
        Row(
          children: List.generate(tabs.length, (index) {
            final status = tabs[index];
            final bool isSelected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            status.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.5,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          widthFactor: isSelected ? 1.0 : 0.0,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
