import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

part 'order_provider.freezed.dart';

/// State for available orders list
@freezed
class AvailableOrdersState with _$AvailableOrdersState {
  const factory AvailableOrdersState({
    @Default([]) List<AvailableOrder> orders,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
  }) = _AvailableOrdersState;
}

/// State for current/active order
@freezed
class CurrentOrderState with _$CurrentOrderState {
  const factory CurrentOrderState({
    DriverOrder? order,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
  }) = _CurrentOrderState;
}

/// State for driver statistics
@freezed
class DriverStatsState with _$DriverStatsState {
  const factory DriverStatsState({
    @Default(DriverStats()) DriverStats stats,
    @Default(false) bool isLoading,
    String? error,
  }) = _DriverStatsState;
}

/// State for order history
@freezed
class OrderHistoryState with _$OrderHistoryState {
  const factory OrderHistoryState({
    @Default([]) List<DriverOrder> orders,
    @Default(false) bool isLoading,
    @Default(false) bool hasMore,
    @Default(1) int currentPage,
    String? error,
  }) = _OrderHistoryState;
}

/// Notifier for available orders
class AvailableOrdersNotifier extends StateNotifier<AvailableOrdersState> {
  final ApiService _apiService;

  AvailableOrdersNotifier(this._apiService)
      : super(const AvailableOrdersState());

  Future<void> fetchAvailableOrders({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      error: null,
    );

    try {
      final response = await _apiService.get(ApiEndpoints.availableOrders);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final ordersData = response.data['data']?['orders'] as List<dynamic>? ?? [];
        final orders =
            ordersData.map((o) => AvailableOrder.fromJson(o as Map<String, dynamic>)).toList();

        state = state.copyWith(
          orders: orders,
          isLoading: false,
          isRefreshing: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  void addOrder(AvailableOrder order) {
    state = state.copyWith(orders: [order, ...state.orders]);
  }

  void removeOrder(String orderId) {
    state = state.copyWith(
      orders: state.orders.where((o) => o.id != orderId).toList(),
    );
  }

  void clearOrders() {
    state = const AvailableOrdersState();
  }
}

/// Notifier for current order
class CurrentOrderNotifier extends StateNotifier<CurrentOrderState> {
  final ApiService _apiService;

  CurrentOrderNotifier(this._apiService) : super(const CurrentOrderState());

  Future<void> fetchCurrentOrder() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiEndpoints.currentOrder);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderData = response.data['data']?['order'];
        final order = orderData != null
            ? DriverOrder.fromJson(orderData as Map<String, dynamic>)
            : null;

        state = state.copyWith(
          order: order,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          order: null,
          isLoading: false,
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.post(
        '${ApiEndpoints.acceptOrder}/$orderId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final order = DriverOrder.fromJson(
            response.data['data']['order'] as Map<String, dynamic>);
        state = state.copyWith(
          order: order,
          isUpdating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'فشل في قبول الطلب',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.post(
        '${ApiEndpoints.rejectOrder}/$orderId',
        data: {'reason': reason ?? ''},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        state = state.copyWith(isUpdating: false);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'فشل في رفض الطلب',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  Future<bool> updateOrderStatus(OrderStatus newStatus) async {
    if (state.order == null) return false;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.updateOrderStatus,
        data: {
          'orderId': state.order!.id,
          'status': newStatus.name,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final order = DriverOrder.fromJson(
            response.data['data']['order'] as Map<String, dynamic>);
        state = state.copyWith(
          order: order,
          isUpdating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.data['message'] ?? 'فشل في تحديث الحالة',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  Future<bool> pickUpOrder() async {
    return updateOrderStatus(OrderStatus.pickedUp);
  }

  Future<bool> startDelivery() async {
    return updateOrderStatus(OrderStatus.onTheWay);
  }

  Future<bool> completeDelivery() async {
    final success = await updateOrderStatus(OrderStatus.delivered);
    if (success) {
      state = state.copyWith(order: null);
    }
    return success;
  }

  void setOrder(DriverOrder order) {
    state = state.copyWith(order: order);
  }

  void clearOrder() {
    state = const CurrentOrderState();
  }
}

/// Notifier for driver stats
class DriverStatsNotifier extends StateNotifier<DriverStatsState> {
  final ApiService _apiService;

  DriverStatsNotifier(this._apiService) : super(const DriverStatsState());

  Future<void> fetchStats() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiEndpoints.driverProfile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final statsData = response.data['data']?['stats'];
        final stats = statsData != null
            ? DriverStats.fromJson(statsData as Map<String, dynamic>)
            : const DriverStats();

        state = state.copyWith(
          stats: stats,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  void updateStats(DriverStats stats) {
    state = state.copyWith(stats: stats);
  }
}

/// Notifier for order history
class OrderHistoryNotifier extends StateNotifier<OrderHistoryState> {
  final ApiService _apiService;

  OrderHistoryNotifier(this._apiService) : super(const OrderHistoryState());

  Future<void> fetchHistory({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: page,
    );

    try {
      final response = await _apiService.get(
        ApiEndpoints.orderHistory,
        queryParameters: {
          'page': page,
          'limit': AppConstants.ordersPageSize,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final ordersData = response.data['data']?['orders'] as List<dynamic>? ?? [];
        final orders = ordersData
            .map((o) => DriverOrder.fromJson(o as Map<String, dynamic>))
            .toList();
        final pagination = response.data['data']?['pagination'];
        final hasMore = pagination != null
            ? (pagination['page'] as int) < (pagination['pages'] as int)
            : false;

        state = state.copyWith(
          orders: refresh ? orders : [...state.orders, ...orders],
          isLoading: false,
          hasMore: hasMore,
          currentPage: page,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await fetchHistory();
  }

  void clearHistory() {
    state = const OrderHistoryState();
  }
}

// Providers

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final availableOrdersProvider =
    StateNotifierProvider<AvailableOrdersNotifier, AvailableOrdersState>((ref) {
  return AvailableOrdersNotifier(ref.watch(apiServiceProvider));
});

final currentOrderProvider =
    StateNotifierProvider<CurrentOrderNotifier, CurrentOrderState>((ref) {
  return CurrentOrderNotifier(ref.watch(apiServiceProvider));
});

final driverStatsProvider =
    StateNotifierProvider<DriverStatsNotifier, DriverStatsState>((ref) {
  return DriverStatsNotifier(ref.watch(apiServiceProvider));
});

final orderHistoryProvider =
    StateNotifierProvider<OrderHistoryNotifier, OrderHistoryState>((ref) {
  return OrderHistoryNotifier(ref.watch(apiServiceProvider));
});

/// Provider to check if driver has an active order
final hasActiveOrderProvider = Provider<bool>((ref) {
  final currentOrder = ref.watch(currentOrderProvider);
  return currentOrder.order != null && currentOrder.order!.isActive;
});
