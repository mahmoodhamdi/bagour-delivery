import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/payout_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(payoutProvider.notifier).fetchPayouts();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payoutState = ref.watch(payoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المدفوعات'),
        centerTitle: true,
      ),
      body: payoutState.isLoading
          ? const LoadingWidget()
          : payoutState.error != null
              ? CustomErrorWidget(
                  message: payoutState.error!,
                  onRetry: () => ref.read(payoutProvider.notifier).fetchPayouts(),
                )
              : Column(
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'الرصيد المتاح',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${payoutState.balance?.toStringAsFixed(2) ?? '0.00'} ج.م',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: (payoutState.balance ?? 0) > 0
                                ? () => _requestPayout()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('طلب سحب'),
                          ),
                        ],
                      ),
                    ),

                    // Bank Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.account_balance),
                          title: Text(payoutState.bankName ?? 'لم يتم إضافة حساب بنكي'),
                          subtitle: Text(payoutState.accountNumber ?? 'أضف حسابك البنكي لاستلام المدفوعات'),
                          trailing: TextButton(
                            onPressed: () => _editBankDetails(),
                            child: const Text('تعديل'),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payouts History Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'سجل المدفوعات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                    ),

                    // Payouts List
                    Expanded(
                      child: payoutState.payouts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد مدفوعات سابقة',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: payoutState.payouts.length,
                              itemBuilder: (context, index) {
                                final payout = payoutState.payouts[index];
                                return _buildPayoutItem(payout);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPayoutItem(dynamic payout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(payout.status ?? 'pending').withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.payments,
            color: _getStatusColor(payout.status ?? 'pending'),
          ),
        ),
        title: Text(
          '${payout.amount?.toStringAsFixed(2) ?? '0.00'} ج.م',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          payout.createdAt != null
              ? '${payout.createdAt!.day}/${payout.createdAt!.month}/${payout.createdAt!.year}'
              : '',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(payout.status ?? 'pending').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(payout.status ?? 'pending'),
            style: TextStyle(
              color: _getStatusColor(payout.status ?? 'pending'),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _requestPayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلب سحب'),
        content: const Text('هل تريد سحب الرصيد المتاح إلى حسابك البنكي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(payoutProvider.notifier).requestPayout();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _editBankDetails() {
    // Navigate to edit bank details
  }
}
