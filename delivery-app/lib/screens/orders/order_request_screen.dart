import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderRequestScreen extends ConsumerStatefulWidget {
  final AvailableOrder order;

  const OrderRequestScreen({super.key, required this.order});

  @override
  ConsumerState<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends ConsumerState<OrderRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _countdownTimer;
  int _remainingSeconds = AppConstants.orderAcceptTimeout.inSeconds;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (mounted && !_isProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('انتهى وقت قبول الطلب'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  Future<void> _acceptOrder() async {
    setState(() => _isProcessing = true);
    _countdownTimer.cancel();

    final success = await ref
        .read(currentOrderProvider.notifier)
        .acceptOrder(widget.order.id);

    if (!mounted) return;

    if (success) {
      ref.read(availableOrdersProvider.notifier).removeOrder(widget.order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الطلب بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.activeOrder);
    } else {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في قبول الطلب'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isProcessing = false);
      _startCountdown();
    }
  }

  Future<void> _rejectOrder() async {
    setState(() => _isProcessing = true);
    _countdownTimer.cancel();

    final reason = await _showRejectReasonDialog();

    if (reason == null) {
      setState(() => _isProcessing = false);
      _startCountdown();
      return;
    }

    final success = await ref
        .read(currentOrderProvider.notifier)
        .rejectOrder(widget.order.id, reason: reason);

    if (!mounted) return;

    if (success) {
      ref.read(availableOrdersProvider.notifier).removeOrder(widget.order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفض الطلب'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في رفض الطلب'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isProcessing = false);
      _startCountdown();
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    String? selectedReason;
    final reasons = [
      'بعيد جداً',
      'مشغول حالياً',
      'مشكلة في المركبة',
      'ظروف جوية سيئة',
      'سبب آخر',
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) {
            return RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: selectedReason,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final progress = _remainingSeconds / AppConstants.orderAcceptTimeout.inSeconds;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // New Order Badge
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'طلب جديد!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Countdown Timer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.grey700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.3 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    Text(
                      '$_remainingSeconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Order Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Info
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: order.restaurant.logo != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      order.restaurant.logo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.restaurant, color: AppColors.primary),
                                    ),
                                  )
                                : const Icon(Icons.restaurant, color: AppColors.primary),
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
                                  order.restaurant.area,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Delivery Location
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'التوصيل إلى',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                Text(
                                  order.deliveryAddress.area,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Order Details Row
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.shopping_bag,
                              label: 'العناصر',
                              value: '${order.itemsCount} عنصر',
                            ),
                          ),
                          Expanded(
                            child: _InfoTile(
                              icon: order.paymentMethod == PaymentMethod.cash
                                  ? Icons.payments
                                  : Icons.credit_card,
                              label: 'الدفع',
                              value: order.paymentMethod == PaymentMethod.cash
                                  ? 'نقدي'
                                  : 'بطاقة',
                            ),
                          ),
                          if (order.distanceKm != null)
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.straighten,
                                label: 'المسافة',
                                value: '${order.distanceKm!.toStringAsFixed(1)} كم',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Earnings Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.driverGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'أرباحك المتوقعة',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(order.estimatedEarnings ?? order.deliveryFee).toStringAsFixed(0)} ج.م',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.payments,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : _rejectOrder,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'رفض',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _acceptOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'قبول الطلب',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
