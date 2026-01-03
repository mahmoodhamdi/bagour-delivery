// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverOrderItemImpl _$$DriverOrderItemImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverOrderItemImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$$DriverOrderItemImplToJson(
        _$DriverOrderItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'quantity': instance.quantity,
      'price': instance.price,
      'specialInstructions': instance.specialInstructions,
    };

_$OrderRestaurantImpl _$$OrderRestaurantImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderRestaurantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      logo: json['logo'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      location: (json['location'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
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
      'address': instance.address,
      'area': instance.area,
      'location': instance.location,
    };

_$OrderCustomerImpl _$$OrderCustomerImplFromJson(Map<String, dynamic> json) =>
    _$OrderCustomerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$$OrderCustomerImplToJson(_$OrderCustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
    };

_$DeliveryAddressImpl _$$DeliveryAddressImplFromJson(
        Map<String, dynamic> json) =>
    _$DeliveryAddressImpl(
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

Map<String, dynamic> _$$DeliveryAddressImplToJson(
        _$DeliveryAddressImpl instance) =>
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

_$DriverOrderImpl _$$DriverOrderImplFromJson(Map<String, dynamic> json) =>
    _$DriverOrderImpl(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as String,
      restaurant:
          OrderRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      customer:
          OrderCustomer.fromJson(json['customer'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => DriverOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: DeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      driverEarnings: (json['driverEarnings'] as num?)?.toDouble(),
      tip: (json['tip'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$DriverOrderImplToJson(_$DriverOrderImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'orderNumber': instance.orderNumber,
      'restaurant': instance.restaurant,
      'customer': instance.customer,
      'items': instance.items,
      'deliveryAddress': instance.deliveryAddress,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'total': instance.total,
      'notes': instance.notes,
      'cancellationReason': instance.cancellationReason,
      'estimatedDeliveryTime':
          instance.estimatedDeliveryTime?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'driverEarnings': instance.driverEarnings,
      'tip': instance.tip,
      'distanceKm': instance.distanceKm,
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

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.wallet: 'wallet',
};

_$AvailableOrderImpl _$$AvailableOrderImplFromJson(Map<String, dynamic> json) =>
    _$AvailableOrderImpl(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as String,
      restaurant:
          OrderRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      deliveryAddress: DeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>),
      itemsCount: (json['itemsCount'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      estimatedEarnings: (json['estimatedEarnings'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$AvailableOrderImplToJson(
        _$AvailableOrderImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'orderNumber': instance.orderNumber,
      'restaurant': instance.restaurant,
      'deliveryAddress': instance.deliveryAddress,
      'itemsCount': instance.itemsCount,
      'total': instance.total,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'deliveryFee': instance.deliveryFee,
      'distanceKm': instance.distanceKm,
      'estimatedEarnings': instance.estimatedEarnings,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_$EarningsSummaryImpl _$$EarningsSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$EarningsSummaryImpl(
      todayEarnings: (json['todayEarnings'] as num).toDouble(),
      weekEarnings: (json['weekEarnings'] as num).toDouble(),
      monthEarnings: (json['monthEarnings'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      todayDeliveries: (json['todayDeliveries'] as num).toInt(),
      weekDeliveries: (json['weekDeliveries'] as num).toInt(),
      monthDeliveries: (json['monthDeliveries'] as num).toInt(),
      totalDeliveries: (json['totalDeliveries'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$EarningsSummaryImplToJson(
        _$EarningsSummaryImpl instance) =>
    <String, dynamic>{
      'todayEarnings': instance.todayEarnings,
      'weekEarnings': instance.weekEarnings,
      'monthEarnings': instance.monthEarnings,
      'totalEarnings': instance.totalEarnings,
      'todayDeliveries': instance.todayDeliveries,
      'weekDeliveries': instance.weekDeliveries,
      'monthDeliveries': instance.monthDeliveries,
      'totalDeliveries': instance.totalDeliveries,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'pendingBalance': instance.pendingBalance,
      'availableBalance': instance.availableBalance,
    };

_$DriverStatsImpl _$$DriverStatsImplFromJson(Map<String, dynamic> json) =>
    _$DriverStatsImpl(
      todayDeliveries: (json['todayDeliveries'] as num?)?.toInt() ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DriverStatsImplToJson(_$DriverStatsImpl instance) =>
    <String, dynamic>{
      'todayDeliveries': instance.todayDeliveries,
      'todayEarnings': instance.todayEarnings,
      'pendingOrders': instance.pendingOrders,
      'rating': instance.rating,
      'totalRatings': instance.totalRatings,
      'acceptanceRate': instance.acceptanceRate,
      'completionRate': instance.completionRate,
    };
