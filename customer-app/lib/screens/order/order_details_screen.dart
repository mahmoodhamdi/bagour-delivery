import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/driver_info_card.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        actions: [
          if (orderState.order != null)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, orderState.order!),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('تحديث'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (orderState.order!.canCancel)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined, color: AppColors.error),
                      title: Text('إلغاء الطلب', style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'support',
                  child: ListTile(
                    leading: Icon(Icons.support_agent),
                    title: Text('الدعم الفني'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (!orderState.order!.isActive)
                  const PopupMenuItem(
                    value: 'issue',
                    child: ListTile(
                      leading: Icon(Icons.report_problem_outlined),
                      title: Text('الإبلاغ عن مشكلة'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
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
        child: Padding(
          padding: const EdgeInsets.all(32),
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
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(orderProvider(widget.orderId).notifier)
                    .fetchOrder(widget.orderId),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final order = state.order;
    if (order == null) {
      return const Center(child: Text('الطلب غير موجود'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(orderProvider(widget.orderId).notifier)
            .fetchOrder(widget.orderId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Header
            _buildStatusCard(context, order),
            const SizedBox(height: 20),

            // Status Timeline (for active orders)
            if (order.isActive) ...[
              OrderStatusTimeline(
                currentStatus: order.status,
                statusHistory: order.statusHistory,
              ),
              const SizedBox(height: 20),
            ],

            // Driver Info (if assigned)
            if (order.driver != null) ...[
              DriverInfoCard(
                driver: order.driver!,
                onCall: () => _callPhone(order.driver!.phone),
              ),
              const SizedBox(height: 20),
            ],

            // Restaurant Info
            _buildRestaurantCard(context, order),
            const SizedBox(height: 20),

            // Order Items
            _buildItemsCard(context, order),
            const SizedBox(height: 20),

            // Delivery Address
            _buildAddressCard(context, order),
            const SizedBox(height: 20),

            // Payment Info
            _buildPaymentCard(context, order),
            const SizedBox(height: 20),

            // Order Summary
            _buildSummaryCard(context, order),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, order),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Order order) {
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
          const SizedBox(height: 8),
          Text(
            _formatDateTime(order.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
          if (order.estimatedDeliveryTime != null && order.isActive) ...[
            const SizedBox(height: 12),
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
                    'الوصول المتوقع: ${_formatTime(order.estimatedDeliveryTime!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
          if (order.isActive) ...[
            const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'المطعم',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: order.restaurant.logo != null
                    ? CachedNetworkImage(
                        imageUrl: order.restaurant.logo!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildRestaurantPlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildRestaurantPlaceholder(),
                      )
                    : _buildRestaurantPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (order.restaurant.phone != null) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _callPhone(order.restaurant.phone),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.restaurant.phone!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (order.restaurant.phone != null)
                IconButton.filled(
                  onPressed: () => _callPhone(order.restaurant.phone),
                  icon: const Icon(Icons.phone),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.background,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'تفاصيل الطلب',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.totalItems} عنصر',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return _buildOrderItem(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity Badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Item Image
        if (item.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.image!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: AppColors.background,
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: AppColors.background,
                child: const Icon(Icons.fastfood, color: AppColors.textHint),
              ),
            ),
          ),
        if (item.image != null) const SizedBox(width: 12),
        // Item Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (item.variations.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: item.variations.map((v) {
                    return Text(
                      '${v.nameAr ?? v.name}: ${v.optionAr ?? v.option}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    );
                  }).toList(),
                ),
              ],
              if (item.addons.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: item.addons.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+ ${a.nameAr ?? a.name}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (item.specialInstructions != null &&
                  item.specialInstructions!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.notes,
                      size: 12,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.specialInstructions!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Price
        Text(
          '${item.total.toStringAsFixed(2)} ج.م',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'عنوان التوصيل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home,
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
                      order.deliveryAddress.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (order.deliveryAddress.building != null ||
                        order.deliveryAddress.floor != null ||
                        order.deliveryAddress.apartment != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (order.deliveryAddress.building != null)
                            'مبنى ${order.deliveryAddress.building}',
                          if (order.deliveryAddress.floor != null)
                            'الطابق ${order.deliveryAddress.floor}',
                          if (order.deliveryAddress.apartment != null)
                            'شقة ${order.deliveryAddress.apartment}',
                        ].join(' - '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    ],
                    if (order.deliveryAddress.landmark != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.deliveryAddress.landmark!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات الدفع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(order.paymentMethod),
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPaymentMethodName(order.paymentMethod),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(order.paymentStatus)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPaymentStatusName(order.paymentStatus),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getPaymentStatusColor(order.paymentStatus),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ملخص الفاتورة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(context, 'المجموع الفرعي', order.subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'رسوم التوصيل', order.deliveryFee),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'الخصم',
              -order.discount,
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} ج.م',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
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
        Text(
          '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ج.م',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDiscount ? AppColors.success : null,
                fontWeight: isDiscount ? FontWeight.bold : null,
              ),
        ),
      ],
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
              onPressed: () => context.push(
                '/orders/${order.id}/rate',
                extra: {
                  'restaurantName': order.restaurant.displayName,
                  'driverName': order.driver?.name,
                },
              ),
              icon: const Icon(Icons.star_outline),
              label: const Text('قيم الطلب'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/reorder', extra: {'order': order}),
              icon: const Icon(Icons.replay),
              label: const Text('إعادة الطلب'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (!order.isActive) ...[
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => context.push('/order-issue', extra: {'order': order}),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('الإبلاغ عن مشكلة'),
            ),
          ),
        ],
      ],
    );
  }

  void _handleMenuAction(String action, Order order) {
    switch (action) {
      case 'refresh':
        ref
            .read(orderProvider(widget.orderId).notifier)
            .fetchOrder(widget.orderId);
        break;
      case 'cancel':
        _showCancelDialog(context, order);
        break;
      case 'support':
        _callPhone(AppConstants.supportPhone);
        break;
      case 'issue':
        context.push('/order-issue', extra: {'order': order});
        break;
    }
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
                    backgroundColor: success ? AppColors.success : AppColors.error,
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

  IconData _getPaymentIcon(OrderPaymentMethod method) {
    switch (method) {
      case OrderPaymentMethod.cash:
        return Icons.money;
      case OrderPaymentMethod.card:
        return Icons.credit_card;
      case OrderPaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getPaymentMethodName(OrderPaymentMethod method) {
    switch (method) {
      case OrderPaymentMethod.cash:
        return 'الدفع عند الاستلام';
      case OrderPaymentMethod.card:
        return 'بطاقة ائتمان';
      case OrderPaymentMethod.wallet:
        return 'المحفظة';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.pending;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  String _getPaymentStatusName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'قيد الانتظار';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.failed:
        return 'فشل';
      case PaymentStatus.refunded:
        return 'مسترد';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'اليوم';
    } else if (date == yesterday) {
      dateStr = 'أمس';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return '$dateStr الساعة ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
