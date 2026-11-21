import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_samples/core/constants/app_colors.dart';
import 'package:my_samples/features/samples/data/api/sample_api.dart';
import 'package:my_samples/features/samples/data/models/sample_item.dart';
import 'package:my_samples/features/samples/data/models/sample_status.dart';
import 'package:my_samples/features/samples/data/utils/sample_utils.dart';

class AddSampleBottomSheet extends StatefulWidget {
  final ValueChanged<SampleItem> onSampleAdded;

  const AddSampleBottomSheet({super.key, required this.onSampleAdded});

  static void show(
    BuildContext context, {
    required ValueChanged<SampleItem> onSampleAdded,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSampleBottomSheet(onSampleAdded: onSampleAdded),
    );
  }

  @override
  State<AddSampleBottomSheet> createState() => _AddSampleBottomSheetState();
}

class _AddSampleBottomSheetState extends State<AddSampleBottomSheet> {
  SampleStatus? _selectedStatus;
  final _nameController = TextEditingController();
  String _selectedCategory = 'Electronics & Audio';
  int _selectedDays = 7;
  final _formKey = GlobalKey<FormState>();
  final List<int> _quickPresets = const [3, 5, 7, 10, 14, 21, 30];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _selectedStatus != null
        ? SampleUtils.getSampleStatusColor(_selectedStatus!)
        : AppColors.primary;
    final urgencyColor = AppColors.getUrgencyColor(_selectedDays);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _selectedStatus != null
                              ? Tooltip(
                                  message: 'Back to selection',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        setState(() {
                                          _selectedStatus = null;
                                        });
                                      },
                                      child: Icon(
                                        LucideIcons.arrowLeft,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  LucideIcons.helpCircle,
                                  color: statusColor,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedStatus == null
                              ? 'Select Sample Status'
                              : 'Add New Sample',
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        LucideIcons.x,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),

              // Body Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: _selectedStatus == null
                      // Step 1: Select which status of sample to add
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Guided Banner for Step 1
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.mousePointerClick,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "STEP 1 OF 2: Tap the card below matching your sample's stage.",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'What status of sample would you like to add?',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStatusChoiceTile(
                              title: 'Pending Approval',
                              subtitle: 'Sample requested, waiting for merchant approval',
                              icon: LucideIcons.clock,
                              color: AppColors.pending,
                              onTap: () {
                                setState(() {
                                  _selectedStatus =
                                      SampleStatus.pendingApproval;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildStatusChoiceTile(
                              title: 'Approved Samples',
                              subtitle: 'Sample approved, set days left to post video',
                              icon: LucideIcons.checkCircle,
                              color: AppColors.approved,
                              onTap: () {
                                setState(() {
                                  _selectedStatus = SampleStatus.approved;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildStatusChoiceTile(
                              title: 'Posted Samples',
                              subtitle:
                                  'Sample content has already been posted',
                              icon: LucideIcons.stickyNoteCheck,
                              color: AppColors.posting,
                              onTap: () {
                                setState(() {
                                  _selectedStatus =
                                      SampleStatus.pendingCriteria;
                                });
                              },
                            ),
                          ],
                        )
                      // Step 2: Form with Sample Name, Category, Days Left (if approved)
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Selected status banner with "Change" button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Adding to: ${_selectedStatus!.label}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedStatus = null;
                                        });
                                      },
                                      child: Text(
                                        'Change Status',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Guided Banner for Step 2
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 14,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.pencilLine,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'STEP 2 OF 2: Fill in the product details and deadline below.',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Field 1: Sample Name
                              Row(
                                children: [
                                  Text(
                                    '1. Sample Name',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'TYPE HERE (REQUIRED)',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter the sample name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'e.g. Wireless ANC Noise-Cancelling Headphones',
                                  hintStyle: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                  prefixIcon: const Icon(
                                    LucideIcons.package,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Field 2: Category (Dropdown)
                              Row(
                                children: [
                                  Text(
                                    '2. Category',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'CHOOSE FROM 10 CATEGORIES',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    SampleUtils.getCategoryIcon(
                                      _selectedCategory,
                                    ),
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                items: SampleUtils.categories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat),
                                  );
                                }).toList(),
                                onChanged: (cat) {
                                  if (cat != null) {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  }
                                },
                              ),

                              // Field 3: Days Left (Show ONLY if user chooses Approved Samples)
                              if (_selectedStatus == SampleStatus.approved) ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text(
                                      '3. Days Left to Post',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: urgencyColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ADJUST [-] [+] OR PRESETS',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: urgencyColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Set countdown days for creator to post this approved sample',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Stepper [-] [ 7 Days ] [+]
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: _selectedDays > 1
                                          ? () {
                                              setState(() {
                                                _selectedDays--;
                                              });
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _selectedDays > 1
                                              ? AppColors.surfaceMuted
                                              : AppColors.surfaceMuted
                                                    .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _selectedDays > 1
                                                ? AppColors.border
                                                : AppColors.border.withValues(
                                                    alpha: 0.4,
                                                  ),
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.minus,
                                          size: 18,
                                          color: _selectedDays > 1
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: urgencyColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: urgencyColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$_selectedDays',
                                            style: GoogleFonts.outfit(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w800,
                                              color: urgencyColor,
                                              height: 1.1,
                                            ),
                                          ),
                                          Text(
                                            _selectedDays == 1
                                                ? 'DAY LEFT'
                                                : 'DAYS LEFT',
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
                                    const SizedBox(width: 16),
                                    InkWell(
                                      onTap: _selectedDays < 90
                                          ? () {
                                              setState(() {
                                                _selectedDays++;
                                              });
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _selectedDays < 90
                                              ? AppColors.surfaceMuted
                                              : AppColors.surfaceMuted
                                                    .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _selectedDays < 90
                                                ? AppColors.border
                                                : AppColors.border.withValues(
                                                    alpha: 0.4,
                                                  ),
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.plus,
                                          size: 18,
                                          color: _selectedDays < 90
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Quick Presets
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: _quickPresets.map((days) {
                                    final isSelected = _selectedDays == days;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDays = days;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          '$days d',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11.5,
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
                              ],
                              const SizedBox(height: 26),

                              // Submit Button
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryLight,
                                      AppColors.primary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        final newSample = SampleItem(
                                          id:
                                              (DateTime.now()
                                                          .millisecondsSinceEpoch %
                                                      10000)
                                                  .toString(),
                                          title: _nameController.text.trim(),
                                          category: _selectedCategory,
                                          remainingDays:
                                              _selectedStatus ==
                                                  SampleStatus.approved
                                              ? _selectedDays
                                              : 0,
                                          totalDays:
                                              _selectedStatus ==
                                                  SampleStatus.approved
                                              ? _selectedDays
                                              : 0,
                                          icon: SampleUtils.getCategoryIcon(
                                            _selectedCategory,
                                          ),
                                          status: _selectedStatus!,
                                        );

                                        Navigator.pop(context);
                                        SampleApi().addSample(newSample);
                                        widget.onSampleAdded(newSample);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                SampleUtils.getSampleStatusColor(
                                                  _selectedStatus!,
                                                ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  LucideIcons.checkCircle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Added "${newSample.title}" to ${_selectedStatus!.label}!',
                                                    style: GoogleFonts.dmSans(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            LucideIcons.plus,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Add Sample',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
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
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChoiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
