import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order/available_order_card.dart';
import '../../widgets/order/order_details_sheet.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_indicator.dart';

class AvailableOrdersScreen extends ConsumerStatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  ConsumerState<AvailableOrdersScreen> createState() =>
      _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends ConsumerState<AvailableOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadOrders(refresh: true);
    });
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    await Future.wait([
      ref.read(availableOrdersProvider.notifier).fetchAvailableOrders(refresh: refresh),
      ref.read(currentOrderProvider.notifier).fetchCurrentOrder(),
    ]);
  }

  void _showOrderDetails(AvailableOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(
        order: order,
        onAccept: () => _acceptOrder(order),
        onReject: () => _rejectOrder(order),
      ),
    );
  }

  Future<void> _acceptOrder(AvailableOrder order) async {
    Navigator.of(context).pop(); // Close bottom sheet

    final success = await ref.read(currentOrderProvider.notifier).acceptOrder(order.id);

    if (success && mounted) {
      ref.read(availableOrdersProvider.notifier).removeOrder(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الطلب بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.activeOrder);
    } else if (mounted) {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في قبول الطلب'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectOrder(AvailableOrder order) async {
    final reason = await _showRejectReasonDialog();
    if (reason == null) return;

    Navigator.of(context).pop(); // Close bottom sheet

    final success = await ref.read(currentOrderProvider.notifier).rejectOrder(
      order.id,
      reason: reason,
    );

    if (success && mounted) {
      ref.read(availableOrdersProvider.notifier).removeOrder(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفض الطلب'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else if (mounted) {
      final error = ref.read(currentOrderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل في رفض الطلب'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    String? selectedReason;
    final reasons = [
      'بعيد جداً',
      'غير متاح حالياً',
      'مشكلة في المركبة',
      'سبب آخر',
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((reason) {
              return RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) => setState(() => selectedReason = value),
                title: Text(reason),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: selectedReason != null
                ? () => Navigator.of(context).pop(selectedReason)
                : null,
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableOrdersState = ref.watch(availableOrdersProvider);
    final currentOrderState = ref.watch(currentOrderProvider);
    final hasActiveOrder = ref.watch(hasActiveOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'الطلبات المتاحة'),
            Tab(text: 'سجل الطلبات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Available Orders Tab
          _buildAvailableOrdersTab(availableOrdersState, hasActiveOrder),

          // Order History Tab
          _buildOrderHistoryTab(),
        ],
      ),

      // Show active order floating button if there's one
      floatingActionButton: hasActiveOrder && currentOrderState.order != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/orders/${currentOrderState.order!.id}'),
              icon: const Icon(Icons.delivery_dining),
              label: const Text('الطلب النشط'),
              backgroundColor: AppColors.success,
            )
          : null,
    );
  }

  Widget _buildAvailableOrdersTab(
    AvailableOrdersState state,
    bool hasActiveOrder,
  ) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingIndicator(message: 'جاري تحميل الطلبات...');
    }

    if (state.error != null && state.orders.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: () => _loadOrders(refresh: true),
      );
    }

    if (state.orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبات متاحة',
        subtitle: hasActiveOrder
            ? 'لديك طلب نشط حالياً. أكمل التوصيل أولاً.'
            : 'سيتم إشعارك عند توفر طلبات جديدة',
        actionLabel: hasActiveOrder ? 'عرض الطلب النشط' : null,
        onAction: hasActiveOrder ? () => context.push(AppRoutes.activeOrder) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.orders.length + (hasActiveOrder ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasActiveOrder && index == 0) {
            return _buildActiveOrderBanner();
          }

          final orderIndex = hasActiveOrder ? index - 1 : index;
          final order = state.orders[orderIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AvailableOrderCard(
              order: order,
              onTap: () => _showOrderDetails(order),
              onAccept: hasActiveOrder ? null : () => _acceptOrder(order),
              enabled: !hasActiveOrder,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrderBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لديك طلب نشط',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'أكمل التوصيل الحالي قبل قبول طلبات جديدة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.activeOrder),
            child: const Text('عرض'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final historyState = ref.watch(orderHistoryProvider);

        if (historyState.isLoading && historyState.orders.isEmpty) {
          return const LoadingIndicator(message: 'جاري تحميل السجل...');
        }

        if (historyState.error != null && historyState.orders.isEmpty) {
          return ErrorState(
            message: historyState.error!,
            onRetry: () => ref.read(orderHistoryProvider.notifier).fetchHistory(refresh: true),
          );
        }

        if (historyState.orders.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'لا يوجد سجل طلبات',
            subtitle: 'سيظهر هنا سجل الطلبات التي قمت بتوصيلها',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(orderHistoryProvider.notifier).fetchHistory(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyState.orders.length + (historyState.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == historyState.orders.length) {
                // Load more indicator
                if (!historyState.isLoading) {
                  ref.read(orderHistoryProvider.notifier).loadMore();
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final order = historyState.orders[index];
              return _buildHistoryOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryOrderCard(DriverOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.restaurant.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    '${order.totalEarnings.toStringAsFixed(0)} ج.م',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
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

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'تم التوصيل';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'ملغي';
        break;
      default:
        color = AppColors.primary;
        text = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
