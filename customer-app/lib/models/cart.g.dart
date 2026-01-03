// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SelectedAddonImpl _$$SelectedAddonImplFromJson(Map<String, dynamic> json) =>
    _$SelectedAddonImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$SelectedAddonImplToJson(_$SelectedAddonImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'price': instance.price,
      'quantity': instance.quantity,
    };

_$SelectedVariationImpl _$$SelectedVariationImplFromJson(
        Map<String, dynamic> json) =>
    _$SelectedVariationImpl(
      variationName: json['variationName'] as String,
      variationNameAr: json['variationNameAr'] as String?,
      optionName: json['optionName'] as String,
      optionNameAr: json['optionNameAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$SelectedVariationImplToJson(
        _$SelectedVariationImpl instance) =>
    <String, dynamic>{
      'variationName': instance.variationName,
      'variationNameAr': instance.variationNameAr,
      'optionName': instance.optionName,
      'optionNameAr': instance.optionNameAr,
      'price': instance.price,
    };

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      restaurantNameAr: json['restaurantNameAr'] as String?,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      image: json['image'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => SelectedAddon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map(
                  (e) => SelectedVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'restaurantId': instance.restaurantId,
      'restaurantName': instance.restaurantName,
      'restaurantNameAr': instance.restaurantNameAr,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'image': instance.image,
      'basePrice': instance.basePrice,
      'quantity': instance.quantity,
      'addons': instance.addons,
      'variations': instance.variations,
      'specialInstructions': instance.specialInstructions,
    };

_$CartImpl _$$CartImplFromJson(Map<String, dynamic> json) => _$CartImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      restaurantId: json['restaurantId'] as String?,
      restaurantName: json['restaurantName'] as String?,
      restaurantNameAr: json['restaurantNameAr'] as String?,
      minimumOrder: (json['minimumOrder'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      freeDeliveryAbove: (json['freeDeliveryAbove'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CartImplToJson(_$CartImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'restaurantId': instance.restaurantId,
      'restaurantName': instance.restaurantName,
      'restaurantNameAr': instance.restaurantNameAr,
      'minimumOrder': instance.minimumOrder,
      'deliveryFee': instance.deliveryFee,
      'freeDeliveryAbove': instance.freeDeliveryAbove,
    };
