import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/cart.dart';

class CartSummary extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Free Delivery Progress
            if (cart.freeDeliveryAbove != null &&
                cart.amountForFreeDelivery > 0) ...[
              _buildFreeDeliveryProgress(context),
              const SizedBox(height: 16),
            ],
            // Minimum Order Warning
            if (!cart.meetsMinimumOrder) ...[
              _buildMinimumOrderWarning(context),
              const SizedBox(height: 16),
            ],
            // Price Breakdown
            _buildPriceRow(
              context,
              'المجموع الفرعي',
              cart.subtotal,
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              context,
              'رسوم التوصيل',
              cart.actualDeliveryFee,
              isFree: cart.hasFreeDelivery,
              originalValue: cart.deliveryFee,
            ),
            const Divider(height: 24),
            _buildPriceRow(
              context,
              'الإجمالي',
              cart.total,
              isTotal: true,
            ),
            const SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cart.meetsMinimumOrder ? onCheckout : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      const SizedBox(width: 8),
                      Text(
                        'إتمام الطلب',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cart.total.toStringAsFixed(2)} ج.م',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildFreeDeliveryProgress(BuildContext context) {
    final progress = cart.subtotal / (cart.freeDeliveryAbove ?? 1);
    final remaining = cart.amountForFreeDelivery;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أضف ${remaining.toStringAsFixed(2)} ج.م للتوصيل المجاني',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumOrderWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الحد الأدنى للطلب ${cart.minimumOrder?.toStringAsFixed(0)} ج.م\n'
              'أضف ${cart.amountForMinimumOrder.toStringAsFixed(2)} ج.م للمتابعة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[900],
                  ),
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
    bool isFree = false,
    double? originalValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
        ),
        Row(
          children: [
            if (isFree && originalValue != null && originalValue > 0) ...[
              Text(
                '${originalValue.toStringAsFixed(2)} ج.م',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'مجاني',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ] else
              Text(
                '${value.toStringAsFixed(2)} ج.م',
                style: isTotal
                    ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
          ],
        ),
      ],
    );
  }
}
