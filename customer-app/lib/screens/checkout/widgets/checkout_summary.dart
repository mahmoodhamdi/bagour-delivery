import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/cart.dart';

class CheckoutSummary extends StatelessWidget {
  final Cart cart;

  const CheckoutSummary({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'ملخص الطلب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildRow(
                context,
                'المجموع الفرعي',
                '${cart.subtotal.toStringAsFixed(2)} ج.م',
              ),
              const SizedBox(height: 8),
              _buildRow(
                context,
                'رسوم التوصيل',
                cart.hasFreeDelivery
                    ? 'مجاني'
                    : '${cart.actualDeliveryFee.toStringAsFixed(2)} ج.م',
                isFree: cart.hasFreeDelivery,
                originalValue: cart.deliveryFee,
              ),
              const Divider(height: 24),
              _buildRow(
                context,
                'الإجمالي',
                '${cart.total.toStringAsFixed(2)} ج.م',
                isTotal: true,
              ),
            ],
          ),
        ),
        if (cart.hasFreeDelivery)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'تهانينا! حصلت على توصيل مجاني',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success,
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
                value,
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
