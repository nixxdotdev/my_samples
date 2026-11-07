import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sample_flow/core/constants/app_colors.dart';
import 'package:sample_flow/features/samples/data/api/sample_api.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';
import 'package:sample_flow/features/samples/presentation/widgets/sample_detail_bottom_sheet.dart';
import 'package:sample_flow/features/samples/presentation/widgets/sample_filter_tabs.dart';
import 'package:sample_flow/features/samples/presentation/widgets/your_samples_card.dart';

class YourSamplesScreen extends StatefulWidget {
  final int initialStatusIndex;
  final VoidCallback onBackToHome;

  const YourSamplesScreen({
    super.key,
    this.initialStatusIndex = 0,
    required this.onBackToHome,
  });

  @override
  State<YourSamplesScreen> createState() => _YourSamplesScreenState();
}

class _YourSamplesScreenState extends State<YourSamplesScreen> {
  late int _selectedSampleStatusFilter;

  @override
  void initState() {
    super.initState();
    _selectedSampleStatusFilter = widget.initialStatusIndex;
    SampleApi().addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    SampleApi().removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant YourSamplesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatusIndex != widget.initialStatusIndex) {
      _selectedSampleStatusFilter = widget.initialStatusIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = SampleStatus.values[_selectedSampleStatusFilter];
    final samples = SampleApi()
        .getSamples()
        .where((item) => item.status == status)
        .toList();

    return Column(
      children: [
        // Fixed Top Bar & Filter Tabs
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              SampleFilterTabs(
                selectedIndex: _selectedSampleStatusFilter,
                onTabSelected: (index) {
                  setState(() {
                    _selectedSampleStatusFilter = index;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Scrollable List of Your Samples Cards
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await SampleApi().syncWithBackend();
              if (mounted) {
                setState(() {});
              }
            },
            child: samples.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'No samples in this category',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    itemCount: samples.length,
                    itemBuilder: (context, index) {
                      final item = samples[index];
                      return YourSamplesCard(
                        item: item,
                        onTap: () {
                          SampleDetailBottomSheet.show(
                            context,
                            item: item,
                            onStatusChanged: () {
                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        InkWell(
          onTap: widget.onBackToHome,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        // Centered Title
        Expanded(
          child: Text(
            'Your Samples',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}
