import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/loading_widget.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).fetchAnalytics(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات'),
        centerTitle: true,
      ),
      body: analyticsState.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selection
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Summary Cards
                  _buildSummaryCards(analyticsState),
                  const SizedBox(height: 24),

                  // Orders Chart
                  _buildOrdersChart(analyticsState),
                  const SizedBox(height: 24),

                  // Top Items
                  _buildTopItems(analyticsState),
                  const SizedBox(height: 24),

                  // Ratings Overview
                  _buildRatingsOverview(analyticsState),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodChip('today', 'اليوم'),
        const SizedBox(width: 8),
        _buildPeriodChip('week', 'الأسبوع'),
        const SizedBox(width: 8),
        _buildPeriodChip('month', 'الشهر'),
        const SizedBox(width: 8),
        _buildPeriodChip('year', 'السنة'),
      ],
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
          ref.read(analyticsProvider.notifier).fetchAnalytics(value);
        }
      },
    );
  }

  Widget _buildSummaryCards(dynamic state) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'الطلبات',
            '${state.totalOrders ?? 0}',
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'الإيرادات',
            '${state.totalRevenue?.toStringAsFixed(0) ?? 0} ج.م',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart(dynamic state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الطلبات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'رسم بياني للطلبات',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopItems(dynamic state) {
    final topItems = state.topItems ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأصناف الأكثر طلباً',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (topItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'لا توجد بيانات',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              )
            else
              ...topItems.take(5).map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        '${topItems.indexOf(item) + 1}',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                    title: Text(item.name ?? ''),
                    trailing: Text('${item.orderCount ?? 0} طلب'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsOverview(dynamic state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التقييمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      '${state.averageRating?.toStringAsFixed(1) ?? '0.0'}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (state.averageRating?.floor() ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '${state.totalReviews ?? 0} تقييم',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final percentage = state.ratingDistribution?[star] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$percentage%'),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
