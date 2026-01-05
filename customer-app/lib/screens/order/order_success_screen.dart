import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderSuccessScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? orderNumber;
  final DateTime? estimatedDeliveryTime;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    this.orderNumber,
    this.estimatedDeliveryTime,
  });

  @override
  ConsumerState<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends ConsumerState<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showSuccessAnimation = true;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      _fadeController.forward();

      // Hide success animation after a few seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showSuccessAnimation = false);
        }
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider(widget.orderId));
    final order = orderState.order;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Success Icon with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'تم تأكيد طلبك بنجاح!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'شكراً لك على طلبك. سيتم تحضيره وتوصيله إليك في أقرب وقت.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Order Details Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildOrderInfoCard(context, order),
                  ),
                  const SizedBox(height: 24),

                  // Estimated Time Card
                  if (order?.estimatedDeliveryTime != null ||
                      widget.estimatedDeliveryTime != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildEstimatedTimeCard(
                        context,
                        order?.estimatedDeliveryTime ?? widget.estimatedDeliveryTime!,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // What's Next Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildWhatsNextSection(context),
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Success Animation Overlay
          if (_showSuccessAnimation)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Lottie.asset(
                    AppAssets.successAnimation,
                    width: 200,
                    height: 200,
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if animation asset is not available
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, Order? order) {
    final orderNumber = order?.orderNumber ?? widget.orderNumber ?? 'غير متوفر';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'تفاصيل الطلب',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'رقم الطلب',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#$orderNumber',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ),
          if (order != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildOrderInfoRow(
              context,
              icon: Icons.restaurant,
              label: 'المطعم',
              value: order.restaurant.displayName,
            ),
            const SizedBox(height: 12),
            _buildOrderInfoRow(
              context,
              icon: Icons.shopping_bag_outlined,
              label: 'عدد العناصر',
              value: '${order.totalItems} عنصر',
            ),
            const SizedBox(height: 12),
            _buildOrderInfoRow(
              context,
              icon: Icons.payment,
              label: 'طريقة الدفع',
              value: _getPaymentMethodName(order.paymentMethod),
            ),
            const SizedBox(height: 12),
            _buildOrderInfoRow(
              context,
              icon: Icons.attach_money,
              label: 'الإجمالي',
              value: '${order.total.toStringAsFixed(2)} ج.م',
              valueColor: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Widget _buildEstimatedTimeCard(BuildContext context, DateTime estimatedTime) {
    final now = DateTime.now();
    final difference = estimatedTime.difference(now);
    final minutes = difference.inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوقت المتوقع للتوصيل',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  minutes > 0 ? '$minutes دقيقة تقريباً' : 'قريباً جداً',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الوصول بحلول ${_formatTime(estimatedTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNextSection(BuildContext context) {
    final steps = [
      {
        'icon': Icons.check_circle,
        'title': 'تم استلام الطلب',
        'subtitle': 'المطعم يراجع طلبك',
        'completed': true,
      },
      {
        'icon': Icons.restaurant,
        'title': 'جاري التحضير',
        'subtitle': 'سيبدأ التحضير قريباً',
        'completed': false,
      },
      {
        'icon': Icons.delivery_dining,
        'title': 'في الطريق',
        'subtitle': 'السائق في طريقه إليك',
        'completed': false,
      },
      {
        'icon': Icons.home,
        'title': 'تم التوصيل',
        'subtitle': 'استمتع بوجبتك!',
        'completed': false,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'مراحل الطلب',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            final completed = step['completed'] as bool;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.success
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: completed
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 18,
                        color: completed ? Colors.white : AppColors.textHint,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: completed
                            ? AppColors.success
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: completed
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['subtitle'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/order/${widget.orderId}'),
            icon: const Icon(Icons.track_changes),
            label: const Text('تتبع الطلب'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('العودة للرئيسية'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push('/orders'),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('عرض جميع الطلبات'),
        ),
      ],
    );
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
