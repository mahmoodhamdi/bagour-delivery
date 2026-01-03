import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/earnings_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    await Future.wait([
      ref.read(earningsProvider.notifier).fetchEarnings(),
      ref.read(withdrawalsProvider.notifier).fetchWithdrawals(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final withdrawalsState = ref.watch(withdrawalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'الأرباح'),
            Tab(text: 'طلبات السحب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsTab(earningsState),
          _buildWithdrawalsTab(withdrawalsState),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(EarningsState state) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'جاري تحميل الأرباح...');
    }

    if (state.error != null) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.read(earningsProvider.notifier).fetchEarnings(),
      );
    }

    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () => ref.read(earningsProvider.notifier).fetchEarnings(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Available Balance Card
            _buildBalanceCard(summary.availableBalance, summary.pendingBalance),
            const SizedBox(height: 24),

            // Earnings Summary
            _buildSectionHeader('ملخص الأرباح'),
            const SizedBox(height: 12),
            _buildEarningsSummaryGrid(summary),
            const SizedBox(height: 24),

            // Deliveries Summary
            _buildSectionHeader('ملخص التوصيلات'),
            const SizedBox(height: 12),
            _buildDeliveriesSummaryGrid(summary),
            const SizedBox(height: 24),

            // Rating Card
            _buildRatingCard(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double available, double pending) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الرصيد المتاح',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () => context.push(AppRoutes.requestWithdrawal),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${available.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'قيد المعالجة: ${pending.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: available > 0
                  ? () => context.push(AppRoutes.requestWithdrawal)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('طلب سحب'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEarningsSummaryGrid(summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'اليوم',
            '${summary.todayEarnings.toStringAsFixed(0)} ج.م',
            Icons.today,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'هذا الأسبوع',
            '${summary.weekEarnings.toStringAsFixed(0)} ج.م',
            Icons.calendar_view_week,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveriesSummaryGrid(summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'اليوم',
            '${summary.todayDeliveries} توصيلة',
            Icons.delivery_dining,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'هذا الأسبوع',
            '${summary.weekDeliveries} توصيلة',
            Icons.local_shipping,
            AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
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
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star,
                color: AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقييمك',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        summary.averageRating.toStringAsFixed(1),
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${summary.totalRatings} تقييم)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rating stars
            Row(
              children: List.generate(5, (index) {
                final rating = summary.averageRating;
                if (index < rating.floor()) {
                  return const Icon(Icons.star, color: AppColors.warning, size: 20);
                } else if (index < rating) {
                  return const Icon(Icons.star_half, color: AppColors.warning, size: 20);
                } else {
                  return Icon(Icons.star_border,
                      color: AppColors.grey300, size: 20);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsTab(WithdrawalsState state) {
    if (state.isLoading && state.requests.isEmpty) {
      return const LoadingIndicator(message: 'جاري تحميل الطلبات...');
    }

    if (state.error != null && state.requests.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.read(withdrawalsProvider.notifier).fetchWithdrawals(),
      );
    }

    if (state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طلبات سحب',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك طلب سحب أرباحك من الرصيد المتاح',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.requestWithdrawal),
              child: const Text('طلب سحب جديد'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(withdrawalsProvider.notifier).fetchWithdrawals(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final request = state.requests[index];
          return _buildWithdrawalCard(request);
        },
      ),
    );
  }

  Widget _buildWithdrawalCard(WithdrawalRequest request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case 'pending':
        statusColor = AppColors.warning;
        statusText = 'قيد المراجعة';
        statusIcon = Icons.schedule;
        break;
      case 'processing':
        statusColor = AppColors.info;
        statusText = 'جاري التنفيذ';
        statusIcon = Icons.sync;
        break;
      case 'completed':
        statusColor = AppColors.success;
        statusText = 'تم التحويل';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.grey500;
        statusText = request.status;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${request.amount.toStringAsFixed(0)} ج.م',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${request.bankName} - ${request.accountNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(request.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.notes!,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
