import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/order_info_card.dart';
import 'widgets/driver_info_card.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        actions: [
          if (orderState.order != null)
            IconButton(
              onPressed: () => _showOrderOptions(context, orderState.order!),
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: _buildBody(context, orderState),
    );
  }

  Widget _buildBody(BuildContext context, OrderState state) {
    if (state.isLoading && state.order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final order = state.order;
    if (order == null) {
      return const Center(child: Text('الطلب غير موجود'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Header
            _buildStatusHeader(context, order),
            const SizedBox(height: 24),

            // Status Timeline
            OrderStatusTimeline(
              currentStatus: order.status,
              statusHistory: order.statusHistory,
            ),
            const SizedBox(height: 24),

            // Driver Info (if assigned)
            if (order.driver != null) ...[
              DriverInfoCard(
                driver: order.driver!,
                onCall: () => _callDriver(order.driver!.phone),
              ),
              const SizedBox(height: 16),
            ],

            // Order Info
            OrderInfoCard(order: order),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, order),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(order.status),
            _getStatusColor(order.status).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(order.status),
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            order.statusDisplayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'رقم الطلب: ${order.orderNumber}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          if (order.estimatedDeliveryTime != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الوقت المتوقع: ${_formatTime(order.estimatedDeliveryTime!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: order.progressPercentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    return Column(
      children: [
        if (order.canCancel) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, order),
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text(
                'إلغاء الطلب',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (order.status == OrderStatus.delivered) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showRatingDialog(context, order),
              icon: const Icon(Icons.star_outline),
              label: const Text('قيّم الطلب'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => context.push(AppRoutes.orders),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('عرض جميع الطلبات'),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.confirmed:
        return AppColors.confirmed;
      case OrderStatus.preparing:
        return AppColors.preparing;
      case OrderStatus.ready:
        return AppColors.ready;
      case OrderStatus.pickedUp:
        return AppColors.pickedUp;
      case OrderStatus.onTheWay:
        return AppColors.onTheWay;
      case OrderStatus.delivered:
        return AppColors.delivered;
      case OrderStatus.cancelled:
        return AppColors.cancelled;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.inventory_2_outlined;
      case OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case OrderStatus.onTheWay:
        return Icons.directions_bike;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _callDriver(String? phone) async {
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showOrderOptions(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('تحديث الحالة'),
              onTap: () {
                Navigator.pop(context);
                ref.read(orderProvider(widget.orderId).notifier).fetchOrder(widget.orderId);
              },
            ),
            if (order.canCancel)
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                title: const Text('إلغاء الطلب', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelDialog(context, order);
                },
              ),
            if (order.status == OrderStatus.delivered)
              ListTile(
                leading: const Icon(Icons.replay, color: AppColors.primary),
                title: const Text('إعادة الطلب'),
                onTap: () {
                  Navigator.pop(context);
                  _reorder(context, order);
                },
              ),
            if (order.status == OrderStatus.delivered && order.restaurant.id.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.star_outline, color: AppColors.rating),
                title: const Text('تقييم الطلب'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.rateOrder.replaceFirst(':id', order.id),
                    extra: {
                      'restaurantName': order.restaurant.name,
                      'driverName': order.driver?.name,
                    },
                  );
                },
              ),
            if (order.restaurant.phone != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('اتصال بالمطعم'),
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse('tel:${order.restaurant.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('الدعم الفني'),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('tel:${AppConstants.supportPhone}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Order order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من إلغاء الطلب؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإلغاء (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(orderProvider(widget.orderId).notifier)
                  .cancelOrder(reasonController.text);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'تم إلغاء الطلب' : 'فشل إلغاء الطلب',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
  }

  Future<void> _reorder(BuildContext context, Order order) async {
    final cart = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // Check if cart has items from different restaurant
    if (cart.isFromDifferentRestaurant(order.restaurant.id)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('استبدال السلة؟'),
          content: const Text(
            'لديك عناصر من مطعم آخر في السلة. هل تريد استبدالها بهذا الطلب؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('استبدال'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Clear cart first
      await cartNotifier.clearCart();
    }

    // Navigate to restaurant page
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يمكنك الآن إضافة نفس العناصر من صفحة المطعم'),
          backgroundColor: AppColors.success,
        ),
      );

      context.push(AppRoutes.restaurant.replaceFirst(':id', order.restaurant.id));
    }
  }

  void _showRatingDialog(BuildContext context, Order order) {
    int rating = 5;
    int deliveryRating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('قيّم تجربتك'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تقييم المطعم:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => rating = index + 1),
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.rating,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                if (order.driver != null) ...[
                  const Text('تقييم التوصيل:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () =>
                            setState(() => deliveryRating = index + 1),
                        icon: Icon(
                          index < deliveryRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.rating,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    labelText: 'اكتب تعليقاً (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(orderProvider(widget.orderId).notifier)
                    .rateOrder(
                      rating: rating,
                      review: reviewController.text.isNotEmpty
                          ? reviewController.text
                          : null,
                      deliveryRating: order.driver != null ? deliveryRating : null,
                    );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'شكراً لتقييمك!'
                            : 'فشل إرسال التقييم',
                      ),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
