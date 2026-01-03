import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Order status enum for driver
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('on_the_way')
  onTheWay,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

/// Payment method enum
enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('wallet')
  wallet,
}

/// Order item for driver view
@freezed
class DriverOrderItem with _$DriverOrderItem {
  const factory DriverOrderItem({
    required String name,
    String? nameAr,
    required int quantity,
    required double price,
    String? specialInstructions,
  }) = _DriverOrderItem;

  factory DriverOrderItem.fromJson(Map<String, dynamic> json) =>
      _$DriverOrderItemFromJson(json);

  const DriverOrderItem._();

  String get displayName => nameAr ?? name;
}

/// Restaurant info for order
@freezed
class OrderRestaurant with _$OrderRestaurant {
  const factory OrderRestaurant({
    required String id,
    required String name,
    String? nameAr,
    String? logo,
    required String phone,
    required String address,
    required String area,
    required List<double> location,
  }) = _OrderRestaurant;

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) =>
      _$OrderRestaurantFromJson(json);

  const OrderRestaurant._();

  String get displayName => nameAr ?? name;
  double get latitude => location.length > 1 ? location[1] : 0;
  double get longitude => location.isNotEmpty ? location[0] : 0;
}

/// Customer info for order
@freezed
class OrderCustomer with _$OrderCustomer {
  const factory OrderCustomer({
    required String id,
    required String name,
    required String phone,
  }) = _OrderCustomer;

  factory OrderCustomer.fromJson(Map<String, dynamic> json) =>
      _$OrderCustomerFromJson(json);
}

/// Delivery address
@freezed
class DeliveryAddress with _$DeliveryAddress {
  const factory DeliveryAddress({
    required String name,
    required String address,
    required String area,
    required String city,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    required List<double> coordinates,
  }) = _DeliveryAddress;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressFromJson(json);

  const DeliveryAddress._();

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0;
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0;

  String get fullAddress {
    final parts = <String>[address, area, city];
    if (building != null) parts.add('مبنى $building');
    if (floor != null) parts.add('الدور $floor');
    if (apartment != null) parts.add('شقة $apartment');
    return parts.join('، ');
  }
}

/// Main Order model for driver
@freezed
class DriverOrder with _$DriverOrder {
  const factory DriverOrder({
    @JsonKey(name: '_id') required String id,
    required String orderNumber,
    required OrderRestaurant restaurant,
    required OrderCustomer customer,
    required List<DriverOrderItem> items,
    required DeliveryAddress deliveryAddress,
    required OrderStatus status,
    required PaymentMethod paymentMethod,
    required double subtotal,
    required double deliveryFee,
    @Default(0.0) double discount,
    required double total,
    String? notes,
    String? cancellationReason,
    DateTime? estimatedDeliveryTime,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Driver-specific fields
    double? driverEarnings,
    double? tip,
    double? distanceKm,
  }) = _DriverOrder;

  factory DriverOrder.fromJson(Map<String, dynamic> json) =>
      _$DriverOrderFromJson(json);

  const DriverOrder._();

  /// Get status display name in Arabic
  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.ready:
        return 'جاهز للاستلام';
      case OrderStatus.pickedUp:
        return 'تم الاستلام';
      case OrderStatus.onTheWay:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  /// Check if driver can pick up this order
  bool get canPickUp => status == OrderStatus.ready;

  /// Check if order is being delivered
  bool get isBeingDelivered =>
      status == OrderStatus.pickedUp || status == OrderStatus.onTheWay;

  /// Check if order can be marked as delivered
  bool get canDeliver => status == OrderStatus.onTheWay;

  /// Check if order is active for driver
  bool get isActive =>
      status == OrderStatus.ready ||
      status == OrderStatus.pickedUp ||
      status == OrderStatus.onTheWay;

  /// Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get total earnings including tip
  double get totalEarnings => (driverEarnings ?? 0) + (tip ?? 0);

  /// Get payment method display name
  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.wallet:
        return 'محفظة';
    }
  }
}

/// Available order for driver to accept
@freezed
class AvailableOrder with _$AvailableOrder {
  const factory AvailableOrder({
    @JsonKey(name: '_id') required String id,
    required String orderNumber,
    required OrderRestaurant restaurant,
    required DeliveryAddress deliveryAddress,
    required int itemsCount,
    required double total,
    required PaymentMethod paymentMethod,
    required double deliveryFee,
    double? distanceKm,
    double? estimatedEarnings,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _AvailableOrder;

  factory AvailableOrder.fromJson(Map<String, dynamic> json) =>
      _$AvailableOrderFromJson(json);

  const AvailableOrder._();

  /// Time remaining to accept (if expiresAt is set)
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if order has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// Driver earnings summary
@freezed
class EarningsSummary with _$EarningsSummary {
  const factory EarningsSummary({
    required double todayEarnings,
    required double weekEarnings,
    required double monthEarnings,
    required double totalEarnings,
    required int todayDeliveries,
    required int weekDeliveries,
    required int monthDeliveries,
    required int totalDeliveries,
    required double averageRating,
    required int totalRatings,
    @Default(0.0) double pendingBalance,
    @Default(0.0) double availableBalance,
  }) = _EarningsSummary;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);
}

/// Driver statistics for home screen
@freezed
class DriverStats with _$DriverStats {
  const factory DriverStats({
    @Default(0) int todayDeliveries,
    @Default(0.0) double todayEarnings,
    @Default(0) int pendingOrders,
    @Default(0.0) double rating,
    @Default(0) int totalRatings,
    @Default(0.0) double acceptanceRate,
    @Default(0.0) double completionRate,
  }) = _DriverStats;

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);
}
