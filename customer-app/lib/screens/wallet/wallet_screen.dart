import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/wallet_service.dart';
import '../../config/routes.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  WalletBalance? _balance;
  List<WalletTransaction> _transactions = [];
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWalletData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload data when app comes back to foreground (after payment)
    if (state == AppLifecycleState.resumed) {
      _loadWalletData();
    }
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);

    try {
      final walletService = ref.read(walletServiceProvider);

      // Load balance and transactions in parallel
      final results = await Future.wait([
        walletService.getBalance(),
        walletService.getTransactions(page: 1, limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _balance = results[0] as WalletBalance;
          final transactionsResponse = results[1] as WalletTransactionsResponse;
          _transactions = transactionsResponse.transactions;
          _hasMore = transactionsResponse.page < transactionsResponse.pages;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل بيانات المحفظة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTopUpDialog() {
    final List<int> amounts = [50, 100, 200, 500];
    int? selectedAmount;
    String paymentMethod = 'card';
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('شحن المحفظة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختر المبلغ المراد شحنه'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amounts.map((amount) {
                    final isSelected = selectedAmount == amount;
                    return ElevatedButton(
                      onPressed: () {
                        setDialogState(() => selectedAmount = amount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.green : null,
                        foregroundColor: isSelected ? Colors.white : null,
                      ),
                      child: Text('$amount ج.م'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('طريقة الدفع'),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('بطاقة ائتمان'),
                  value: 'card',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setDialogState(() => paymentMethod = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('محفظة إلكترونية'),
                  value: 'mobile_wallet',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setDialogState(() => paymentMethod = value!);
                  },
                ),
                if (paymentMethod == 'mobile_wallet') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '01xxxxxxxxx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: selectedAmount != null
                  ? () {
                      Navigator.of(dialogContext).pop();
                      _processTopUp(
                        selectedAmount!.toDouble(),
                        paymentMethod,
                        phoneController.text.trim(),
                      );
                    }
                  : null,
              child: const Text('متابعة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processTopUp(
    double amount,
    String paymentMethod,
    String phoneNumber,
  ) async {
    try {
      final walletService = ref.read(walletServiceProvider);

      final response = await walletService.initiateTopUp(
        amount: amount,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
      );

      if (mounted) {
        // Navigate to payment webview
        context.push(
          AppRoutes.payment,
          extra: {
            'paymentUrl': response.paymentUrl,
            'orderId': response.transactionId,
            'isWalletTopup': true,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل بدء عملية الشحن: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
        centerTitle: true,
      ),
      body: _isLoading && _balance == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Balance Card
                  Card(
                    elevation: 4,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'رصيد المحفظة',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_balance?.balance ?? 0.0).toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'إجمالي الشحن',
                                '${(_balance?.totalTopups ?? 0.0).toStringAsFixed(0)} ج.م',
                              ),
                              Container(width: 1, height: 30, color: Colors.white30),
                              _buildStatItem(
                                'إجمالي الإنفاق',
                                '${(_balance?.totalSpent ?? 0.0).toStringAsFixed(0)} ج.م',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showTopUpDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('شحن المحفظة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.info_outline,
                            title: 'استخدم المحفظة للدفع',
                            subtitle: 'يمكنك استخدام رصيد المحفظة لدفع ثمن طلباتك',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.security,
                            title: 'آمن ومضمون',
                            subtitle: 'جميع المعاملات محمية ومشفرة',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.history,
                            title: 'سجل كامل',
                            subtitle: 'تتبع جميع معاملاتك بسهولة',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transactions Header
                  const Text(
                    'آخر المعاملات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Transactions List
                  if (_transactions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد معاملات حتى الآن',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_transactions.map((transaction) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.isCredit
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                transaction.isCredit ? Icons.add : Icons.remove,
                                color: transaction.isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(transaction.typeLabel),
                            subtitle: Text(
                              _formatDate(transaction.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${transaction.isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: transaction.isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ))),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
