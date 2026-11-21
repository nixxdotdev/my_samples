import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/core/network/api_client.dart';
import 'package:my_samples/features/about/presentation/widgets/about_feature_row.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final VoidCallback? onStartGuide;

  const AboutScreen({super.key, this.onStartGuide});

  // ignore: unused_element
  void _showBackendConfigDialog(BuildContext context) {
    final sampleApi = SampleApi();
    final controller = TextEditingController(text: sampleApi.currentBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        bool isChecking = false;
        String? checkResult;
        bool? isSuccess;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    LucideIcons.server,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Backend API URL',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure the REST backend server endpoint for synchronization:',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'http://localhost:3000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(LucideIcons.globe, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('localhost:3000'),
                        onPressed: () {
                          controller.text = 'http://localhost:3000';
                        },
                      ),
                      ActionChip(
                        label: const Text('10.0.2.2:3000 (Android)'),
                        onPressed: () {
                          controller.text = 'http://10.0.2.2:3000';
                        },
                      ),
                    ],
                  ),
                  if (checkResult != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          isSuccess == true
                              ? LucideIcons.checkCircle
                              : LucideIcons.alertCircle,
                          size: 16,
                          color: isSuccess == true
                              ? AppColors.approved
                              : AppColors.critical,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkResult!,
                            style: GoogleFonts.dmSans(
                              fontSize: 12.5,
                              color: isSuccess == true
                                  ? AppColors.approved
                                  : AppColors.critical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isChecking
                      ? null
                      : () async {
                          setDialogState(() {
                            isChecking = true;
                            checkResult = 'Testing connection...';
                            isSuccess = null;
                          });
                          final trimmedUrl = controller.text.trim();
                          ApiClient().updateBaseUrl(trimmedUrl);
                          final ok = await ApiClient().checkHealth();
                          setDialogState(() {
                            isChecking = false;
                            isSuccess = ok;
                            checkResult = ok
                                ? 'Server reachable & online!'
                                : 'Cannot reach server at this address.';
                          });
                        },
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final trimmed = controller.text.trim();
                    if (trimmed.isNotEmpty) {
                      await sampleApi.updateBackendUrl(trimmed);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Backend URL updated: $trimmed'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Save & Sync',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchPortfolioUrl(BuildContext context) async {
    final Uri url = Uri.parse('https://nixxdotdev.vercel.app');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open https://nixxdotdev.vercel.app'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open portfolio URL'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Floating App Logo
          SizedBox(
            width: 130,
            height: 130,
            child: Image.asset(
              'assets/logo/sf_logo_v1.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 16),
          // App Name
          Text(
            'MySample',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            'Affiliator Sample Tracker',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Version & Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'v0.1.0 • Beta Preview',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About MySample',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'MySample is designed specifically for TikTok Shop Creators & Affiliates. It streamlines the lifecycle of free product samples from request to post, preventing missed video deadlines and keeping your Creator Score in top standing.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive UI Walkthrough Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.compass,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real-Time UI Walkthrough',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Follow an interactive on-screen guide of all buttons & forms',
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onStartGuide,
                    icon: const Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Start Real-Time Walkthrough',
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
          ),
          const SizedBox(height: 16),

          // Core Features Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Core Highlights',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                const AboutFeatureRow(
                  icon: LucideIcons.clock,
                  iconColor: AppColors.critical,
                  title: 'Deadline Urgency Radar',
                  description: 'Color-coded urgency alerts (Critical <= 2 days, Warning 3-5 days, Safe 6+ days).',
                ),
                const SizedBox(height: 12),
                const AboutFeatureRow(
                  icon: LucideIcons.checkCircle,
                  iconColor: AppColors.approved,
                  title: '3-Stage Sample Lifecycle',
                  description: 'Track items seamlessly across Pending Approval, Approved Samples, and Posted content.',
                ),
                const SizedBox(height: 12),
                const AboutFeatureRow(
                  icon: LucideIcons.bell,
                  iconColor: AppColors.primary,
                  title: 'Smart Notification Hub',
                  description: 'Instant status updates for merchant approvals, package tracking, and posting criteria.',
                ),
                const SizedBox(height: 12),
                const AboutFeatureRow(
                  icon: LucideIcons.fileText,
                  iconColor: AppColors.posting,
                  title: 'Creator Compliance',
                  description: 'Never lose affiliate sample privileges due to overdue or unposted product reviews.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Footer: Clickable portfolio link
          InkWell(
            onTap: () => _launchPortfolioUrl(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Developed by ',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'nixxdotdev',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    LucideIcons.externalLink,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
