import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../checkout_screen.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onSelectMethod;

  const CheckoutPaymentSection({
    super.key,
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payment, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'طريقة الدفع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          context,
          method: PaymentMethod.cash,
          icon: Icons.money,
          title: 'الدفع عند الاستلام',
          subtitle: 'ادفع نقداً للسائق',
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          context,
          method: PaymentMethod.card,
          icon: Icons.credit_card,
          title: 'بطاقة ائتمانية',
          subtitle: 'ادفع ببطاقة الائتمان',
          enabled: false, // TODO: Enable when payment gateway is ready
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          context,
          method: PaymentMethod.wallet,
          icon: Icons.account_balance_wallet,
          title: 'المحفظة',
          subtitle: 'ادفع من رصيد محفظتك',
          enabled: false, // TODO: Enable when wallet is implemented
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    bool enabled = true,
  }) {
    final isSelected = selectedMethod == method;

    return GestureDetector(
      onTap: enabled ? () => onSelectMethod(method) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: !enabled
              ? AppColors.background
              : isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !enabled
                ? AppColors.border
                : isSelected
                    ? AppColors.primary
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (enabled ? AppColors.primary : AppColors.textHint)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: enabled ? AppColors.primary : AppColors.textHint,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              enabled ? AppColors.textPrimary : AppColors.textHint,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled ? subtitle : 'قريباً',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (enabled)
              Radio<PaymentMethod>(
                value: method,
                groupValue: selectedMethod,
                onChanged: (value) {
                  if (value != null) onSelectMethod(value);
                },
                activeColor: AppColors.primary,
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'قريباً',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
