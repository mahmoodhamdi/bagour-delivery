import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final hasMore = ref.read(notificationsHasMoreProvider);
      final isLoading = ref.read(notificationsLoadingProvider);
      if (hasMore && !isLoading) {
        ref.read(notificationProvider.notifier).loadMore();
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_order':
        return Icons.shopping_bag_outlined;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      case 'order_confirmed':
        return Icons.check_circle_outline;
      case 'order_ready':
        return Icons.restaurant_outlined;
      case 'order_delivered':
        return Icons.delivery_dining_outlined;
      case 'review':
        return Icons.star_outline;
      case 'payment':
      case 'payout':
        return Icons.payment_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_order':
        return AppColors.success;
      case 'order_cancelled':
        return AppColors.error;
      case 'order_confirmed':
        return AppColors.info;
      case 'order_ready':
        return AppColors.statusReady;
      case 'order_delivered':
        return AppColors.statusDelivered;
      case 'review':
        return AppColors.rating;
      case 'payment':
      case 'payout':
        return AppColors.info;
      case 'promotion':
        return AppColors.tertiary;
      case 'system':
        return AppColors.grey600;
      default:
        return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks أسبوع';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read first
    if (!notification.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.orderId != null) {
      context.push('/orders/${notification.orderId}');
    } else if (notification.type == 'review') {
      context.push('/reviews');
    } else if (notification.type == 'payment' || notification.type == 'payout') {
      context.push('/earnings');
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    await ref.read(notificationProvider.notifier).deleteNotification(notification.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الإشعار'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final isLoading = notificationState.isLoading;
    final error = notificationState.error;
    final hasMore = notificationState.hasMore;
    final unreadCount = notificationState.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty && unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('قراءة الكل'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
              ),
            ),
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  ref.read(notificationProvider.notifier).markAllAsRead();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 12),
                      Text('تحديد الكل كمقروء'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading && notifications.isEmpty
          ? const LoadingWidget()
          : error != null && notifications.isEmpty
              ? CustomErrorWidget(
                  message: error,
                  onRetry: () {
                    ref.read(notificationProvider.notifier).fetchNotifications(refresh: true);
                  },
                )
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(notificationProvider.notifier).fetchNotifications(refresh: true);
                      },
                      child: Column(
                        children: [
                          // Unread count banner
                          if (unreadCount > 0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: AppRadius.radiusFull,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'إشعارات غير مقروءة',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Notifications list
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: notifications.length + (hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == notifications.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final notification = notifications[index];
                                final showDateHeader = index == 0 ||
                                    !_isSameDay(
                                      notification.createdAt,
                                      notifications[index - 1].createdAt,
                                    );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDateHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                        child: Text(
                                          _getDateHeader(notification.createdAt),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    _buildNotificationItem(notification),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'اليوم';
    } else if (notificationDate == yesterday) {
      return 'أمس';
    } else {
      return _formatDate(date);
    }
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.notifications_off_outlined,
      title: 'لا توجد إشعارات',
      message: 'سنقوم بإعلامك عند وصول طلبات جديدة أو تحديثات مهمة',
      actionLabel: 'تحديث',
      onAction: () {
        ref.read(notificationProvider.notifier).fetchNotifications(refresh: true);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final type = notification.type;
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.error,
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف الإشعار'),
            content: const Text('هل أنت متأكد من حذف هذا الإشعار؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? null : AppColors.primary.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(type).withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    _getNotificationIcon(type),
                    color: _getNotificationColor(type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.titleAr.isNotEmpty
                                  ? notification.titleAr
                                  : notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.bodyAr.isNotEmpty
                            ? notification.bodyAr
                            : notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(type).withValues(alpha: 0.1),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              _getNotificationTypeLabel(type),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getNotificationColor(type),
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
      ),
    );
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'new_order':
        return 'طلب جديد';
      case 'order_cancelled':
        return 'طلب ملغى';
      case 'order_confirmed':
        return 'تأكيد طلب';
      case 'order_ready':
        return 'طلب جاهز';
      case 'order_delivered':
        return 'تم التوصيل';
      case 'review':
        return 'تقييم';
      case 'payment':
        return 'دفع';
      case 'payout':
        return 'تحويل';
      case 'promotion':
        return 'عرض';
      case 'system':
        return 'نظام';
      default:
        return 'إشعار';
    }
  }
}
