import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';

class SetDaysDialog extends StatefulWidget {
  final SampleItem item;

  const SetDaysDialog({super.key, required this.item});

  static Future<int?> show(BuildContext context, SampleItem item) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SetDaysDialog(item: item),
    );
  }

  @override
  State<SetDaysDialog> createState() => _SetDaysDialogState();
}

class _SetDaysDialogState extends State<SetDaysDialog> {
  late int _selectedDays;
  final List<int> _quickPresets = const [3, 5, 7, 10, 14, 21, 30];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.item.remainingDays > 0 ? widget.item.remainingDays : 7;
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = AppColors.getUrgencyColor(_selectedDays);
    String urgencyLabel;
    if (_selectedDays <= 2) {
      urgencyLabel = 'High Urgency (Posting due soon)';
    } else if (_selectedDays <= 5) {
      urgencyLabel = 'Medium Urgency (Moderate schedule)';
    } else {
      urgencyLabel = 'Normal Window (Sufficient preparation)';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Icon
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    LucideIcons.calendar,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Days Left to Post',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Set deadline for approved sample',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),

            // Guided Instruction Banner
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.lightbulb, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HOW TO SET: Use [-]/[+] or click a quick preset below, then tap "Confirm & Move".',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product title preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.item.icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Stepper: [-] [ 7 Days ] [+]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus Button
                InkWell(
                  onTap: _selectedDays > 1
                      ? () {
                          setState(() {
                            _selectedDays--;
                          });
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _selectedDays > 1
                          ? AppColors.surfaceMuted
                          : AppColors.surfaceMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedDays > 1
                            ? AppColors.border
                            : AppColors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.minus,
                      size: 20,
                      color: _selectedDays > 1
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Large Number Counter Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: urgencyColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_selectedDays',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: urgencyColor,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        _selectedDays == 1 ? 'DAY LEFT' : 'DAYS LEFT',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: urgencyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),

                // Plus Button
                InkWell(
                  onTap: _selectedDays < 90
                      ? () {
                          setState(() {
                            _selectedDays++;
                          });
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _selectedDays < 90
                          ? AppColors.surfaceMuted
                          : AppColors.surfaceMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedDays < 90
                            ? AppColors.border
                            : AppColors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.plus,
                      size: 20,
                      color: _selectedDays < 90
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Urgency description badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgencyLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: urgencyColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Presets label
            Text(
              'Quick Presets:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Quick Preset Chips Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickPresets.map((days) {
                final isSelected = _selectedDays == days;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDays = days;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '$days days',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // Action Buttons (Cancel and Confirm)
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm & Move
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF67C090), Color(0xFF4FA878)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.approved.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(context, _selectedDays),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.checkCircle,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm & Move',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
