// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantImpl _$$RestaurantImplFromJson(Map<String, dynamic> json) =>
    _$RestaurantImpl(
      id: json['_id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      logo: json['logo'] as String?,
      coverImage: json['coverImage'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      area: json['area'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      priceRange: (json['priceRange'] as num?)?.toInt() ?? 2,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      minimumOrder: (json['minimumOrder'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      freeDeliveryAbove: (json['freeDeliveryAbove'] as num?)?.toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : EstimatedDeliveryTime.fromJson(
              json['estimatedDeliveryTime'] as Map<String, dynamic>),
      workingHours: (json['workingHours'] as List<dynamic>?)
              ?.map((e) => WorkingHours.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isApproved: json['isApproved'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      isPaused: json['isPaused'] as bool? ?? false,
      acceptsCash: json['acceptsCash'] as bool? ?? true,
      acceptsOnlinePayment: json['acceptsOnlinePayment'] as bool? ?? false,
      isOpen: json['isOpen'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RestaurantImplToJson(_$RestaurantImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'slug': instance.slug,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'logo': instance.logo,
      'coverImage': instance.coverImage,
      'images': instance.images,
      'phone': instance.phone,
      'address': instance.address,
      'area': instance.area,
      'location': instance.location,
      'categories': instance.categories,
      'tags': instance.tags,
      'priceRange': instance.priceRange,
      'rating': instance.rating,
      'totalRatings': instance.totalRatings,
      'totalOrders': instance.totalOrders,
      'minimumOrder': instance.minimumOrder,
      'deliveryFee': instance.deliveryFee,
      'freeDeliveryAbove': instance.freeDeliveryAbove,
      'estimatedDeliveryTime': instance.estimatedDeliveryTime,
      'workingHours': instance.workingHours,
      'isApproved': instance.isApproved,
      'isActive': instance.isActive,
      'isPaused': instance.isPaused,
      'acceptsCash': instance.acceptsCash,
      'acceptsOnlinePayment': instance.acceptsOnlinePayment,
      'isOpen': instance.isOpen,
      'isFavorite': instance.isFavorite,
      'distance': instance.distance,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      type: json['type'] as String? ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [0.0, 0.0],
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

_$EstimatedDeliveryTimeImpl _$$EstimatedDeliveryTimeImplFromJson(
        Map<String, dynamic> json) =>
    _$EstimatedDeliveryTimeImpl(
      min: (json['min'] as num?)?.toInt() ?? 20,
      max: (json['max'] as num?)?.toInt() ?? 40,
    );

Map<String, dynamic> _$$EstimatedDeliveryTimeImplToJson(
        _$EstimatedDeliveryTimeImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

_$WorkingHoursImpl _$$WorkingHoursImplFromJson(Map<String, dynamic> json) =>
    _$WorkingHoursImpl(
      day: (json['day'] as num).toInt(),
      isOpen: json['isOpen'] as bool? ?? true,
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => WorkingShift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WorkingHoursImplToJson(_$WorkingHoursImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'isOpen': instance.isOpen,
      'shifts': instance.shifts,
    };

_$WorkingShiftImpl _$$WorkingShiftImplFromJson(Map<String, dynamic> json) =>
    _$WorkingShiftImpl(
      open: json['open'] as String,
      close: json['close'] as String,
    );

Map<String, dynamic> _$$WorkingShiftImplToJson(_$WorkingShiftImpl instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
    };

_$MenuCategoryImpl _$$MenuCategoryImplFromJson(Map<String, dynamic> json) =>
    _$MenuCategoryImpl(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      image: json['image'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MenuCategoryImplToJson(_$MenuCategoryImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'restaurantId': instance.restaurantId,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'image': instance.image,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'items': instance.items,
    };

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      discountEndsAt: json['discountEndsAt'] == null
          ? null
          : DateTime.parse(json['discountEndsAt'] as String),
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 15,
      calories: (json['calories'] as num?)?.toInt(),
      servingSize: json['servingSize'] as String?,
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => MenuAddon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => MenuVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'restaurantId': instance.restaurantId,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'image': instance.image,
      'price': instance.price,
      'discountPrice': instance.discountPrice,
      'discountEndsAt': instance.discountEndsAt?.toIso8601String(),
      'preparationTime': instance.preparationTime,
      'calories': instance.calories,
      'servingSize': instance.servingSize,
      'addons': instance.addons,
      'variations': instance.variations,
      'tags': instance.tags,
      'isAvailable': instance.isAvailable,
      'isPopular': instance.isPopular,
      'isNew': instance.isNew,
      'sortOrder': instance.sortOrder,
      'totalOrders': instance.totalOrders,
    };

_$MenuAddonImpl _$$MenuAddonImplFromJson(Map<String, dynamic> json) =>
    _$MenuAddonImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      maxQuantity: (json['maxQuantity'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$$MenuAddonImplToJson(_$MenuAddonImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'price': instance.price,
      'isAvailable': instance.isAvailable,
      'maxQuantity': instance.maxQuantity,
    };

_$MenuVariationImpl _$$MenuVariationImplFromJson(Map<String, dynamic> json) =>
    _$MenuVariationImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => VariationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MenuVariationImplToJson(_$MenuVariationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'isRequired': instance.isRequired,
      'options': instance.options,
    };

_$VariationOptionImpl _$$VariationOptionImplFromJson(
        Map<String, dynamic> json) =>
    _$VariationOptionImpl(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$VariationOptionImplToJson(
        _$VariationOptionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'price': instance.price,
    };

_$RestaurantSearchParamsImpl _$$RestaurantSearchParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantSearchParamsImpl(
      search: json['search'] as String?,
      category: json['category'] as String?,
      area: json['area'] as String?,
      priceRange: (json['priceRange'] as num?)?.toInt(),
      isOpen: json['isOpen'] as bool?,
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 10,
    );

Map<String, dynamic> _$$RestaurantSearchParamsImplToJson(
        _$RestaurantSearchParamsImpl instance) =>
    <String, dynamic>{
      'search': instance.search,
      'category': instance.category,
      'area': instance.area,
      'priceRange': instance.priceRange,
      'isOpen': instance.isOpen,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
      'page': instance.page,
      'limit': instance.limit,
      'lat': instance.lat,
      'lng': instance.lng,
      'maxDistance': instance.maxDistance,
    };
