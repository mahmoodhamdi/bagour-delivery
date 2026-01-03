import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../models/order.dart';

class OrderInfoCard extends StatelessWidget {
  final Order order;

  const OrderInfoCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
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
          // Restaurant Info
          _buildRestaurantInfo(context),
          const Divider(height: 24),

          // Delivery Address
          _buildDeliveryAddress(context),
          const Divider(height: 24),

          // Order Items
          _buildOrderItems(context),
          const Divider(height: 24),

          // Payment Summary
          _buildPaymentSummary(context),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: order.restaurant.logo != null
              ? CachedNetworkImage(
                  imageUrl: order.restaurant.logo!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
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
              Text(
                '${order.totalItems} عنصر',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.background,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'عنوان التوصيل',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.deliveryAddress.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                order.deliveryAddress.fullAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (order.deliveryAddress.landmark != null) ...[
                const SizedBox(height: 2),
                Text(
                  'علامة: ${order.deliveryAddress.landmark}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'تفاصيل الطلب',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...order.items.map((item) => _buildOrderItem(context, item)),
        if (order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_outlined,
                    size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(right: 26, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.quantity}x',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (item.variations.isNotEmpty || item.addons.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      ...item.variations
                          .map((v) => v.optionAr ?? v.option),
                      ...item.addons.map((a) => '+ ${a.nameAr ?? a.name}'),
                    ].join('، '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(2)} ج.م',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'ملخص الدفع',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            _buildPaymentMethodBadge(context),
          ],
        ),
        const SizedBox(height: 12),
        _buildPriceRow(context, 'المجموع الفرعي', order.subtotal),
        const SizedBox(height: 4),
        _buildPriceRow(context, 'رسوم التوصيل', order.deliveryFee),
        if (order.discount > 0) ...[
          const SizedBox(height: 4),
          _buildPriceRow(context, 'الخصم', -order.discount, isDiscount: true),
        ],
        const Divider(height: 16),
        _buildPriceRow(context, 'الإجمالي', order.total, isTotal: true),
      ],
    );
  }

  Widget _buildPaymentMethodBadge(BuildContext context) {
    String label;
    IconData icon;

    switch (order.paymentMethod) {
      case OrderPaymentMethod.cash:
        label = 'نقداً';
        icon = Icons.money;
        break;
      case OrderPaymentMethod.card:
        label = 'بطاقة';
        icon = Icons.credit_card;
        break;
      case OrderPaymentMethod.wallet:
        label = 'محفظة';
        icon = Icons.account_balance_wallet;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${value.abs().toStringAsFixed(2)} ج.م',
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDiscount ? AppColors.success : null,
                    fontWeight: FontWeight.w600,
                  ),
        ),
      ],
    );
  }
}
