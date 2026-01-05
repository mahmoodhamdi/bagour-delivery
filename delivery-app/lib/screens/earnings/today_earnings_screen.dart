import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/earnings_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';

class TodayEarningsScreen extends ConsumerStatefulWidget {
  const TodayEarningsScreen({super.key});

  @override
  ConsumerState<TodayEarningsScreen> createState() =>
      _TodayEarningsScreenState();
}

class _TodayEarningsScreenState extends ConsumerState<TodayEarningsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
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
        title: const Text('أرباح اليوم'),
      ),
      body: _buildBody(earningsState, historyState),
    );
  }

  Widget _buildBody(EarningsState earningsState, OrderHistoryState historyState) {
    if (earningsState.isLoading) {
      return const LoadingIndicator(message: 'جاري تحميل الأرباح...');
    }

    if (earningsState.error != null) {
      return ErrorState(
        message: earningsState.error!,
        onRetry: _loadData,
      );
    }

    final summary = earningsState.summary;
    final today = DateTime.now();
    final todayOrders = historyState.orders.where((o) =>
        o.createdAt.day == today.day &&
        o.createdAt.month == today.month &&
        o.createdAt.year == today.year &&
        o.status == OrderStatus.delivered).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Earnings Card
            _buildMainEarningsCard(summary),
            const SizedBox(height: 24),

            // Statistics Grid
            _buildStatisticsGrid(summary, todayOrders.length),
            const SizedBox(height: 24),

            // Hourly Breakdown
            _buildHourlyBreakdown(todayOrders),
            const SizedBox(height: 24),

            // Today's Deliveries
            _buildTodayDeliveries(todayOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildMainEarningsCard(EarningsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي أرباح اليوم',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.todayEarnings.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _EarningsStat(
                  icon: Icons.delivery_dining,
                  value: '${summary.todayDeliveries}',
                  label: 'توصيلة',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _EarningsStat(
                  icon: Icons.trending_up,
                  value: summary.todayDeliveries > 0
                      ? '${(summary.todayEarnings / summary.todayDeliveries).toStringAsFixed(0)}'
                      : '0',
                  label: 'ج.م/توصيلة',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _EarningsStat(
                  icon: Icons.star,
                  value: summary.averageRating.toStringAsFixed(1),
                  label: 'التقييم',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(EarningsSummary summary, int todayDeliveries) {
    // Calculate comparison with yesterday (mock data)
    final yesterdayEarnings = summary.weekEarnings / 7;
    final earningsChange = summary.todayEarnings - yesterdayEarnings;
    final isPositive = earningsChange >= 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'مقارنة بالأمس',
            value: '${isPositive ? '+' : ''}${earningsChange.toStringAsFixed(0)} ج.م',
            icon: isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'متوسط الأسبوع',
            value: '${(summary.weekEarnings / 7).toStringAsFixed(0)} ج.م',
            icon: Icons.calendar_view_week,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyBreakdown(List<DriverOrder> todayOrders) {
    // Group orders by hour
    final Map<int, double> hourlyEarnings = {};
    for (final order in todayOrders) {
      final hour = order.createdAt.hour;
      hourlyEarnings[hour] = (hourlyEarnings[hour] ?? 0) + order.totalEarnings;
    }

    // Find max for scaling
    final maxEarnings = hourlyEarnings.values.isEmpty
        ? 1.0
        : hourlyEarnings.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'الأرباح حسب الساعة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hourlyEarnings.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد أرباح بعد اليوم',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(24, (hour) {
                    final earnings = hourlyEarnings[hour] ?? 0;
                    final height = maxEarnings > 0 ? (earnings / maxEarnings) * 80 : 0.0;
                    final isActive = hour == DateTime.now().hour;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (earnings > 0)
                              Tooltip(
                                message: '${earnings.toStringAsFixed(0)} ج.م',
                                child: Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(alpha: 0.5),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            if (earnings == 0)
                              Container(
                                height: 4,
                                color: AppColors.grey200,
                              ),
                            const SizedBox(height: 4),
                            if (hour % 6 == 0)
                              Text(
                                '$hour',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayDeliveries(List<DriverOrder> todayOrders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'توصيلات اليوم',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${todayOrders.length} توصيلة',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (todayOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 48,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لم تقم بأي توصيلات اليوم',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayOrders.take(5).map((order) => _DeliveryItem(order: order)),
            if (todayOrders.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full history
                },
                child: Text('عرض الكل (${todayOrders.length})'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return '${days[date.weekday % 7]} ${date.day}/${date.month}';
  }
}

class _EarningsStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _EarningsStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryItem extends StatelessWidget {
  final DriverOrder order;

  const _DeliveryItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurant.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  _formatTime(order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${order.totalEarnings.toStringAsFixed(0)} ج.م',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
