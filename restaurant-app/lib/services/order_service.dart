import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import 'api_service.dart';

/// Order item model
class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final String nameAr;
  final int quantity;
  final double price;
  final double total;
  final String? notes;
  final List<OrderItemOption>? options;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.nameAr,
    required this.quantity,
    required this.price,
    required this.total,
    this.notes,
    this.options,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      menuItemId: json['menuItem']?['_id'] ?? json['menuItemId'] ?? '',
      name: json['menuItem']?['name'] ?? json['name'] ?? '',
      nameAr: json['menuItem']?['nameAr'] ?? json['nameAr'] ?? json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? json['price'] ?? 0).toDouble(),
      notes: json['notes'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => OrderItemOption.fromJson(o))
              .toList()
          : null,
    );
  }
}

/// Order item option
class OrderItemOption {
  final String name;
  final String? value;
  final double price;

  OrderItemOption({
    required this.name,
    this.value,
    this.price = 0,
  });

  factory OrderItemOption.fromJson(Map<String, dynamic> json) {
    return OrderItemOption(
      name: json['name'] ?? '',
      value: json['value'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

/// Customer info in order
class OrderCustomer {
  final String id;
  final String name;
  final String phone;
  final String? email;

  OrderCustomer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}

/// Delivery address
class DeliveryAddress {
  final String? label;
  final String address;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? instructions;
  final double? latitude;
  final double? longitude;

  DeliveryAddress({
    this.label,
    required this.address,
    this.building,
    this.floor,
    this.apartment,
    this.instructions,
    this.latitude,
    this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: json['label'],
      address: json['address'] ?? '',
      building: json['building'],
      floor: json['floor'],
      apartment: json['apartment'],
      instructions: json['instructions'],
      latitude: json['location']?['coordinates']?[1]?.toDouble(),
      longitude: json['location']?['coordinates']?[0]?.toDouble(),
    );
  }
}

/// Order model
class Order {
  final String id;
  final String orderNumber;
  final OrderCustomer customer;
  final List<OrderItem> items;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final DeliveryAddress? deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryAddress,
    this.notes,
    required this.createdAt,
    this.confirmedAt,
    this.preparingAt,
    this.readyAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customer: OrderCustomer.fromJson(json['customer'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: json['status'] ?? 'pending',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      preparingAt: json['preparingAt'] != null
          ? DateTime.parse(json['preparingAt'])
          : null,
      readyAt: json['readyAt'] != null ? DateTime.parse(json['readyAt']) : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
    );
  }

  String get statusLabel => AppConstants.orderStatusLabels[status] ?? status;
}

/// Orders list response with pagination
class OrdersResponse {
  final List<Order> orders;
  final int total;
  final int page;
  final int pages;

  OrdersResponse({
    required this.orders,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] ?? json['data'] ?? [])
          .map<Order>((o) => Order.fromJson(o))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

/// Order statistics
class OrderStats {
  final int total;
  final int pending;
  final int confirmed;
  final int preparing;
  final int ready;
  final int delivered;
  final int cancelled;
  final double totalRevenue;
  final double averageOrderValue;

  OrderStats({
    this.total = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.preparing = 0,
    this.ready = 0,
    this.delivered = 0,
    this.cancelled = 0,
    this.totalRevenue = 0,
    this.averageOrderValue = 0,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      preparing: json['preparing'] ?? 0,
      ready: json['ready'] ?? 0,
      delivered: json['delivered'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }
}

/// Order service for order operations
class OrderService {
  final ApiService _api;

  OrderService(this._api);

  /// Get orders with pagination and filters
  Future<OrdersResponse> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _api.get(
        AppEndpoints.orders,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return OrdersResponse.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب الطلبات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get single order details
  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _api.get('${AppEndpoints.orders}/$orderId');

      if (response.data['success'] == true) {
        return Order.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب تفاصيل الطلب');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus(String orderId, String status,
      {String? reason}) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (reason != null) data['cancellationReason'] = reason;

      final response = await _api.put(
        '${AppEndpoints.orders}/$orderId/status',
        data: data,
      );

      if (response.data['success'] == true) {
        return Order.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث حالة الطلب');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Confirm order
  Future<Order> confirmOrder(String orderId) async {
    return updateOrderStatus(orderId, 'confirmed');
  }

  /// Start preparing order
  Future<Order> startPreparingOrder(String orderId) async {
    return updateOrderStatus(orderId, 'preparing');
  }

  /// Mark order as ready
  Future<Order> markOrderReady(String orderId) async {
    return updateOrderStatus(orderId, 'ready');
  }

  /// Cancel order
  Future<Order> cancelOrder(String orderId, String reason) async {
    return updateOrderStatus(orderId, 'cancelled', reason: reason);
  }

  /// Get order statistics
  Future<OrderStats> getOrderStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _api.get(
        '${AppEndpoints.orders}/stats',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return OrderStats.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب إحصائيات الطلبات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get today's orders
  Future<OrdersResponse> getTodayOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getOrders(startDate: startOfDay, limit: 100);
  }

  /// Get pending orders count
  Future<int> getPendingOrdersCount() async {
    final response = await getOrders(status: 'pending', limit: 1);
    return response.total;
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }
    }
    return Exception('حدث خطأ ما');
  }
}

/// Order service provider
final orderServiceProvider = Provider<OrderService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderService(apiService);
});

/// Orders list provider with filters
final ordersProvider = FutureProvider.family
    .autoDispose<OrdersResponse, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrders(
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
    status: params['status'],
    search: params['search'],
    startDate: params['startDate'],
    endDate: params['endDate'],
  );
});

/// Single order provider
final orderProvider =
    FutureProvider.family.autoDispose<Order, String>((ref, orderId) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrder(orderId);
});

/// Today's orders provider
final todayOrdersProvider =
    FutureProvider.autoDispose<OrdersResponse>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return service.getTodayOrders();
});

/// Order stats provider
final orderStatsProvider =
    FutureProvider.autoDispose<OrderStats>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrderStats();
});
