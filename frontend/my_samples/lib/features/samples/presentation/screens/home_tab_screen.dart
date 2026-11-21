import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/notifications/presentation/widgets/notifications_bottom_sheet.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';
import 'package:my_samples/features/samples/presentation/widgets/analytics_card.dart';
import 'package:my_samples/features/samples/presentation/widgets/sample_card.dart';
import 'package:my_samples/features/samples/presentation/widgets/sample_detail_bottom_sheet.dart';

class HomeTabScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToSamplesWithStatus;
  final VoidCallback onNavigateToSamples;
  final VoidCallback? onStartGuide;

  const HomeTabScreen({
    super.key,
    required this.onNavigateToSamplesWithStatus,
    required this.onNavigateToSamples,
    this.onStartGuide,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
  }

  List<SampleItem> _getFilteredSamples() {
    final allSamples = SampleApi().getSamples();
    final activeSamples = allSamples
        .where(
          (item) =>
              item.status != SampleStatus.pendingApproval &&
              item.status != SampleStatus.pendingCriteria,
        )
        .toList();

    if (_searchQuery.trim().isEmpty) {
      return activeSamples;
    }
    return activeSamples
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sampleApi = SampleApi();
    final hasUnread = sampleApi.hasUnreadNotifications();
    final filteredSamples = _getFilteredSamples();

    return Column(
      children: [
        // Fixed Top Section
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, hasUnread),
              const SizedBox(height: 18),
              AnalyticsCard(
                pendingCount: '${sampleApi.pendingCount}',
                approvedCount: '${sampleApi.approvedCount}',
                postedCount: '${sampleApi.postedCount}',
                onHeaderAction: widget.onNavigateToSamples,
                onSelectStatus: widget.onNavigateToSamplesWithStatus,
              ),
              const SizedBox(height: 20),
              _buildListHeaderAndSearch(),
              const SizedBox(height: 14),
            ],
          ),
        ),

        // Scrollable List of Sample Dues
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await SampleApi().syncWithBackend();
              if (mounted) {
                setState(() {});
              }
            },
            child: filteredSamples.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            _searchQuery.trim().isNotEmpty
                                ? 'No samples match "$_searchQuery"'
                                : 'No sample dues available',
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
                    itemCount: filteredSamples.length,
                    itemBuilder: (context, index) {
                      final item = filteredSamples[index];
                      return SampleCard(
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

  Widget _buildHeader(BuildContext context, bool hasUnread) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Image.asset(
                    'assets/logo/sf_logo_v1.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.critical,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              'MySample',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        // Action buttons: Guide button + Notification bell with badge dot
        Row(
          children: [
            // Interactive Guided Tour Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onStartGuide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.circleQuestionMark,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Guide',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Notification bell with badge dot
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      NotificationsBottomSheet.show(
                        context,
                        onUpdated: () => setState(() {}),
                      );
                    },
                    icon: const Icon(
                      LucideIcons.bell,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    tooltip: 'Notifications',
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.critical,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListHeaderAndSearch() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            'List of Sample Dues',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search Box
        Expanded(
          flex: 5,
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 38,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            LucideIcons.x,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 26,
                  minHeight: 38,
                ),
                contentPadding: const EdgeInsets.only(right: 8),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
