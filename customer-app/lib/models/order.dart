import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Order status enum
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
enum OrderPaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('wallet')
  wallet,
}

/// Payment status enum
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

/// Order item model
@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String menuItemId,
    required String name,
    String? nameAr,
    String? image,
    required double price,
    required int quantity,
    @Default([]) List<OrderItemAddon> addons,
    @Default([]) List<OrderItemVariation> variations,
    String? specialInstructions,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  const OrderItem._();

  String get displayName => nameAr ?? name;
  double get total => (price + addonsTotal + variationsTotal) * quantity;
  double get addonsTotal =>
      addons.fold(0.0, (sum, a) => sum + (a.price * a.quantity));
  double get variationsTotal =>
      variations.fold(0.0, (sum, v) => sum + v.price);
}

/// Order item addon
@freezed
class OrderItemAddon with _$OrderItemAddon {
  const factory OrderItemAddon({
    required String name,
    String? nameAr,
    required double price,
    @Default(1) int quantity,
  }) = _OrderItemAddon;

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) =>
      _$OrderItemAddonFromJson(json);
}

/// Order item variation
@freezed
class OrderItemVariation with _$OrderItemVariation {
  const factory OrderItemVariation({
    required String name,
    String? nameAr,
    required String option,
    String? optionAr,
    @Default(0.0) double price,
  }) = _OrderItemVariation;

  factory OrderItemVariation.fromJson(Map<String, dynamic> json) =>
      _$OrderItemVariationFromJson(json);
}

/// Delivery address in order
@freezed
class OrderDeliveryAddress with _$OrderDeliveryAddress {
  const factory OrderDeliveryAddress({
    required String name,
    required String address,
    required String area,
    required String city,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    required List<double> coordinates,
  }) = _OrderDeliveryAddress;

  factory OrderDeliveryAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryAddressFromJson(json);

  const OrderDeliveryAddress._();

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0;
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0;

  String get fullAddress => '$address، $area، $city';
}

/// Driver info in order
@freezed
class OrderDriver with _$OrderDriver {
  const factory OrderDriver({
    required String id,
    required String name,
    String? phone,
    String? avatar,
    double? rating,
    List<double>? currentLocation,
  }) = _OrderDriver;

  factory OrderDriver.fromJson(Map<String, dynamic> json) =>
      _$OrderDriverFromJson(json);

  const OrderDriver._();

  double? get latitude =>
      currentLocation != null && currentLocation!.length > 1
          ? currentLocation![1]
          : null;
  double? get longitude =>
      currentLocation != null && currentLocation!.isNotEmpty
          ? currentLocation![0]
          : null;
}

/// Restaurant info in order
@freezed
class OrderRestaurant with _$OrderRestaurant {
  const factory OrderRestaurant({
    required String id,
    required String name,
    String? nameAr,
    String? logo,
    String? phone,
    List<double>? location,
  }) = _OrderRestaurant;

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) =>
      _$OrderRestaurantFromJson(json);

  const OrderRestaurant._();

  String get displayName => nameAr ?? name;
}

/// Status history entry
@freezed
class OrderStatusHistory with _$OrderStatusHistory {
  const factory OrderStatusHistory({
    required OrderStatus status,
    required DateTime timestamp,
    String? note,
  }) = _OrderStatusHistory;

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryFromJson(json);
}

/// Main Order model
@freezed
class Order with _$Order {
  const factory Order({
    @JsonKey(name: '_id') required String id,
    required String orderNumber,
    required OrderRestaurant restaurant,
    required List<OrderItem> items,
    required OrderDeliveryAddress deliveryAddress,
    required OrderStatus status,
    required OrderPaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
    required double subtotal,
    required double deliveryFee,
    @Default(0.0) double discount,
    required double total,
    OrderDriver? driver,
    String? notes,
    String? cancellationReason,
    DateTime? estimatedDeliveryTime,
    @Default([]) List<OrderStatusHistory> statusHistory,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  const Order._();

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
        return 'في الطريق إليك';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  /// Check if order is active (not completed or cancelled)
  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  /// Check if order can be cancelled
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// Get progress percentage (0-100)
  int get progressPercentage {
    switch (status) {
      case OrderStatus.pending:
        return 10;
      case OrderStatus.confirmed:
        return 25;
      case OrderStatus.preparing:
        return 40;
      case OrderStatus.ready:
        return 55;
      case OrderStatus.pickedUp:
        return 70;
      case OrderStatus.onTheWay:
        return 85;
      case OrderStatus.delivered:
        return 100;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  /// Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
