import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/order.dart';
import '../services/api_service.dart';

/// Single order state
class OrderState {
  final Order? order;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.order,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    Order? order,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Order list state
class OrderListState {
  final List<Order> orders;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  OrderListState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }

  List<Order> get activeOrders =>
      orders.where((o) => o.isActive).toList();

  List<Order> get completedOrders =>
      orders.where((o) => !o.isActive).toList();
}

/// Single order notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final ApiService _apiService;

  OrderNotifier(this._apiService) : super(const OrderState());

  /// Fetch order by ID
  Future<void> fetchOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('${AppEndpoints.orders}/$orderId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final order = Order.fromJson(response.data['data']);
        state = state.copyWith(order: order, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل جلب تفاصيل الطلب',
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

  /// Update order from socket event
  void updateFromSocket(Order updatedOrder) {
    if (state.order?.id == updatedOrder.id) {
      state = state.copyWith(order: updatedOrder);
    }
  }

  /// Update driver location from socket
  void updateDriverLocation(List<double> coordinates) {
    if (state.order?.driver != null) {
      final updatedDriver = state.order!.driver!.copyWith(
        currentLocation: coordinates,
      );
      state = state.copyWith(
        order: state.order!.copyWith(driver: updatedDriver),
      );
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String reason) async {
    if (state.order == null || !state.order!.canCancel) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        '${AppEndpoints.orders}/${state.order!.id}/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedOrder = Order.fromJson(response.data['data']);
        state = state.copyWith(order: updatedOrder, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل إلغاء الطلب',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Rate order
  Future<bool> rateOrder({
    required int rating,
    String? review,
    int? deliveryRating,
  }) async {
    if (state.order == null || state.order!.status != OrderStatus.delivered) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        '${AppEndpoints.orders}/${state.order!.id}/rate',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
          if (deliveryRating != null) 'deliveryRating': deliveryRating,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل تقييم الطلب',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Create a new order
  Future<String?> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String addressId,
    required String paymentMethod,
    String? notes,
    String? couponCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        AppEndpoints.orders,
        data: {
          'restaurantId': restaurantId,
          'items': items,
          'addressId': addressId,
          'paymentMethod': paymentMethod,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final order = Order.fromJson(response.data['data']);
        state = state.copyWith(order: order, isLoading: false);
        return order.id;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل إنشاء الطلب',
        );
        return null;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }
}

/// Order list notifier
class OrderListNotifier extends StateNotifier<OrderListState> {
  final ApiService _apiService;

  OrderListNotifier(this._apiService) : super(const OrderListState());

  /// Fetch orders
  Future<void> fetchOrders({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.page;
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: page,
      orders: refresh ? [] : state.orders,
    );

    try {
      final response = await _apiService.get(
        AppEndpoints.orders,
        queryParameters: {
          'page': page,
          'limit': AppConstants.defaultPageSize,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> ordersJson = response.data['data']['orders'] ?? [];
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        final pagination = response.data['data']['pagination'];
        final hasMore = pagination != null
            ? pagination['page'] < pagination['pages']
            : orders.length >= AppConstants.defaultPageSize;

        state = state.copyWith(
          orders: refresh ? orders : [...state.orders, ...orders],
          isLoading: false,
          hasMore: hasMore,
          page: page + 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل جلب الطلبات',
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

  /// Load more orders
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchOrders();
  }

  /// Refresh orders
  Future<void> refresh() async {
    await fetchOrders(refresh: true);
  }

  /// Update order in list from socket
  void updateOrderInList(Order updatedOrder) {
    final index = state.orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      final updatedOrders = List<Order>.from(state.orders);
      updatedOrders[index] = updatedOrder;
      state = state.copyWith(orders: updatedOrders);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Single order provider (family)
final orderProvider =
    StateNotifierProvider.family<OrderNotifier, OrderState, String>(
  (ref, orderId) {
    final apiService = ref.watch(apiServiceProvider);
    final notifier = OrderNotifier(apiService);
    notifier.fetchOrder(orderId);
    return notifier;
  },
);

/// Order list provider
final orderListProvider =
    StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderListNotifier(apiService);
});

/// Active orders provider
final activeOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderListProvider).activeOrders;
});

/// Completed orders provider
final completedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderListProvider).completedOrders;
});

/// Has active orders provider
final hasActiveOrdersProvider = Provider<bool>((ref) {
  return ref.watch(activeOrdersProvider).isNotEmpty;
});

/// Order creation provider (for checkout)
final orderCreationProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderNotifier(apiService);
});
