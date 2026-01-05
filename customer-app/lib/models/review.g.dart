// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      restaurantId: json['restaurantId'] as String,
      driverId: json['driverId'] as String?,
      restaurantRating: (json['restaurantRating'] as num).toDouble(),
      foodRating: (json['foodRating'] as num).toDouble(),
      driverRating: (json['driverRating'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      restaurantReply: json['restaurantReply'] as String?,
      repliedAt: json['repliedAt'] == null
          ? null
          : DateTime.parse(json['repliedAt'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
      isReported: json['isReported'] as bool? ?? false,
      reportReason: json['reportReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'restaurantId': instance.restaurantId,
      'driverId': instance.driverId,
      'restaurantRating': instance.restaurantRating,
      'foodRating': instance.foodRating,
      'driverRating': instance.driverRating,
      'comment': instance.comment,
      'images': instance.images,
      'restaurantReply': instance.restaurantReply,
      'repliedAt': instance.repliedAt?.toIso8601String(),
      'isVisible': instance.isVisible,
      'isReported': instance.isReported,
      'reportReason': instance.reportReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$RateOrderRequestImpl _$$RateOrderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RateOrderRequestImpl(
      restaurant: (json['restaurant'] as num?)?.toDouble(),
      driver: (json['driver'] as num?)?.toDouble(),
      food: (json['food'] as num?)?.toDouble(),
      comment: json['comment'] as String? ?? '',
    );

Map<String, dynamic> _$$RateOrderRequestImplToJson(
        _$RateOrderRequestImpl instance) =>
    <String, dynamic>{
      'restaurant': instance.restaurant,
      'driver': instance.driver,
      'food': instance.food,
      'comment': instance.comment,
    };

_$CustomerReviewImpl _$$CustomerReviewImplFromJson(Map<String, dynamic> json) =>
    _$CustomerReviewImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      restaurantLogo: json['restaurantLogo'] as String?,
      restaurantRating: (json['restaurantRating'] as num).toDouble(),
      foodRating: (json['foodRating'] as num).toDouble(),
      driverRating: (json['driverRating'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      restaurantReply: json['restaurantReply'] as String?,
      repliedAt: json['repliedAt'] == null
          ? null
          : DateTime.parse(json['repliedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CustomerReviewImplToJson(
        _$CustomerReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'restaurantId': instance.restaurantId,
      'restaurantName': instance.restaurantName,
      'restaurantLogo': instance.restaurantLogo,
      'restaurantRating': instance.restaurantRating,
      'foodRating': instance.foodRating,
      'driverRating': instance.driverRating,
      'comment': instance.comment,
      'restaurantReply': instance.restaurantReply,
      'repliedAt': instance.repliedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
