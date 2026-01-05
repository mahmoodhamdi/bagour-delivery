import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isLoading = false;

  // Placeholder data - will be replaced with actual API calls
  final double _balance = 0.0;
  final List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call to fetch wallet balance and transactions
      // final walletService = ref.read(walletServiceProvider);
      // final balance = await walletService.getBalance();
      // final transactions = await walletService.getTransactions();

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        setState(() => _isLoading = false);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شحن المحفظة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر المبلغ المراد شحنه'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50, 100, 200, 500].map((amount) {
                return ElevatedButton(
                  onPressed: () {
                    context.pop();
                    _processTopUp(amount.toDouble());
                  },
                  child: Text('$amount ج.م'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _processTopUp(double amount) async {
    // TODO: Implement top-up functionality
    // This would typically redirect to payment gateway
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('شحن المحفظة بمبلغ $amount ج.م'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
        centerTitle: true,
      ),
      body: _isLoading
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
                            '${_balance.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                              backgroundColor: transaction.type == TransactionType.credit
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                transaction.type == TransactionType.credit
                                    ? Icons.add
                                    : Icons.remove,
                                color: transaction.type == TransactionType.credit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text(
                              _formatDate(transaction.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${transaction.type == TransactionType.credit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: transaction.type == TransactionType.credit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ))),
                ],
              ),
            ),
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

// Transaction model
enum TransactionType { credit, debit }

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
}
