import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sample_flow/core/constants/app_colors.dart';
import 'package:sample_flow/features/samples/data/models/notification_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_item.dart';
import 'package:sample_flow/features/samples/data/models/sample_status.dart';

/// Temporary in-memory API & mock data store.
/// This houses the hardcoded samples and notifications before backend integration.
class SampleApi {
  // Singleton pattern for seamless state sharing across presentation widgets
  static final SampleApi _instance = SampleApi._internal();
  factory SampleApi() => _instance;
  SampleApi._internal();

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      title: 'Sample Review Due in 2 Days!',
      description:
          'Your video post for Wireless ANC Headphones is due before Oct 12, 11:59 PM.',
      timeAgo: '25m ago',
      icon: LucideIcons.alertCircle,
      iconColor: AppColors.critical,
      iconBgColor: AppColors.critical.withValues(alpha: 0.12),
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Sample Request Approved',
      description:
          'Merchant approved your request for Hydrating Peptide Glow Serum. Delivery in progress.',
      timeAgo: '2h ago',
      icon: LucideIcons.checkCircle,
      iconColor: AppColors.approved,
      iconBgColor: AppColors.approved.withValues(alpha: 0.12),
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Sample Package Dispatched',
      description:
          'Custom Mechanical Keyboard has shipped via J&T Express (Tracking #TK-98421).',
      timeAgo: '5h ago',
      icon: LucideIcons.package,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.primary.withValues(alpha: 0.12),
      isRead: false,
    ),
    NotificationItem(
      id: 'n4',
      title: 'Posting Criteria Guidelines',
      description:
          'Please ensure the official TikTok Shop product anchor tag is linked in your video caption.',
      timeAgo: '1d ago',
      icon: LucideIcons.fileText,
      iconColor: AppColors.pending,
      iconBgColor: AppColors.pending.withValues(alpha: 0.12),
      isRead: true,
    ),
    NotificationItem(
      id: 'n5',
      title: 'New Brand Collaboration Offer',
      description:
          'A brand invited you to request a free Creator Magnetic Ring Light sample.',
      timeAgo: '2d ago',
      icon: LucideIcons.sparkles,
      iconColor: AppColors.primaryLight,
      iconBgColor: AppColors.primaryLight.withValues(alpha: 0.15),
      isRead: true,
    ),
  ];

  final List<SampleItem> _samples = [
    // 1. Pending Approval
    SampleItem(
      id: '1',
      title: 'Wireless ANC Noise-Cancelling Headphones',
      category: 'Electronics & Audio',
      remainingDays: 0,
      totalDays: 0,
      icon: LucideIcons.headphones,
      status: SampleStatus.pendingApproval,
    ),
    SampleItem(
      id: '2',
      title: 'Hydrating Peptide Glow Serum & Mist',
      category: 'Beauty & Skincare',
      remainingDays: 0,
      totalDays: 0,
      icon: LucideIcons.sparkles,
      status: SampleStatus.pendingApproval,
    ),
    SampleItem(
      id: '3',
      title: 'Oversized Heavyweight Vintage Boxy Tee',
      category: 'Apparel & Fashion',
      remainingDays: 0,
      totalDays: 0,
      icon: LucideIcons.shirt,
      status: SampleStatus.pendingApproval,
    ),
    SampleItem(
      id: '4',
      title: 'Portable Cold Brew & Espresso Tumbler Maker',
      category: 'Home & Kitchen',
      remainingDays: 0,
      totalDays: 0,
      icon: LucideIcons.coffee,
      status: SampleStatus.pendingApproval,
    ),

    // 2. Approved Samples
    SampleItem(
      id: '5',
      title: 'Smart Health & Sleep Tracker Fitness Band',
      category: 'Gadgets & Fitness',
      remainingDays: 5,
      totalDays: 14,
      icon: LucideIcons.watch,
      status: SampleStatus.approved,
    ),
    SampleItem(
      id: '6',
      title: 'Custom Hot-Swappable Mechanical Keyboard',
      category: 'Computer & Office',
      remainingDays: 7,
      totalDays: 14,
      icon: LucideIcons.keyboard,
      status: SampleStatus.approved,
    ),
    SampleItem(
      id: '7',
      title: 'Vitamin C Brightening Daily Cleanser Foam',
      category: 'Personal Care',
      remainingDays: 8,
      totalDays: 14,
      icon: LucideIcons.droplets,
      status: SampleStatus.approved,
    ),
    SampleItem(
      id: '8',
      title: 'Creator Magnetic Ring Light & Tripod Stand',
      category: 'Creator Studio Gear',
      remainingDays: 10,
      totalDays: 14,
      icon: LucideIcons.camera,
      status: SampleStatus.approved,
    ),

    // 3. Pending Criteria / Posted
    SampleItem(
      id: '9',
      title: 'Minimalist RFID Slim Leather Card Wallet',
      category: 'Accessories & Travel',
      remainingDays: 12,
      totalDays: 14,
      icon: LucideIcons.wallet,
      status: SampleStatus.pendingCriteria,
    ),
    SampleItem(
      id: '10',
      title: 'MagSafe Fast Wireless Power Bank 10000mAh',
      category: 'Mobile & Tech',
      remainingDays: 14,
      totalDays: 14,
      icon: LucideIcons.smartphone,
      status: SampleStatus.pendingCriteria,
    ),
    SampleItem(
      id: '11',
      title: 'Matte Ceramic Pour-Over Coffee Dripper',
      category: 'Home & Kitchen',
      remainingDays: 6,
      totalDays: 14,
      icon: LucideIcons.coffee,
      status: SampleStatus.pendingCriteria,
    ),
    SampleItem(
      id: '12',
      title: 'Ergonomic Memory Foam Keyboard Wrist Rest',
      category: 'Computer & Office',
      remainingDays: 9,
      totalDays: 14,
      icon: LucideIcons.keyboard,
      status: SampleStatus.pendingCriteria,
    ),
  ];

  // ================= SAMPLES API =================

  List<SampleItem> getSamples() => _samples;

  void addSample(SampleItem item) {
    _samples.insert(0, item);
  }

  void updateSampleStatus(
    String id,
    SampleStatus status, {
    int? remainingDays,
    int? totalDays,
  }) {
    final index = _samples.indexWhere((item) => item.id == id);
    if (index != -1) {
      _samples[index].status = status;
      if (remainingDays != null) {
        _samples[index].remainingDays = remainingDays;
      }
      if (totalDays != null) {
        _samples[index].totalDays = totalDays;
      }
    }
  }

  int get pendingCount =>
      _samples.where((s) => s.status == SampleStatus.pendingApproval).length;
  int get approvedCount =>
      _samples.where((s) => s.status == SampleStatus.approved).length;
  int get postedCount =>
      _samples.where((s) => s.status == SampleStatus.pendingCriteria).length;

  // ================= NOTIFICATIONS API =================

  List<NotificationItem> getNotifications() => _notifications;

  bool hasUnreadNotifications() =>
      _notifications.any((item) => !item.isRead);

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
    }
  }
}
