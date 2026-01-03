import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;
  final String orderId;

  const PaymentResultScreen({
    super.key,
    required this.success,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (success ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: success ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                success ? 'تم الدفع بنجاح!' : 'فشل الدفع',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: success ? AppColors.success : AppColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                success
                    ? 'شكراً لك! تم تأكيد طلبك وسيتم تحضيره قريباً.'
                    : 'عذراً، لم نتمكن من إتمام عملية الدفع. يرجى المحاولة مرة أخرى.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Primary Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (success) {
                      context.go('/order/$orderId');
                    } else {
                      context.go('/checkout');
                    }
                  },
                  child: Text(
                    success ? 'تتبع الطلب' : 'المحاولة مرة أخرى',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: const Text('العودة للرئيسية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
