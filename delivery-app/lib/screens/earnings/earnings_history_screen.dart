import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/earnings_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';

class EarningsHistoryScreen extends ConsumerStatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  ConsumerState<EarningsHistoryScreen> createState() =>
      _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends ConsumerState<EarningsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(earningsProvider.notifier).fetchEarnings(),
      ref.read(orderHistoryProvider.notifier).fetchHistory(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final historyState = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الأرباح'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'أسبوعي'),
            Tab(text: 'شهري'),
            Tab(text: 'سنوي'),
          ],
          onTap: (index) {
            setState(() {
              _selectedPeriod = ['week', 'month', 'year'][index];
            });
          },
        ),
      ),
      body: _buildBody(earningsState, historyState),
    );
  }

  Widget _buildBody(EarningsState earningsState, OrderHistoryState historyState) {
    if (earningsState.isLoading) {
      return const LoadingIndicator(message: 'جاري تحميل السجل...');
    }

    if (earningsState.error != null) {
      return ErrorState(
        message: earningsState.error!,
        onRetry: _loadData,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPeriodView('week', earningsState.summary, historyState.orders),
        _buildPeriodView('month', earningsState.summary, historyState.orders),
        _buildPeriodView('year', earningsState.summary, historyState.orders),
      ],
    );
  }

  Widget _buildPeriodView(
    String period,
    EarningsSummary summary,
    List<DriverOrder> allOrders,
  ) {
    final now = DateTime.now();
    List<DriverOrder> filteredOrders;
    double totalEarnings;
    int deliveriesCount;
    String periodLabel;

    switch (period) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredOrders = allOrders.where((o) =>
            o.createdAt.isAfter(weekAgo) &&
            o.status == OrderStatus.delivered).toList();
        totalEarnings = summary.weekEarnings;
        deliveriesCount = summary.weekDeliveries;
        periodLabel = 'هذا الأسبوع';
        break;
      case 'month':
        filteredOrders = allOrders.where((o) =>
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year &&
            o.status == OrderStatus.delivered).toList();
        totalEarnings = summary.monthEarnings;
        deliveriesCount = summary.monthDeliveries;
        periodLabel = 'هذا الشهر';
        break;
      case 'year':
        filteredOrders = allOrders.where((o) =>
            o.createdAt.year == now.year &&
            o.status == OrderStatus.delivered).toList();
        totalEarnings = summary.totalEarnings;
        deliveriesCount = summary.totalDeliveries;
        periodLabel = 'هذه السنة';
        break;
      default:
        filteredOrders = [];
        totalEarnings = 0;
        deliveriesCount = 0;
        periodLabel = '';
    }

    // Group by date
    final Map<String, List<DriverOrder>> groupedOrders = {};
    for (final order in filteredOrders) {
      final dateKey = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
      groupedOrders.putIfAbsent(dateKey, () => []).add(order);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            _buildSummaryCard(totalEarnings, deliveriesCount, periodLabel),
            const SizedBox(height: 24),

            // Chart
            _buildEarningsChart(period, filteredOrders),
            const SizedBox(height: 24),

            // Daily Breakdown
            _buildDailyBreakdown(groupedOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double earnings, int deliveries, String period) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${earnings.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.delivery_dining,
                value: '$deliveries',
                label: 'توصيلة',
              ),
              const SizedBox(width: 24),
              _StatChip(
                icon: Icons.trending_up,
                value: deliveries > 0
                    ? (earnings / deliveries).toStringAsFixed(0)
                    : '0',
                label: 'ج.م/توصيلة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(String period, List<DriverOrder> orders) {
    // Group earnings by day/week/month
    Map<String, double> chartData = {};
    final now = DateTime.now();

    switch (period) {
      case 'week':
        // Last 7 days
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final key = _getWeekdayName(date.weekday);
          chartData[key] = 0;
        }
        for (final order in orders) {
          final key = _getWeekdayName(order.createdAt.weekday);
          chartData[key] = (chartData[key] ?? 0) + order.totalEarnings;
        }
        break;
      case 'month':
        // Last 4 weeks
        for (int i = 3; i >= 0; i--) {
          chartData['أسبوع ${4 - i}'] = 0;
        }
        for (final order in orders) {
          final weekOfMonth = ((order.createdAt.day - 1) ~/ 7) + 1;
          final key = 'أسبوع $weekOfMonth';
          if (chartData.containsKey(key)) {
            chartData[key] = (chartData[key] ?? 0) + order.totalEarnings;
          }
        }
        break;
      case 'year':
        // All months
        final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
            'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
        for (final month in months) {
          chartData[month] = 0;
        }
        for (final order in orders) {
          final key = months[order.createdAt.month - 1];
          chartData[key] = (chartData[key] ?? 0) + order.totalEarnings;
        }
        break;
    }

    final maxValue = chartData.values.isEmpty
        ? 1.0
        : chartData.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع الأرباح',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.entries.map((entry) {
                  final height = maxValue > 0
                      ? (entry.value / maxValue) * 100
                      : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (entry.value > 0)
                            Text(
                              '${entry.value.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            height: height > 0 ? height : 4,
                            decoration: BoxDecoration(
                              color: entry.value > 0
                                  ? AppColors.primary
                                  : AppColors.grey200,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            period == 'year'
                                ? entry.key.substring(0, 3)
                                : entry.key,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: period == 'year' ? 8 : 10,
                                  color: AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
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

  Widget _buildDailyBreakdown(Map<String, List<DriverOrder>> groupedOrders) {
    if (groupedOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppColors.grey300,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد أرباح في هذه الفترة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التفاصيل اليومية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            ...groupedOrders.entries.map((entry) {
              final dayTotal = entry.value.fold<double>(
                  0, (sum, o) => sum + o.totalEarnings);

              return _DayItem(
                date: entry.key,
                deliveries: entry.value.length,
                earnings: dayTotal,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    final days = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return days[weekday - 1];
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            '$value $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String date;
  final int deliveries;
  final double earnings;

  const _DayItem({
    required this.date,
    required this.deliveries,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$deliveries توصيلة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${earnings.toStringAsFixed(0)} ج.م',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
          ),
        ],
      ),
    );
  }
}
