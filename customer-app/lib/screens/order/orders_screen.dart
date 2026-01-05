import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'widgets/order_history_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _pastScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch orders on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider.notifier).fetchOrders(refresh: true);
    });

    // Setup scroll listeners for infinite scroll
    _activeScrollController.addListener(_onActiveScroll);
    _pastScrollController.addListener(_onPastScroll);
  }

  void _onActiveScroll() {
    if (_activeScrollController.position.pixels >=
        _activeScrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onPastScroll() {
    if (_pastScrollController.position.pixels >=
        _pastScrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(orderListProvider);
    if (!state.isLoading && state.hasMore) {
      ref.read(orderListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeScrollController.dispose();
    _pastScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pending_actions, size: 18),
                  const SizedBox(width: 8),
                  const Text('نشطة'),
                  if (orderState.activeOrders.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${orderState.activeOrders.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  const Text('السابقة'),
                  if (orderState.completedOrders.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${orderState.completedOrders.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(
            context,
            orderState.activeOrders,
            orderState.isLoading,
            orderState.error,
            isActive: true,
            scrollController: _activeScrollController,
          ),
          _buildOrderList(
            context,
            orderState.completedOrders,
            orderState.isLoading,
            orderState.error,
            isActive: false,
            scrollController: _pastScrollController,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<Order> orders,
    bool isLoading,
    String? error, {
    required bool isActive,
    required ScrollController scrollController,
  }) {
    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(orderListProvider.notifier).fetchOrders(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return _buildEmptyState(context, isActive);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: orders.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final order = orders[index];
          return OrderHistoryCard(
            order: order,
            onTap: () => context.push('/order/${order.id}'),
            onReorder: isActive ? null : () => _navigateToReorder(context, order),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isActive) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.pending_actions : Icons.history,
                size: 64,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isActive ? 'لا توجد طلبات نشطة' : 'لا توجد طلبات سابقة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'اطلب الآن من مطاعمك المفضلة واستمتع بتجربة توصيل سريعة'
                  : 'ستظهر طلباتك السابقة هنا بعد اكتمالها',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isActive) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('تصفح المطاعم'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToReorder(BuildContext context, Order order) {
    context.push(
      '/reorder',
      extra: {'order': order},
    );
  }
}
