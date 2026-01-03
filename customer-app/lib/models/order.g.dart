// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => OrderItemAddon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map(
                  (e) => OrderItemVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'image': instance.image,
      'price': instance.price,
      'quantity': instance.quantity,
      'addons': instance.addons,
      'variations': instance.variations,
      'specialInstructions': instance.specialInstructions,
    };

_$OrderItemAddonImpl _$$OrderItemAddonImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemAddonImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$OrderItemAddonImplToJson(
        _$OrderItemAddonImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'price': instance.price,
      'quantity': instance.quantity,
    };

_$OrderItemVariationImpl _$$OrderItemVariationImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderItemVariationImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      option: json['option'] as String,
      optionAr: json['optionAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$OrderItemVariationImplToJson(
        _$OrderItemVariationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'option': instance.option,
      'optionAr': instance.optionAr,
      'price': instance.price,
    };

_$OrderDeliveryAddressImpl _$$OrderDeliveryAddressImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderDeliveryAddressImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      city: json['city'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      landmark: json['landmark'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$OrderDeliveryAddressImplToJson(
        _$OrderDeliveryAddressImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'area': instance.area,
      'city': instance.city,
      'building': instance.building,
      'floor': instance.floor,
      'apartment': instance.apartment,
      'landmark': instance.landmark,
      'coordinates': instance.coordinates,
    };

_$OrderDriverImpl _$$OrderDriverImplFromJson(Map<String, dynamic> json) =>
    _$OrderDriverImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      currentLocation: (json['currentLocation'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$OrderDriverImplToJson(_$OrderDriverImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'rating': instance.rating,
      'currentLocation': instance.currentLocation,
    };

_$OrderRestaurantImpl _$$OrderRestaurantImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderRestaurantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      logo: json['logo'] as String?,
      phone: json['phone'] as String?,
      location: (json['location'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$OrderRestaurantImplToJson(
        _$OrderRestaurantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'logo': instance.logo,
      'phone': instance.phone,
      'location': instance.location,
    };

_$OrderStatusHistoryImpl _$$OrderStatusHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderStatusHistoryImpl(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$OrderStatusHistoryImplToJson(
        _$OrderStatusHistoryImpl instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'note': instance.note,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'picked_up',
  OrderStatus.onTheWay: 'on_the_way',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as String,
      restaurant:
          OrderRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: OrderDeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      paymentMethod:
          $enumDecode(_$OrderPaymentMethodEnumMap, json['paymentMethod']),
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      driver: json['driver'] == null
          ? null
          : OrderDriver.fromJson(json['driver'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map(
                  (e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'orderNumber': instance.orderNumber,
      'restaurant': instance.restaurant,
      'items': instance.items,
      'deliveryAddress': instance.deliveryAddress,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'paymentMethod': _$OrderPaymentMethodEnumMap[instance.paymentMethod]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'total': instance.total,
      'driver': instance.driver,
      'notes': instance.notes,
      'cancellationReason': instance.cancellationReason,
      'estimatedDeliveryTime':
          instance.estimatedDeliveryTime?.toIso8601String(),
      'statusHistory': instance.statusHistory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$OrderPaymentMethodEnumMap = {
  OrderPaymentMethod.cash: 'cash',
  OrderPaymentMethod.card: 'card',
  OrderPaymentMethod.wallet: 'wallet',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};
