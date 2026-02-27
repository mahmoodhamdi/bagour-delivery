import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/earnings_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  String _selectedBank = '';
  String _selectedPaymentMethod = 'bank';
  bool _isLoading = false;

  final List<Map<String, String>> _banks = [
    {'id': 'cib', 'name': 'البنك التجاري الدولي CIB'},
    {'id': 'nbe', 'name': 'البنك الأهلي المصري'},
    {'id': 'qnb', 'name': 'بنك قطر الوطني QNB'},
    {'id': 'alex', 'name': 'بنك الإسكندرية'},
    {'id': 'banque_misr', 'name': 'بنك مصر'},
    {'id': 'aaib', 'name': 'البنك العربي الأفريقي'},
    {'id': 'other', 'name': 'بنك آخر'},
  ];

  final List<Map<String, String>> _wallets = [
    {'id': 'vodafone_cash', 'name': 'فودافون كاش'},
    {'id': 'etisalat_cash', 'name': 'اتصالات كاش'},
    {'id': 'orange_cash', 'name': 'أورانج كاش'},
    {'id': 'we_pay', 'name': 'وي باي'},
    {'id': 'instapay', 'name': 'انستاباي'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(earningsProvider.notifier).fetchEarnings();
  }

  Future<void> _submitPayout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBank.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedPaymentMethod == 'bank'
              ? 'يرجى اختيار البنك'
              : 'يرجى اختيار المحفظة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(withdrawalsProvider.notifier).requestWithdrawal(
          amount: double.parse(_amountController.text),
          bankName: _selectedBank,
          accountNumber: _accountNumberController.text.trim(),
          accountName: _accountNameController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      final error = ref.read(withdrawalsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في تقديم طلب السحب'),
          backgroundColor: AppColors.error,
        ),
      );
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
            Container(
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
            const SizedBox(height: 24),
            Text(
              'تم تقديم الطلب بنجاح',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم مراجعة طلبك وتحويل المبلغ خلال 3-5 أيام عمل',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('حسناً'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final availableBalance = earningsState.summary.availableBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب سحب'),
      ),
      body: earningsState.isLoading
          ? const LoadingIndicator(message: 'جاري التحميل...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Available Balance Card
                    _buildBalanceCard(availableBalance),
                    const SizedBox(height: 24),

                    // Payment Method Selection
                    _buildPaymentMethodSelection(),
                    const SizedBox(height: 24),

                    // Bank/Wallet Selection
                    _buildBankSelection(),
                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        prefixIcon: const Icon(Icons.payments),
                        suffixText: 'ج.م',
                        helperText: 'الحد الأدنى للسحب: 50 ج.م',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'المبلغ مطلوب';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'أدخل مبلغ صحيح';
                        }
                        if (amount < 50) {
                          return 'الحد الأدنى للسحب 50 ج.م';
                        }
                        if (amount > availableBalance) {
                          return 'المبلغ أكبر من الرصيد المتاح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Number Field
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: _selectedPaymentMethod == 'wallet'
                          ? TextInputType.phone
                          : TextInputType.number,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: _selectedPaymentMethod == 'wallet'
                            ? 'رقم الهاتف'
                            : 'رقم الحساب / IBAN',
                        prefixIcon: Icon(_selectedPaymentMethod == 'wallet'
                            ? Icons.phone
                            : Icons.account_balance),
                        hintText: _selectedPaymentMethod == 'wallet'
                            ? '01XXXXXXXXX'
                            : 'EG00 0000 0000 0000 0000 0000',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedPaymentMethod == 'wallet'
                              ? 'رقم الهاتف مطلوب'
                              : 'رقم الحساب مطلوب';
                        }
                        if (_selectedPaymentMethod == 'wallet') {
                          if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                            return 'رقم الهاتف غير صالح';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Name Field
                    TextFormField(
                      controller: _accountNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'اسم صاحب الحساب',
                        prefixIcon: Icon(Icons.person),
                        hintText: 'كما هو مسجل في البنك',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'اسم صاحب الحساب مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.info),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'ملاحظات هامة',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoItem(text: 'يتم تحويل المبلغ خلال 3-5 أيام عمل'),
                          _InfoItem(text: 'تأكد من صحة بيانات الحساب'),
                          _InfoItem(text: 'يجب أن يكون الحساب باسمك الشخصي'),
                          _InfoItem(text: 'رسوم التحويل: مجاني'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading || availableBalance < 50
                          ? null
                          : _submitPayout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'تأكيد طلب السحب',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    if (availableBalance < 50)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'الرصيد المتاح أقل من الحد الأدنى للسحب',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(double availableBalance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'الرصيد المتاح للسحب',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${availableBalance.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              _amountController.text = availableBalance.toStringAsFixed(0);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text('سحب الرصيد كاملاً'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة السحب',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.account_balance,
                label: 'حساب بنكي',
                isSelected: _selectedPaymentMethod == 'bank',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'bank';
                    _selectedBank = '';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.account_balance_wallet,
                label: 'محفظة إلكترونية',
                isSelected: _selectedPaymentMethod == 'wallet',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'wallet';
                    _selectedBank = '';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankSelection() {
    final items = _selectedPaymentMethod == 'bank' ? _banks : _wallets;

    return DropdownButtonFormField<String>(
      initialValue: _selectedBank.isEmpty ? null : _selectedBank,
      decoration: InputDecoration(
        labelText: _selectedPaymentMethod == 'bank' ? 'البنك' : 'المحفظة',
        prefixIcon: Icon(_selectedPaymentMethod == 'bank'
            ? Icons.business
            : Icons.account_balance_wallet),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item['name'],
          child: Text(item['name']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBank = value ?? '');
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _selectedPaymentMethod == 'bank'
              ? 'يرجى اختيار البنك'
              : 'يرجى اختيار المحفظة';
        }
        return null;
      },
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;

  const _InfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.info)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
