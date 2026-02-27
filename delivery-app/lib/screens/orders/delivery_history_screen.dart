import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';

class DeliveryHistoryScreen extends ConsumerStatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  ConsumerState<DeliveryHistoryScreen> createState() =>
      _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends ConsumerState<DeliveryHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderHistoryProvider.notifier).loadMore();
    }
  }

  Future<void> _loadHistory() async {
    await ref.read(orderHistoryProvider.notifier).fetchHistory(refresh: true);
  }

  List<DriverOrder> _filterOrders(List<DriverOrder> orders) {
    switch (_selectedFilter) {
      case 'delivered':
        return orders.where((o) => o.status == OrderStatus.delivered).toList();
      case 'cancelled':
        return orders.where((o) => o.status == OrderStatus.cancelled).toList();
      case 'today':
        final today = DateTime.now();
        return orders.where((o) =>
            o.createdAt.day == today.day &&
            o.createdAt.month == today.month &&
            o.createdAt.year == today.year).toList();
      case 'week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return orders.where((o) => o.createdAt.isAfter(weekAgo)).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التوصيلات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _buildBody(historyState),
    );
  }

  Widget _buildBody(OrderHistoryState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingIndicator(message: 'جاري تحميل السجل...');
    }

    if (state.error != null && state.orders.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: _loadHistory,
      );
    }

    final filteredOrders = _filterOrders(state.orders);

    if (filteredOrders.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'لا توجد توصيلات',
        message: _selectedFilter == 'all'
            ? 'لم تقم بأي توصيلات بعد'
            : 'لا توجد توصيلات تطابق الفلتر المحدد',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'الكل',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                _FilterChip(
                  label: 'اليوم',
                  isSelected: _selectedFilter == 'today',
                  onTap: () => setState(() => _selectedFilter = 'today'),
                ),
                _FilterChip(
                  label: 'هذا الأسبوع',
                  isSelected: _selectedFilter == 'week',
                  onTap: () => setState(() => _selectedFilter = 'week'),
                ),
                _FilterChip(
                  label: 'تم التوصيل',
                  isSelected: _selectedFilter == 'delivered',
                  onTap: () => setState(() => _selectedFilter = 'delivered'),
                ),
                _FilterChip(
                  label: 'ملغي',
                  isSelected: _selectedFilter == 'cancelled',
                  onTap: () => setState(() => _selectedFilter = 'cancelled'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Summary Card
          _buildSummaryCard(filteredOrders),

          // Orders List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredOrders.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final order = filteredOrders[index];
                return _DeliveryHistoryCard(
                  order: order,
                  onTap: () => context.push(
                    '/orders/history/${order.id}',
                    extra: order,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<DriverOrder> orders) {
    final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;
    final totalEarnings = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold<double>(0, (sum, o) => sum + o.totalEarnings);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            icon: Icons.delivery_dining,
            value: deliveredCount.toString(),
            label: 'توصيلة',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _SummaryItem(
            icon: Icons.payments,
            value: '${totalEarnings.toStringAsFixed(0)} ج.م',
            label: 'إجمالي الأرباح',
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'فلتر التوصيلات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('جميع التوصيلات'),
              trailing: _selectedFilter == 'all'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedFilter = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('اليوم'),
              trailing: _selectedFilter == 'today'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedFilter = 'today');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('هذا الأسبوع'),
              trailing: _selectedFilter == 'week'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedFilter = 'week');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: const Text('تم التوصيل'),
              trailing: _selectedFilter == 'delivered'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedFilter = 'delivered');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColors.error),
              title: const Text('ملغي'),
              trailing: _selectedFilter == 'cancelled'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedFilter = 'cancelled');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DeliveryHistoryCard extends StatelessWidget {
  final DriverOrder order;
  final VoidCallback onTap;

  const _DeliveryHistoryCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDelivered
                              ? AppColors.success.withValues(alpha: 0.1)
                              : isCancelled
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDelivered
                              ? Icons.check_circle
                              : isCancelled
                                  ? Icons.cancel
                                  : Icons.receipt_long,
                          color: isDelivered
                              ? AppColors.success
                              : isCancelled
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _formatDate(order.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? AppColors.success.withValues(alpha: 0.1)
                          : isCancelled
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.grey100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDelivered
                            ? AppColors.success
                            : isCancelled
                                ? AppColors.error
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Restaurant & Customer Info
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.restaurant,
                      label: 'المطعم',
                      value: order.restaurant.displayName,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.grey200,
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.location_on,
                      label: 'التوصيل',
                      value: order.deliveryAddress.area,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Earnings Row
              if (isDelivered)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.payments,
                            color: AppColors.success,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('أرباحك'),
                        ],
                      ),
                      Text(
                        '${order.totalEarnings.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
