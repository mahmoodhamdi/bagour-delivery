import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/earnings_provider.dart';

class DeliveryCompleteScreen extends ConsumerStatefulWidget {
  final DriverOrder order;

  const DeliveryCompleteScreen({super.key, required this.order});

  @override
  ConsumerState<DeliveryCompleteScreen> createState() =>
      _DeliveryCompleteScreenState();
}

class _DeliveryCompleteScreenState extends ConsumerState<DeliveryCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isConfirming = false;
  bool _paymentCollected = false;
  final _cashCollectedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Pre-fill cash amount if payment is cash
    if (widget.order.paymentMethod == PaymentMethod.cash) {
      _cashCollectedController.text = widget.order.total.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cashCollectedController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelivery() async {
    if (widget.order.paymentMethod == PaymentMethod.cash && !_paymentCollected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تأكيد استلام المبلغ النقدي'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);

    final success = await ref.read(currentOrderProvider.notifier).completeDelivery();

    if (!mounted) return;

    if (success) {
      // Refresh earnings
      ref.read(earningsProvider.notifier).fetchEarnings();
      ref.read(driverStatsProvider.notifier).fetchStats();

      _showSuccessDialog();
    } else {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في تأكيد التوصيل'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isConfirming = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Container(
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
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تهانينا!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم التوصيل بنجاح',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payments, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'أرباحك: ${widget.order.totalEarnings.toStringAsFixed(0)} ج.م',
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
                Navigator.pop(context);
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
    final order = widget.order;
    final isCashPayment = order.paymentMethod == PaymentMethod.cash;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد التوصيل'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.driverGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        size: 48,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'وصلت للعميل',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'طلب #${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص الطلب',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        label: 'العميل',
                        value: order.customer.name,
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'المطعم',
                        value: order.restaurant.displayName,
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'عدد العناصر',
                        value: '${order.totalItems} عنصر',
                      ),
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'إجمالي الطلب',
                        value: '${order.total.toStringAsFixed(0)} ج.م',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Section
            if (isCashPayment)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.payments,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الدفع نقدي',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'يجب تحصيل المبلغ من العميل',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المبلغ المطلوب',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${order.total.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _paymentCollected,
                          onChanged: (value) {
                            setState(() => _paymentCollected = value ?? false);
                          },
                          title: const Text('تم استلام المبلغ من العميل'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Earnings Card
            FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                color: AppColors.success.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أرباحك من هذا الطلب',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                Text(
                                  '${order.totalEarnings.toStringAsFixed(0)} ج.م',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (order.tip != null && order.tip! > 0) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text('البقشيش'),
                              ],
                            ),
                            Text(
                              '${order.tip!.toStringAsFixed(0)} ج.م',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm Button
            ElevatedButton(
              onPressed: _isConfirming ? null : _confirmDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'تأكيد التوصيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Report Issue Button
            TextButton.icon(
              onPressed: () {
                _showReportIssueDialog();
              },
              icon: const Icon(Icons.report_problem_outlined, color: AppColors.error),
              label: const Text(
                'الإبلاغ عن مشكلة',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog() {
    final issueController = TextEditingController();
    String? selectedIssue;

    final issues = [
      'العميل غير متواجد',
      'عنوان خاطئ',
      'العميل رفض الاستلام',
      'مشكلة في الطلب',
      'أخرى',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الإبلاغ عن مشكلة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...issues.map((issue) => RadioListTile<String>(
                    title: Text(issue),
                    value: issue,
                    groupValue: selectedIssue,
                    onChanged: (value) {
                      setModalState(() => selectedIssue = value);
                    },
                  )),
              if (selectedIssue == 'أخرى')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: issueController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب تفاصيل المشكلة...',
                    ),
                    maxLines: 3,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedIssue != null
                    ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال البلاغ بنجاح'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('إرسال البلاغ'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
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
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
