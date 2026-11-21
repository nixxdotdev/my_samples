import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/features/guide/models/guide_step.dart';
import 'package:my_samples/core/constants/app_colors.dart';

class InteractiveTourOverlay extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onDismiss;
  final VoidCallback? onTryAction;

  const InteractiveTourOverlay({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
    required this.onDismiss,
    this.onTryAction,
  });

  static const List<GuideStep> steps = [
    GuideStep(
      stepIndex: 1,
      totalSteps: 6,
      targetTabIndex: 0,
      title: "Today's Analytics",
      section: "Home Screen • Top Overview",
      description: "Track your real-time creator metrics across all 3 lifecycle stages: Pending Approval, Approved Samples, and Posted content.",
      whichButtonToTap: "Tap any of the 3 numbers (Pending, Approved, Posted) to jump straight to that category list in the Samples tab!",
      icon: LucideIcons.barChart3,
      cardAlignment: Alignment.center,
    ),
    GuideStep(
      stepIndex: 2,
      totalSteps: 6,
      targetTabIndex: 0,
      title: "Search & Dues Radar",
      section: "Home Screen • Active Dues",
      description: "Find any product immediately and monitor posting deadlines. Colored rings show urgency: Green (6+ days), Orange (3-5 days), and Red (1-2 days).",
      whatToFill: "Tap the 'Search...' field and type any product name or category (e.g. 'Headphones' or 'Audio'). Tap '✕' to clear.",
      whichButtonToTap: "Tap any sample card in the list to open its full details and lifecycle actions.",
      icon: LucideIcons.search,
      cardAlignment: Alignment.center,
    ),
    GuideStep(
      stepIndex: 3,
      totalSteps: 6,
      targetTabIndex: 0,
      title: "Notification Center",
      section: "Home Screen • Top Header",
      description: "Stay ahead of TikTok Shop compliance deadlines with automatic 5-day, 3-day, and critical 1-day milestone alerts.",
      whichButtonToTap: "Tap the Bell Icon (🔔) in the top-right corner. When open, tap 'Mark all as read' to clear badges, or tap individual alerts.",
      icon: LucideIcons.bell,
      cardAlignment: Alignment.center,
    ),
    GuideStep(
      stepIndex: 4,
      totalSteps: 6,
      targetTabIndex: 1,
      title: "Category Filter Tabs",
      section: "Samples Screen • Top Bar",
      description: "Switch between sample stages to see exactly which items are awaiting merchant approval, in filming progress, or published.",
      whichButtonToTap: "Tap 'Pending Approval', 'Approved Samples', or 'Posted Samples' at the top to filter items instantly.",
      icon: LucideIcons.layers,
      cardAlignment: Alignment.center,
    ),
    GuideStep(
      stepIndex: 5,
      totalSteps: 6,
      targetTabIndex: 1,
      title: "Add New Sample (+)",
      section: "Samples Screen • Floating Action Button",
      description: "Add new creator samples in 2 quick steps: 1) Select the stage, 2) Fill in the details.",
      whatToFill: "Fill in 'Sample Name' (Required), pick a 'Category' from the dropdown, and adjust 'Days Left' using [-]/[+] or preset chips.",
      whichButtonToTap: "Tap the circular Mint/Teal (+) button at the bottom-right, then tap 'Add Sample' when finished.",
      icon: LucideIcons.plusCircle,
      cardAlignment: Alignment.center,
    ),
    GuideStep(
      stepIndex: 6,
      totalSteps: 6,
      targetTabIndex: 1,
      title: "Sample Details & Full Lifecycle",
      section: "Sample Details • Bottom Sheet",
      description: "Progress items through the affiliate workflow. Move pending requests to approved, or mark finished videos as posted.",
      whichButtonToTap: "Tap any sample card ➔ Tap 'Move to Approved Samples' to set deadline days, or tap 'Mark Sample as Posted' when uploaded! Tap the trash can (🗑️) to delete.",
      icon: LucideIcons.sparkles,
      cardAlignment: Alignment.center,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStep < 0 || currentStep >= steps.length) {
      return const SizedBox.shrink();
    }

    final step = steps[currentStep];
    final isLastStep = currentStep == steps.length - 1;

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Guide Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top header: Step badge + Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.footprints,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'INTERACTIVE GUIDE • STEP ${step.stepIndex} OF ${step.totalSteps}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onDismiss,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Skip',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title with Icon
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(step.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.section,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Description
                    Text(
                      step.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guided Box 1: Which Button to Tap
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.mousePointerClick,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WHICH BUTTON TO TAP:',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.whichButtonToTap,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Guided Box 2: What to Fill Up (if applicable)
                    if (step.whatToFill != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pending.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.pending.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.pencil,
                              size: 18,
                              color: AppColors.pending,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WHAT TO FILL UP / TYPE:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: AppColors.pending,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.whatToFill!,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Navigation Actions: Back + Dots + Next/Finish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (currentStep > 0)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            onPressed: onPrevious,
                            icon: const Icon(LucideIcons.arrowLeft, size: 16),
                            label: Text(
                              'Back',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 80),

                        // Step Indicator Dots
                        Row(
                          children: List.generate(step.totalSteps, (dotIdx) {
                            final isActive = dotIdx == currentStep;
                            final isPassed = dotIdx < currentStep;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 18 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : (isPassed
                                          ? AppColors.primaryLight
                                          : AppColors.border),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // Next / Finish Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onPressed: onNext,
                            icon: Icon(
                              isLastStep
                                  ? LucideIcons.check
                                  : LucideIcons.arrowRight,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              isLastStep ? 'Got it!' : 'Next',
                              style: GoogleFonts.dmSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
