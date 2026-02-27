import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../models/order.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isOnline = false;
  bool _isTogglingStatus = false;
  late LocationService _locationService;
  late SocketService _socketService;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _locationService = ref.read(locationServiceProvider);
    _socketService = ref.read(socketServiceProvider);
    _apiService = ref.read(apiServiceProvider);
    _loadData();
  }

  @override
  void dispose() {
    // Stop location tracking on dispose
    _locationService.stopLocationTracking();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(driverStatsProvider.notifier).fetchStats(),
      ref.read(currentOrderProvider.notifier).fetchCurrentOrder(),
    ]);
  }

  Future<void> _toggleOnlineStatus() async {
    setState(() => _isTogglingStatus = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // Get current location first if going online
      if (!_isOnline) {
        final hasPermission = await _locationService.checkAndRequestPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب السماح بالوصول إلى الموقع للعمل')),
            );
          }
          setState(() => _isTogglingStatus = false);
          return;
        }

        final position = await _locationService.getCurrentLocation();
        if (position == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('فشل الحصول على الموقع الحالي')),
            );
          }
          setState(() => _isTogglingStatus = false);
          return;
        }
      }

      // Call API to toggle status
      final response = await _apiService.post(ApiEndpoints.toggleOnline);

      if (response.data['success']) {
        setState(() {
          _isOnline = !_isOnline;
        });

        if (_isOnline) {
          // Emit driver online status via socket
          _socketService.setDriverOnline(user.id);

          // Start location tracking
          await _locationService.startLocationTracking(
            onLocationUpdate: (Position position) {
              // Location updates are automatically sent to server
              // Socket location updates are sent when on active delivery
            },
            onError: (String error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في تتبع الموقع: $error')),
                );
              }
            },
          );

          // Start fetching available orders
          ref.read(availableOrdersProvider.notifier).fetchAvailableOrders();
        } else {
          // Emit driver offline status via socket
          _socketService.setDriverOffline(user.id);

          // Stop location tracking
          _locationService.stopLocationTracking();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isOnline ? 'أنت متصل الآن' : 'أنت غير متصل الآن'),
              backgroundColor: _isOnline ? Colors.green : Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تغيير الحالة: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(driverStatsProvider);
    final currentOrderState = ref.watch(currentOrderProvider);
    final hasActiveOrder = ref.watch(hasActiveOrderProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.driverGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'مرحباً بك',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.notifications),
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isOnline ? 'أنت متصل الآن' : 'أنت غير متصل',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Online Toggle Card
                    _buildOnlineToggleCard(),
                    const SizedBox(height: 16),

                    // Stats Cards
                    _buildStatsSection(statsState.stats),
                    const SizedBox(height: 16),

                    // Current Order Card
                    if (hasActiveOrder && currentOrderState.order != null)
                      _buildCurrentOrderCard(currentOrderState.order!),

                    // Quick Actions
                    if (!hasActiveOrder) ...[
                      _buildQuickActionsSection(),
                      const SizedBox(height: 16),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildOnlineToggleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isOnline
                    ? AppColors.online.withValues(alpha: 0.1)
                    : AppColors.offline.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isOnline ? Icons.power_settings_new : Icons.power_off,
                color: _isOnline ? AppColors.online : AppColors.offline,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnline ? 'متصل' : 'غير متصل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              _isOnline ? AppColors.online : AppColors.offline,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isOnline
                        ? 'أنت جاهز لاستقبال الطلبات'
                        : 'فعّل الاتصال لاستقبال الطلبات',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isOnline,
              onChanged: _isTogglingStatus ? null : (_) => _toggleOnlineStatus(),
              activeThumbColor: AppColors.online,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(DriverStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.delivery_dining,
            title: 'توصيلات اليوم',
            value: stats.todayDeliveries.toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet,
            title: 'أرباح اليوم',
            value: '${stats.todayEarnings.toStringAsFixed(0)} ج.م',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
              child: Icon(icon, color: color, size: 24),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOrderCard(DriverOrder order) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(12),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب نشط #${order.orderNumber}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.statusDisplayName,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Restaurant
              Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.restaurant.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Delivery Address
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress.fullAddress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/orders/${order.id}'),
                  child: Text(_getActionButtonText(order.status)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روابط سريعة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                icon: Icons.history,
                label: 'سجل الطلبات',
                onTap: () => context.push(AppRoutes.orders),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.account_balance_wallet,
                label: 'الأرباح',
                onTap: () => context.push(AppRoutes.earnings),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                icon: Icons.person_outline,
                label: 'الملف الشخصي',
                onTap: () => context.push(AppRoutes.profile),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.support_agent,
                label: 'الدعم',
                onTap: () => context.push(AppRoutes.support),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            context.push(AppRoutes.orders);
            break;
          case 2:
            context.push(AppRoutes.earnings);
            break;
          case 3:
            context.push(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'الطلبات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'الأرباح',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'حسابي',
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.pickedUp:
        return AppColors.statusPickedUp;
      case OrderStatus.onTheWay:
        return AppColors.statusOnTheWay;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.primary;
    }
  }

  String _getActionButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.ready:
        return 'استلام الطلب';
      case OrderStatus.pickedUp:
        return 'بدء التوصيل';
      case OrderStatus.onTheWay:
        return 'تأكيد التسليم';
      default:
        return 'عرض التفاصيل';
    }
  }
}
