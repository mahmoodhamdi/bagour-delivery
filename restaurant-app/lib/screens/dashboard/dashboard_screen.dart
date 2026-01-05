import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../orders/orders_screen.dart';
import '../menu/menu_screen.dart';
import '../reviews/reviews_screen.dart';
import '../profile/profile_screen.dart';

/// Dashboard statistics model
class DashboardStats {
  final int todayOrders;
  final double todayRevenue;
  final double averageRating;
  final int totalReviews;
  final int pendingOrders;
  final int preparingOrders;
  final int readyOrders;

  const DashboardStats({
    this.todayOrders = 0,
    this.todayRevenue = 0.0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.pendingOrders = 0,
    this.preparingOrders = 0,
    this.readyOrders = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayOrders: json['todayOrders'] ?? 0,
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      preparingOrders: json['preparingOrders'] ?? 0,
      readyOrders: json['readyOrders'] ?? 0,
    );
  }
}

/// Recent order model for dashboard
class RecentOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String status;
  final double total;
  final int itemCount;
  final DateTime createdAt;

  const RecentOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return RecentOrder(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: customer?['name'] ?? 'عميل',
      status: json['status'] ?? 'pending',
      total: (json['total'] ?? 0).toDouble(),
      itemCount: (json['items'] as List?)?.length ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Dashboard state
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats stats;
  final List<RecentOrder> recentOrders;
  final bool isRestaurantOpen;
  final bool isTogglingStatus;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.stats = const DashboardStats(),
    this.recentOrders = const [],
    this.isRestaurantOpen = true,
    this.isTogglingStatus = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStats? stats,
    List<RecentOrder>? recentOrders,
    bool? isRestaurantOpen,
    bool? isTogglingStatus,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      recentOrders: recentOrders ?? this.recentOrders,
      isRestaurantOpen: isRestaurantOpen ?? this.isRestaurantOpen,
      isTogglingStatus: isTogglingStatus ?? this.isTogglingStatus,
    );
  }
}

/// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _apiService;
  final String? restaurantId;
  Timer? _refreshTimer;

  DashboardNotifier(this._apiService, this.restaurantId)
      : super(const DashboardState()) {
    if (restaurantId != null && restaurantId!.isNotEmpty) {
      fetchDashboardData();
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchDashboardData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchDashboardData({bool showLoading = true}) async {
    if (restaurantId == null || restaurantId!.isEmpty) return;

    if (showLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Fetch dashboard stats
      final statsResponse = await _apiService.get('/restaurant/dashboard');

      DashboardStats stats = const DashboardStats();
      bool isOpen = true;

      if (statsResponse.statusCode == 200 && statsResponse.data['success'] == true) {
        final data = statsResponse.data['data'];
        stats = DashboardStats.fromJson(data);
        isOpen = data['isOpen'] ?? true;
      }

      // Fetch recent orders
      final ordersResponse = await _apiService.get(
        '/restaurant/orders',
        queryParameters: {'limit': 5, 'sort': '-createdAt'},
      );

      List<RecentOrder> recentOrders = [];
      if (ordersResponse.statusCode == 200 && ordersResponse.data['success'] == true) {
        final ordersData = ordersResponse.data['data']['orders'] as List? ??
            ordersResponse.data['data'] as List? ?? [];
        recentOrders = ordersData
            .map((o) => RecentOrder.fromJson(o as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        recentOrders: recentOrders,
        isRestaurantOpen: isOpen,
        error: null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> toggleRestaurantStatus() async {
    if (restaurantId == null || restaurantId!.isEmpty) return;

    state = state.copyWith(isTogglingStatus: true);

    try {
      final newStatus = !state.isRestaurantOpen;
      final response = await _apiService.patch(
        '/restaurant/status',
        data: {'isOpen': newStatus},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        state = state.copyWith(
          isRestaurantOpen: newStatus,
          isTogglingStatus: false,
        );
      } else {
        state = state.copyWith(isTogglingStatus: false);
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isTogglingStatus: false,
        error: _apiService.handleError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isTogglingStatus: false,
        error: 'حدث خطأ في تغيير حالة المطعم',
      );
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }
}

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider.autoDispose<DashboardNotifier, DashboardState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final restaurantId = ref.watch(currentRestaurantIdProvider);
  return DashboardNotifier(apiService, restaurantId);
});

/// Main Dashboard Screen with bottom navigation
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardTabContent(),
          OrdersScreen(),
          MenuScreen(),
          ReviewsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: _buildOrdersBadge(Icons.receipt_long_outlined),
            activeIcon: _buildOrdersBadge(Icons.receipt_long),
            label: 'الطلبات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'القائمة',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'التقييمات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersBadge(IconData icon) {
    final dashboardState = ref.watch(dashboardProvider);
    final pendingCount = dashboardState.stats.pendingOrders;

    if (pendingCount == 0) {
      return Icon(icon);
    }

    return Badge(
      label: Text('$pendingCount'),
      child: Icon(icon),
    );
  }
}

/// Dashboard Tab Content
class DashboardTabContent extends ConsumerWidget {
  const DashboardTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final restaurantName = ref.watch(currentRestaurantNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName ?? AppConstants.appNameAr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dashboardState.error != null
                ? _buildErrorState(context, ref, dashboardState.error!)
                : _buildContent(context, ref, dashboardState),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Status Toggle
          _buildRestaurantStatusCard(context, ref, state),
          const SizedBox(height: 16),

          // Today's Stats
          Text(
            'إحصائيات اليوم',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(context, state.stats),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'إجراءات سريعة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildQuickActions(context, state),
          const SizedBox(height: 24),

          // Recent Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أحدث الطلبات',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.orders),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentOrdersList(context, state.recentOrders),
        ],
      ),
    );
  }

  Widget _buildRestaurantStatusCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.isRestaurantOpen
                    ? AppColors.restaurantOpen
                    : AppColors.restaurantClosed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.isRestaurantOpen ? 'المطعم مفتوح' : 'المطعم مغلق',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: state.isRestaurantOpen
                              ? AppColors.restaurantOpen
                              : AppColors.restaurantClosed,
                        ),
                  ),
                  Text(
                    state.isRestaurantOpen
                        ? 'يمكن للعملاء الطلب الآن'
                        : 'لا يمكن للعملاء الطلب حالياً',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            state.isTogglingStatus
                ? const SizedBox(
                    width: 48,
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Switch(
                    value: state.isRestaurantOpen,
                    onChanged: (_) {
                      _showToggleConfirmation(context, ref, state.isRestaurantOpen);
                    },
                    activeColor: AppColors.restaurantOpen,
                  ),
          ],
        ),
      ),
    );
  }

  void _showToggleConfirmation(
    BuildContext context,
    WidgetRef ref,
    bool currentlyOpen,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentlyOpen ? 'إغلاق المطعم' : 'فتح المطعم'),
        content: Text(
          currentlyOpen
              ? 'هل تريد إغلاق المطعم؟ لن يتمكن العملاء من تقديم طلبات جديدة.'
              : 'هل تريد فتح المطعم؟ سيتمكن العملاء من تقديم الطلبات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(dashboardProvider.notifier).toggleRestaurantStatus();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          icon: Icons.receipt_long,
          iconColor: AppColors.statusConfirmed,
          title: 'الطلبات',
          value: '${stats.todayOrders}',
          subtitle: 'طلب اليوم',
        ),
        _buildStatCard(
          context,
          icon: Icons.payments,
          iconColor: AppColors.revenue,
          title: 'الإيرادات',
          value: '${stats.todayRevenue.toStringAsFixed(0)} ج.م',
          subtitle: 'إيرادات اليوم',
        ),
        _buildStatCard(
          context,
          icon: Icons.star,
          iconColor: AppColors.rating,
          title: 'التقييم',
          value: stats.averageRating.toStringAsFixed(1),
          subtitle: '${stats.totalReviews} تقييم',
        ),
        _buildStatCard(
          context,
          icon: Icons.pending_actions,
          iconColor: AppColors.statusPending,
          title: 'قيد الانتظار',
          value: '${stats.pendingOrders}',
          subtitle: 'طلب جديد',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.receipt_long,
            iconColor: AppColors.statusPending,
            title: 'طلبات جديدة',
            count: state.stats.pendingOrders,
            onTap: () => context.push(AppRoutes.orders),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.restaurant,
            iconColor: AppColors.statusPreparing,
            title: 'قيد التحضير',
            count: state.stats.preparingOrders,
            onTap: () => context.push(AppRoutes.orders),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.check_circle,
            iconColor: AppColors.statusReady,
            title: 'جاهز',
            count: state.stats.readyOrders,
            onTap: () => context.push(AppRoutes.orders),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList(
    BuildContext context,
    List<RecentOrder> orders,
  ) {
    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد طلبات حديثة',
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

    return Column(
      children: orders.map((order) => _buildOrderCard(context, order)).toList(),
    );
  }

  Widget _buildOrderCard(BuildContext context, RecentOrder order) {
    final statusColor = Color(
      AppConstants.orderStatusColors[order.status] ?? 0xFF9E9E9E,
    );
    final statusLabel =
        AppConstants.orderStatusLabels[order.status] ?? order.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: AppRadius.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${order.orderNumber}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.itemCount} عناصر - ${order.total.toStringAsFixed(0)} ج.م',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
