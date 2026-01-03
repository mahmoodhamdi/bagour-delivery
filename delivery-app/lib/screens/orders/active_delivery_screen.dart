import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';

class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final String? orderId;

  const ActiveDeliveryScreen({super.key, this.orderId});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() =>
      _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    await ref.read(currentOrderProvider.notifier).fetchCurrentOrder();
  }

  Future<void> _pickUpOrder() async {
    setState(() => _isUpdatingStatus = true);

    final confirmed = await _showConfirmationDialog(
      title: 'تأكيد الاستلام',
      message: 'هل قمت باستلام الطلب من المطعم؟',
      confirmLabel: 'نعم، تم الاستلام',
    );

    if (!confirmed) {
      setState(() => _isUpdatingStatus = false);
      return;
    }

    final success = await ref.read(currentOrderProvider.notifier).pickUpOrder();

    setState(() => _isUpdatingStatus = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد استلام الطلب'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في تحديث الحالة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _startDelivery() async {
    setState(() => _isUpdatingStatus = true);

    final success = await ref.read(currentOrderProvider.notifier).startDelivery();

    setState(() => _isUpdatingStatus = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بدء التوصيل'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في تحديث الحالة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _completeDelivery() async {
    setState(() => _isUpdatingStatus = true);

    final confirmed = await _showConfirmationDialog(
      title: 'تأكيد التوصيل',
      message: 'هل قمت بتسليم الطلب للعميل؟',
      confirmLabel: 'نعم، تم التسليم',
    );

    if (!confirmed) {
      setState(() => _isUpdatingStatus = false);
      return;
    }

    final order = ref.read(currentOrderProvider).order;
    final success = await ref.read(currentOrderProvider.notifier).completeDelivery();

    setState(() => _isUpdatingStatus = false);

    if (success && mounted) {
      _showDeliveryCompleteDialog(order!);
    } else if (mounted) {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في تحديث الحالة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDeliveryCompleteDialog(DriverOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تم التوصيل بنجاح!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'طلب #${order.orderNumber}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payments, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'أرباحك: ${order.totalEarnings.toStringAsFixed(0)} ج.م',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.home);
              },
              child: const Text('العودة للرئيسية'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(currentOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلب النشط'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: _buildBody(orderState),
    );
  }

  Widget _buildBody(CurrentOrderState state) {
    if (state.isLoading && state.order == null) {
      return const LoadingIndicator(message: 'جاري تحميل الطلب...');
    }

    if (state.error != null && state.order == null) {
      return ErrorState(
        message: state.error!,
        onRetry: _loadOrder,
      );
    }

    if (state.order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلب نشط',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك قبول طلب جديد من قائمة الطلبات المتاحة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('عرض الطلبات المتاحة'),
            ),
          ],
        ),
      );
    }

    return _buildOrderContent(state.order!);
  }

  Widget _buildOrderContent(DriverOrder order) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // Status Progress
              _buildStatusProgress(order),

              // Order Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current Action Card
                    _buildCurrentActionCard(order),
                    const SizedBox(height: 16),

                    // Restaurant Card
                    if (order.status == OrderStatus.ready)
                      _buildLocationCard(
                        title: 'المطعم',
                        name: order.restaurant.displayName,
                        address: order.restaurant.address,
                        phone: order.restaurant.phone,
                        lat: order.restaurant.latitude,
                        lng: order.restaurant.longitude,
                        icon: Icons.restaurant,
                        iconColor: AppColors.primary,
                      ),

                    // Customer Card
                    if (order.status == OrderStatus.pickedUp ||
                        order.status == OrderStatus.onTheWay)
                      _buildLocationCard(
                        title: 'العميل',
                        name: order.deliveryAddress.name,
                        address: order.deliveryAddress.fullAddress,
                        phone: order.customer.phone,
                        lat: order.deliveryAddress.latitude,
                        lng: order.deliveryAddress.longitude,
                        icon: Icons.location_on,
                        iconColor: AppColors.secondary,
                        landmark: order.deliveryAddress.landmark,
                      ),

                    const SizedBox(height: 16),

                    // Order Details Card
                    _buildOrderDetailsCard(order),
                    const SizedBox(height: 16),

                    // Items Card
                    _buildItemsCard(order),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Button
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildActionButton(order),
        ),

        // Loading overlay
        if (_isUpdatingStatus)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const LoadingIndicator(message: 'جاري التحديث...'),
          ),
      ],
    );
  }

  Widget _buildStatusProgress(DriverOrder order) {
    final statuses = [
      OrderStatus.ready,
      OrderStatus.pickedUp,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final currentIndex = statuses.indexOf(order.status);

    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(statuses.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final lineIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 3,
                color: lineIndex < currentIndex
                    ? AppColors.success
                    : AppColors.grey300,
              ),
            );
          }

          // Status dot
          final statusIndex = index ~/ 2;
          final isCompleted = statusIndex < currentIndex;
          final isCurrent = statusIndex == currentIndex;

          return _buildStatusDot(
            status: statuses[statusIndex],
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          );
        }),
      ),
    );
  }

  Widget _buildStatusDot({
    required OrderStatus status,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    String label;
    switch (status) {
      case OrderStatus.ready:
        label = 'جاهز';
        break;
      case OrderStatus.pickedUp:
        label = 'استلام';
        break;
      case OrderStatus.onTheWay:
        label = 'في الطريق';
        break;
      case OrderStatus.delivered:
        label = 'تسليم';
        break;
      default:
        label = '';
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? AppColors.success
                : AppColors.grey300,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.success, width: 3)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentActionCard(DriverOrder order) {
    String title;
    String subtitle;
    IconData icon;
    Color color;

    switch (order.status) {
      case OrderStatus.ready:
        title = 'توجه للمطعم';
        subtitle = 'استلم الطلب من ${order.restaurant.displayName}';
        icon = Icons.restaurant;
        color = AppColors.primary;
        break;
      case OrderStatus.pickedUp:
        title = 'ابدأ التوصيل';
        subtitle = 'توجه لعنوان العميل';
        icon = Icons.directions_bike;
        color = AppColors.warning;
        break;
      case OrderStatus.onTheWay:
        title = 'في الطريق للعميل';
        subtitle = 'أوشكت على الوصول';
        icon = Icons.delivery_dining;
        color = AppColors.success;
        break;
      default:
        title = 'طلب نشط';
        subtitle = order.statusDisplayName;
        icon = Icons.receipt_long;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String name,
    required String address,
    required String phone,
    required double lat,
    required double lng,
    required IconData icon,
    required Color iconColor,
    String? landmark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (landmark != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        landmark,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchCall(phone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchNavigation(lat, lng),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('الاتجاهات'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(DriverOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('رقم الطلب', '#${order.orderNumber}'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'طريقة الدفع',
              order.paymentMethodDisplayName,
              icon: order.paymentMethod == PaymentMethod.cash
                  ? Icons.payments
                  : Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'إجمالي الطلب',
              '${order.total.toStringAsFixed(0)} ج.م',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'أرباحك',
              '${order.totalEarnings.toStringAsFixed(0)} ج.م',
              valueColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsCard(DriverOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'العناصر (${order.totalItems})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}×',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(DriverOrder order) {
    String label;
    VoidCallback? onPressed;
    Color color;

    switch (order.status) {
      case OrderStatus.ready:
        label = 'تأكيد الاستلام من المطعم';
        onPressed = _pickUpOrder;
        color = AppColors.primary;
        break;
      case OrderStatus.pickedUp:
        label = 'بدء التوصيل';
        onPressed = _startDelivery;
        color = AppColors.warning;
        break;
      case OrderStatus.onTheWay:
        label = 'تأكيد التسليم للعميل';
        onPressed = _completeDelivery;
        color = AppColors.success;
        break;
      default:
        label = 'تحديث الحالة';
        onPressed = null;
        color = AppColors.grey500;
    }

    return SafeArea(
      child: ElevatedButton(
        onPressed: _isUpdatingStatus ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isUpdatingStatus
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
