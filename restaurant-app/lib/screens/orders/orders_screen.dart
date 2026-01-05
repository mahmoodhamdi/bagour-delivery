import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

/// Order model for restaurant app
class RestaurantOrder {
  final String id;
  final String orderNumber;
  final String status;
  final String customerName;
  final String? customerPhone;
  final String? customerAvatar;
  final List<OrderItemData> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final DeliveryAddressData? deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RestaurantOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.customerName,
    this.customerPhone,
    this.customerAvatar,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,
    this.deliveryAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final itemsList = (json['items'] as List?)
            ?.map((i) => OrderItemData.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return RestaurantOrder(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'pending',
      customerName: customer?['name'] ?? 'عميل',
      customerPhone: customer?['phone'],
      customerAvatar: customer?['avatar'],
      items: itemsList,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      notes: json['notes'],
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddressData.fromJson(json['deliveryAddress'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusLabel =>
      AppConstants.orderStatusLabels[status] ?? status;

  Color get statusColor =>
      Color(AppConstants.orderStatusColors[status] ?? 0xFF9E9E9E);

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash':
        return 'الدفع عند الاستلام';
      case 'card':
        return 'بطاقة ائتمان';
      case 'wallet':
        return 'المحفظة';
      default:
        return paymentMethod;
    }
  }

  bool get canAccept => status == 'pending';
  bool get canReject => status == 'pending';
  bool get canStartPreparing => status == 'confirmed';
  bool get canMarkReady => status == 'preparing';
}

/// Order item data
class OrderItemData {
  final String menuItemId;
  final String name;
  final String? nameAr;
  final String? image;
  final double price;
  final int quantity;
  final List<OrderAddonData> addons;
  final List<OrderVariationData> variations;
  final String? specialInstructions;

  const OrderItemData({
    required this.menuItemId,
    required this.name,
    this.nameAr,
    this.image,
    required this.price,
    required this.quantity,
    required this.addons,
    required this.variations,
    this.specialInstructions,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    return OrderItemData(
      menuItemId: json['menuItem']?['_id'] ?? json['menuItemId'] ?? '',
      name: json['menuItem']?['name'] ?? json['name'] ?? '',
      nameAr: json['menuItem']?['nameAr'] ?? json['nameAr'],
      image: json['menuItem']?['image'] ?? json['image'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      addons: (json['addons'] as List?)
              ?.map((a) => OrderAddonData.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      variations: (json['variations'] as List?)
              ?.map(
                  (v) => OrderVariationData.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'],
    );
  }

  String get displayName => nameAr ?? name;

  double get itemTotal {
    final addonsTotal = addons.fold(0.0, (sum, a) => sum + (a.price * a.quantity));
    final variationsTotal = variations.fold(0.0, (sum, v) => sum + v.price);
    return (price + addonsTotal + variationsTotal) * quantity;
  }
}

/// Order addon data
class OrderAddonData {
  final String name;
  final String? nameAr;
  final double price;
  final int quantity;

  const OrderAddonData({
    required this.name,
    this.nameAr,
    required this.price,
    this.quantity = 1,
  });

  factory OrderAddonData.fromJson(Map<String, dynamic> json) {
    return OrderAddonData(
      name: json['name'] ?? '',
      nameAr: json['nameAr'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  String get displayName => nameAr ?? name;
}

/// Order variation data
class OrderVariationData {
  final String name;
  final String? nameAr;
  final String option;
  final String? optionAr;
  final double price;

  const OrderVariationData({
    required this.name,
    this.nameAr,
    required this.option,
    this.optionAr,
    this.price = 0,
  });

  factory OrderVariationData.fromJson(Map<String, dynamic> json) {
    return OrderVariationData(
      name: json['name'] ?? '',
      nameAr: json['nameAr'],
      option: json['option'] ?? '',
      optionAr: json['optionAr'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  String get displayName => nameAr ?? name;
  String get displayOption => optionAr ?? option;
}

/// Delivery address data
class DeliveryAddressData {
  final String name;
  final String address;
  final String area;
  final String city;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark;

  const DeliveryAddressData({
    required this.name,
    required this.address,
    required this.area,
    required this.city,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
  });

  factory DeliveryAddressData.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressData(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      building: json['building'],
      floor: json['floor'],
      apartment: json['apartment'],
      landmark: json['landmark'],
    );
  }

  String get fullAddress => '$address، $area، $city';
}

/// Orders state
class OrdersState {
  final bool isLoading;
  final String? error;
  final List<RestaurantOrder> allOrders;
  final String? updatingOrderId;

  const OrdersState({
    this.isLoading = false,
    this.error,
    this.allOrders = const [],
    this.updatingOrderId,
  });

  OrdersState copyWith({
    bool? isLoading,
    String? error,
    List<RestaurantOrder>? allOrders,
    String? updatingOrderId,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allOrders: allOrders ?? this.allOrders,
      updatingOrderId: updatingOrderId,
    );
  }

  List<RestaurantOrder> get newOrders =>
      allOrders.where((o) => o.status == 'pending').toList();

  List<RestaurantOrder> get preparingOrders =>
      allOrders.where((o) => o.status == 'confirmed' || o.status == 'preparing').toList();

  List<RestaurantOrder> get readyOrders =>
      allOrders.where((o) => o.status == 'ready').toList();

  List<RestaurantOrder> get historyOrders => allOrders
      .where((o) =>
          o.status == 'picked_up' ||
          o.status == 'on_the_way' ||
          o.status == 'delivered' ||
          o.status == 'cancelled')
      .toList();
}

/// Orders notifier
class OrdersNotifier extends StateNotifier<OrdersState> {
  final ApiService _apiService;
  final String? restaurantId;
  Timer? _refreshTimer;

  OrdersNotifier(this._apiService, this.restaurantId) : super(const OrdersState()) {
    if (restaurantId != null && restaurantId!.isNotEmpty) {
      fetchOrders();
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchOrders(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchOrders({bool showLoading = true}) async {
    if (restaurantId == null || restaurantId!.isEmpty) return;

    if (showLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiService.get(
        '/restaurant/orders',
        queryParameters: {'limit': 100, 'sort': '-createdAt'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final ordersData = response.data['data']['orders'] as List? ??
            response.data['data'] as List? ??
            [];
        final orders = ordersData
            .map((o) => RestaurantOrder.fromJson(o as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          allOrders: orders,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل في تحميل الطلبات',
        );
      }
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

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    state = state.copyWith(updatingOrderId: orderId);

    try {
      final response = await _apiService.patch(
        '/restaurant/orders/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update the order in the list
        final updatedOrders = state.allOrders.map((order) {
          if (order.id == orderId) {
            return RestaurantOrder.fromJson(response.data['data']);
          }
          return order;
        }).toList();

        state = state.copyWith(
          allOrders: updatedOrders,
          updatingOrderId: null,
        );
        return true;
      }

      state = state.copyWith(updatingOrderId: null);
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        updatingOrderId: null,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        updatingOrderId: null,
        error: 'حدث خطأ في تحديث حالة الطلب',
      );
      return false;
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    return updateOrderStatus(orderId, 'confirmed');
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    state = state.copyWith(updatingOrderId: orderId);

    try {
      final response = await _apiService.patch(
        '/restaurant/orders/$orderId/status',
        data: {
          'status': 'cancelled',
          'cancellationReason': reason,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedOrders = state.allOrders.map((order) {
          if (order.id == orderId) {
            return RestaurantOrder.fromJson(response.data['data']);
          }
          return order;
        }).toList();

        state = state.copyWith(
          allOrders: updatedOrders,
          updatingOrderId: null,
        );
        return true;
      }

      state = state.copyWith(updatingOrderId: null);
      return false;
    } catch (e) {
      state = state.copyWith(updatingOrderId: null);
      return false;
    }
  }

  Future<bool> startPreparing(String orderId) async {
    return updateOrderStatus(orderId, 'preparing');
  }

  Future<bool> markReady(String orderId) async {
    return updateOrderStatus(orderId, 'ready');
  }

  Future<void> refresh() async {
    await fetchOrders();
  }
}

/// Orders provider
final ordersProvider =
    StateNotifierProvider.autoDispose<OrdersNotifier, OrdersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final restaurantId = ref.watch(currentRestaurantIdProvider);
  return OrdersNotifier(apiService, restaurantId);
});

/// Orders Screen
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _buildTab('جديدة', ordersState.newOrders.length, AppColors.statusPending),
            _buildTab('قيد التحضير', ordersState.preparingOrders.length, AppColors.statusPreparing),
            _buildTab('جاهزة', ordersState.readyOrders.length, AppColors.statusReady),
            _buildTab('السجل', ordersState.historyOrders.length, AppColors.grey500),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrdersListView(
            orders: ordersState.newOrders,
            isLoading: ordersState.isLoading,
            error: ordersState.error,
            emptyMessage: 'لا توجد طلبات جديدة',
            emptyIcon: Icons.inbox_outlined,
            updatingOrderId: ordersState.updatingOrderId,
          ),
          _OrdersListView(
            orders: ordersState.preparingOrders,
            isLoading: ordersState.isLoading,
            error: ordersState.error,
            emptyMessage: 'لا توجد طلبات قيد التحضير',
            emptyIcon: Icons.restaurant_outlined,
            updatingOrderId: ordersState.updatingOrderId,
          ),
          _OrdersListView(
            orders: ordersState.readyOrders,
            isLoading: ordersState.isLoading,
            error: ordersState.error,
            emptyMessage: 'لا توجد طلبات جاهزة',
            emptyIcon: Icons.check_circle_outline,
            updatingOrderId: ordersState.updatingOrderId,
          ),
          _OrdersListView(
            orders: ordersState.historyOrders,
            isLoading: ordersState.isLoading,
            error: ordersState.error,
            emptyMessage: 'لا توجد طلبات سابقة',
            emptyIcon: Icons.history,
            updatingOrderId: ordersState.updatingOrderId,
            isHistory: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
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
    );
  }
}

/// Orders List View
class _OrdersListView extends ConsumerWidget {
  final List<RestaurantOrder> orders;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? updatingOrderId;
  final bool isHistory;

  const _OrdersListView({
    required this.orders,
    required this.isLoading,
    this.error,
    required this.emptyMessage,
    required this.emptyIcon,
    this.updatingOrderId,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && orders.isEmpty) {
      return _buildErrorState(context, ref, error!);
    }

    if (orders.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            isUpdating: updatingOrderId == order.id,
            isHistory: isHistory,
          );
        },
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(ordersProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon, size: 48, color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Card
class _OrderCard extends ConsumerWidget {
  final RestaurantOrder order;
  final bool isUpdating;
  final bool isHistory;

  const _OrderCard({
    required this.order,
    this.isUpdating = false,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: AppRadius.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${order.orderNumber}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: order.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: order.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Customer Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.grey200,
                    backgroundImage: order.customerAvatar != null
                        ? NetworkImage(order.customerAvatar!)
                        : null,
                    child: order.customerAvatar == null
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
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
                        if (order.deliveryAddress != null)
                          Text(
                            order.deliveryAddress!.area,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (order.customerPhone != null && !isHistory)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () => _callCustomer(context, order.customerPhone!),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Items Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.itemCount} عناصر',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    ...order.items.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.displayName,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (order.items.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${order.items.length - 3} عناصر أخرى',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),

              // Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 24),

              // Footer - Total and Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        order.paymentMethod == 'cash'
                            ? Icons.payments
                            : Icons.credit_card,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentMethodLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} ج.م',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),

              // Action Buttons
              if (!isHistory) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context, ref),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    if (isUpdating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (order.canAccept) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, ref),
              icon: const Icon(Icons.close),
              label: const Text('رفض'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () async {
                final success =
                    await ref.read(ordersProvider.notifier).acceptOrder(order.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم قبول الطلب بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('قبول الطلب'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          ),
        ],
      );
    }

    if (order.canStartPreparing) {
      return FilledButton.icon(
        onPressed: () async {
          final success =
              await ref.read(ordersProvider.notifier).startPreparing(order.id);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم بدء تحضير الطلب'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.restaurant),
        label: const Text('بدء التحضير'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.statusPreparing,
        ),
      );
    }

    if (order.canMarkReady) {
      return FilledButton.icon(
        onPressed: () async {
          final success =
              await ref.read(ordersProvider.notifier).markReady(order.id);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تجهيز الطلب'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('الطلب جاهز'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.statusReady,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من رفض هذا الطلب؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                hintText: 'اختياري',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(ordersProvider.notifier)
                  .rejectOrder(order.id, reasonController.text);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم رفض الطلب'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('رفض الطلب'),
          ),
        ],
      ),
    );
  }

  void _callCustomer(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الاتصال بـ $phone'),
        action: SnackBarAction(
          label: 'اتصال',
          onPressed: () {
            // Launch phone dialer - would use url_launcher in real app
          },
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
      return 'منذ ${diff.inMinutes} د';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} س';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
