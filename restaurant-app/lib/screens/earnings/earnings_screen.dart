import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';

/// Earnings data model
class EarningsData {
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final double totalEarnings;
  final double pendingPayout;
  final double totalPaidOut;
  final int todayOrders;
  final int weekOrders;
  final int monthOrders;
  final List<DailyEarning> dailyEarnings;
  final List<OrderBreakdown> orderBreakdown;

  EarningsData({
    this.todayEarnings = 0,
    this.weekEarnings = 0,
    this.monthEarnings = 0,
    this.totalEarnings = 0,
    this.pendingPayout = 0,
    this.totalPaidOut = 0,
    this.todayOrders = 0,
    this.weekOrders = 0,
    this.monthOrders = 0,
    this.dailyEarnings = const [],
    this.orderBreakdown = const [],
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      todayEarnings: (json['todayEarnings'] ?? json['today'] ?? 0).toDouble(),
      weekEarnings: (json['weekEarnings'] ?? json['week'] ?? 0).toDouble(),
      monthEarnings: (json['monthEarnings'] ?? json['month'] ?? 0).toDouble(),
      totalEarnings: (json['totalEarnings'] ?? json['total'] ?? 0).toDouble(),
      pendingPayout: (json['pendingPayout'] ?? 0).toDouble(),
      totalPaidOut: (json['totalPaidOut'] ?? 0).toDouble(),
      todayOrders: json['todayOrders'] ?? 0,
      weekOrders: json['weekOrders'] ?? 0,
      monthOrders: json['monthOrders'] ?? 0,
      dailyEarnings: (json['dailyEarnings'] ?? [])
          .map<DailyEarning>((e) => DailyEarning.fromJson(e))
          .toList(),
      orderBreakdown: (json['orderBreakdown'] ?? [])
          .map<OrderBreakdown>((e) => OrderBreakdown.fromJson(e))
          .toList(),
    );
  }
}

/// Daily earning for charts
class DailyEarning {
  final DateTime date;
  final double amount;
  final int orders;

  DailyEarning({
    required this.date,
    required this.amount,
    required this.orders,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? json['earnings'] ?? 0).toDouble(),
      orders: json['orders'] ?? 0,
    );
  }
}

/// Order breakdown by status
class OrderBreakdown {
  final String status;
  final int count;
  final double total;

  OrderBreakdown({
    required this.status,
    required this.count,
    required this.total,
  });

  factory OrderBreakdown.fromJson(Map<String, dynamic> json) {
    return OrderBreakdown(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

/// Payout model
class Payout {
  final String id;
  final double amount;
  final String status;
  final String? transactionId;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? notes;

  Payout({
    required this.id,
    required this.amount,
    required this.status,
    this.transactionId,
    required this.requestedAt,
    this.processedAt,
    this.notes,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      requestedAt: DateTime.parse(
          json['requestedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      notes: json['notes'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد المعالجة';
      case 'processing':
        return 'جاري التحويل';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey500;
      default:
        return AppColors.grey500;
    }
  }
}

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  EarningsData? _earningsData;
  List<Payout> _payouts = [];
  String _selectedPeriod = 'week';

  final _currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);

      // Fetch earnings data
      final earningsResponse = await api.get(
        AppEndpoints.earnings,
        queryParameters: {'period': _selectedPeriod},
      );

      // Fetch payouts
      final payoutsResponse = await api.get(AppEndpoints.payouts);

      if (mounted) {
        setState(() {
          if (earningsResponse.data['success'] == true) {
            _earningsData = EarningsData.fromJson(earningsResponse.data['data']);
          }
          if (payoutsResponse.data['success'] == true) {
            _payouts = (payoutsResponse.data['data']['payouts'] ??
                    payoutsResponse.data['data'] ??
                    [])
                .map<Payout>((p) => Payout.fromJson(p))
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('فشل في تحميل البيانات');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'سجل المدفوعات'),
          ],
        ),
      ),
      body: _isLoading && _earningsData == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPayoutsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPayoutRequestDialog,
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('طلب سحب'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final data = _earningsData ?? EarningsData();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(data),

            const SizedBox(height: 24),

            // Period Selector
            _buildPeriodSelector(),

            const SizedBox(height: 16),

            // Revenue Chart
            _buildRevenueChart(data),

            const SizedBox(height: 24),

            // Order Breakdown
            _buildOrderBreakdown(data),

            const SizedBox(height: 24),

            // Payout Summary
            _buildPayoutSummary(data),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(EarningsData data) {
    return Column(
      children: [
        // Main earnings card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.radiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'إجمالي الأرباح',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(data.totalEarnings),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'متاح للسحب',
                    value: _currencyFormat.format(data.pendingPayout),
                    valueColor: AppColors.white,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                  _SummaryItem(
                    label: 'تم سحبه',
                    value: _currencyFormat.format(data.totalPaidOut),
                    valueColor: AppColors.white,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Period earnings row
        Row(
          children: [
            Expanded(
              child: _EarningsCard(
                title: 'اليوم',
                amount: _currencyFormat.format(data.todayEarnings),
                orders: data.todayOrders,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EarningsCard(
                title: 'هذا الأسبوع',
                amount: _currencyFormat.format(data.weekEarnings),
                orders: data.weekOrders,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EarningsCard(
                title: 'هذا الشهر',
                amount: _currencyFormat.format(data.monthEarnings),
                orders: data.monthOrders,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(
            label: 'أسبوع',
            isSelected: _selectedPeriod == 'week',
            onTap: () {
              setState(() => _selectedPeriod = 'week');
              _loadData();
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'شهر',
            isSelected: _selectedPeriod == 'month',
            onTap: () {
              setState(() => _selectedPeriod = 'month');
              _loadData();
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: '3 أشهر',
            isSelected: _selectedPeriod == 'quarter',
            onTap: () {
              setState(() => _selectedPeriod = 'quarter');
              _loadData();
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'سنة',
            isSelected: _selectedPeriod == 'year',
            onTap: () {
              setState(() => _selectedPeriod = 'year');
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(EarningsData data) {
    if (data.dailyEarnings.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('لا توجد بيانات كافية لعرض الرسم البياني'),
          ),
        ),
      );
    }

    final maxAmount = data.dailyEarnings
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإيرادات',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.dailyEarnings.map((earning) {
                  final heightRatio = maxAmount > 0 ? earning.amount / maxAmount : 0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            earning.amount > 0
                                ? _formatShortCurrency(earning.amount)
                                : '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Tooltip(
                            message:
                                '${DateFormat('dd/MM').format(earning.date)}\n${_currencyFormat.format(earning.amount)}\n${earning.orders} طلب',
                            child: Container(
                              height: (heightRatio * 150).clamp(4.0, 150.0).toDouble(),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('E', 'ar').format(earning.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildOrderBreakdown(EarningsData data) {
    if (data.orderBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الطلبات',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...data.orderBreakdown.map((breakdown) {
              final statusLabel =
                  AppConstants.orderStatusLabels[breakdown.status] ??
                      breakdown.status;
              final statusColor =
                  Color(AppConstants.orderStatusColors[breakdown.status] ??
                      0xFF9E9E9E);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(statusLabel),
                    ),
                    Text(
                      '${breakdown.count} طلب',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _currencyFormat.format(breakdown.total),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutSummary(EarningsData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ملخص المدفوعات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PayoutInfoRow(
              icon: Icons.account_balance_wallet,
              label: 'متاح للسحب',
              value: _currencyFormat.format(data.pendingPayout),
              valueColor: AppColors.success,
            ),
            const Divider(),
            _PayoutInfoRow(
              icon: Icons.check_circle_outline,
              label: 'إجمالي المسحوب',
              value: _currencyFormat.format(data.totalPaidOut),
              valueColor: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutsTab() {
    if (_payouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات سحب',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اطلب سحب أرباحك من الزر أدناه',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payouts.length + 1,
        itemBuilder: (context, index) {
          if (index == _payouts.length) {
            return const SizedBox(height: 80); // Space for FAB
          }
          return _PayoutCard(payout: _payouts[index]);
        },
      ),
    );
  }

  void _showPayoutRequestDialog() {
    final amountController = TextEditingController();
    final availableAmount = _earningsData?.pendingPayout ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب سحب أرباح',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المبلغ المتاح'),
                        Text(
                          _currencyFormat.format(availableAmount),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ المطلوب سحبه',
                  hintText: 'أدخل المبلغ',
                  prefixText: 'ج.م ',
                  suffixIcon: TextButton(
                    onPressed: () {
                      amountController.text = availableAmount.toStringAsFixed(2);
                    },
                    child: const Text('الكل'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الحد الأدنى للسحب: ${_currencyFormat.format(100)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitPayoutRequest(
                        double.tryParse(amountController.text) ?? 0,
                        context,
                      ),
                      child: const Text('تأكيد الطلب'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPayoutRequest(
    double amount,
    BuildContext dialogContext,
  ) async {
    final availableAmount = _earningsData?.pendingPayout ?? 0;

    if (amount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    if (amount < 100) {
      _showError('الحد الأدنى للسحب 100 ج.م');
      return;
    }

    if (amount > availableAmount) {
      _showError('المبلغ المطلوب أكبر من المتاح');
      return;
    }

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post(
        AppEndpoints.payouts,
        data: {'amount': amount},
      );

      if (response.data['success'] == true) {
        if (mounted && dialogContext.mounted) {
          Navigator.pop(dialogContext);
          _showSuccess('تم إرسال طلب السحب بنجاح');
          _loadData();
        }
      } else {
        _showError(response.data['message'] ?? 'فشل في إرسال الطلب');
      }
    } catch (e) {
      _showError('فشل في إرسال الطلب');
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: valueColor.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  final int orders;
  final Color color;

  const _EarningsCard({
    required this.title,
    required this.amount,
    required this.orders,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$orders طلب',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PayoutInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _PayoutInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final Payout payout;

  const _PayoutCard({required this.payout});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: payout.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(payout.status),
                    color: payout.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(payout.amount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy - HH:mm', 'ar')
                            .format(payout.requestedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: payout.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payout.statusLabel,
                    style: TextStyle(
                      color: payout.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (payout.transactionId != null) ...[
              const SizedBox(height: 8),
              Text(
                'رقم العملية: ${payout.transactionId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (payout.processedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'تاريخ التحويل: ${DateFormat('dd/MM/yyyy', 'ar').format(payout.processedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (payout.notes != null && payout.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payout.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
