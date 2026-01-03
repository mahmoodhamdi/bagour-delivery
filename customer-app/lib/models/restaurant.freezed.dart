// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) {
  return _Restaurant.fromJson(json);
}

/// @nodoc
mixin _$Restaurant {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionAr => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get priceRange => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get totalRatings => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;
  double get minimumOrder => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double? get freeDeliveryAbove => throw _privateConstructorUsedError;
  EstimatedDeliveryTime? get estimatedDeliveryTime =>
      throw _privateConstructorUsedError;
  List<WorkingHours> get workingHours => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  bool get acceptsCash => throw _privateConstructorUsedError;
  bool get acceptsOnlinePayment => throw _privateConstructorUsedError;
  bool get isOpen => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Restaurant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantCopyWith<Restaurant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantCopyWith<$Res> {
  factory $RestaurantCopyWith(
          Restaurant value, $Res Function(Restaurant) then) =
      _$RestaurantCopyWithImpl<$Res, Restaurant>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String name,
      String? nameAr,
      String? slug,
      String? description,
      String? descriptionAr,
      String? logo,
      String? coverImage,
      List<String> images,
      String? phone,
      String? address,
      String? area,
      Location? location,
      List<String> categories,
      List<String> tags,
      int priceRange,
      double rating,
      int totalRatings,
      int totalOrders,
      double minimumOrder,
      double deliveryFee,
      double? freeDeliveryAbove,
      EstimatedDeliveryTime? estimatedDeliveryTime,
      List<WorkingHours> workingHours,
      bool isApproved,
      bool isActive,
      bool isPaused,
      bool acceptsCash,
      bool acceptsOnlinePayment,
      bool isOpen,
      bool isFavorite,
      double? distance,
      DateTime? createdAt});

  $LocationCopyWith<$Res>? get location;
  $EstimatedDeliveryTimeCopyWith<$Res>? get estimatedDeliveryTime;
}

/// @nodoc
class _$RestaurantCopyWithImpl<$Res, $Val extends Restaurant>
    implements $RestaurantCopyWith<$Res> {
  _$RestaurantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? slug = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? logo = freezed,
    Object? coverImage = freezed,
    Object? images = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? area = freezed,
    Object? location = freezed,
    Object? categories = null,
    Object? tags = null,
    Object? priceRange = null,
    Object? rating = null,
    Object? totalRatings = null,
    Object? totalOrders = null,
    Object? minimumOrder = null,
    Object? deliveryFee = null,
    Object? freeDeliveryAbove = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? workingHours = null,
    Object? isApproved = null,
    Object? isActive = null,
    Object? isPaused = null,
    Object? acceptsCash = null,
    Object? acceptsOnlinePayment = null,
    Object? isOpen = null,
    Object? isFavorite = null,
    Object? distance = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceRange: null == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      minimumOrder: null == minimumOrder
          ? _value.minimumOrder
          : minimumOrder // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      freeDeliveryAbove: freezed == freeDeliveryAbove
          ? _value.freeDeliveryAbove
          : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as EstimatedDeliveryTime?,
      workingHours: null == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as List<WorkingHours>,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsCash: null == acceptsCash
          ? _value.acceptsCash
          : acceptsCash // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsOnlinePayment: null == acceptsOnlinePayment
          ? _value.acceptsOnlinePayment
          : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
              as bool,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EstimatedDeliveryTimeCopyWith<$Res>? get estimatedDeliveryTime {
    if (_value.estimatedDeliveryTime == null) {
      return null;
    }

    return $EstimatedDeliveryTimeCopyWith<$Res>(_value.estimatedDeliveryTime!,
        (value) {
      return _then(_value.copyWith(estimatedDeliveryTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestaurantImplCopyWith<$Res>
    implements $RestaurantCopyWith<$Res> {
  factory _$$RestaurantImplCopyWith(
          _$RestaurantImpl value, $Res Function(_$RestaurantImpl) then) =
      __$$RestaurantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String name,
      String? nameAr,
      String? slug,
      String? description,
      String? descriptionAr,
      String? logo,
      String? coverImage,
      List<String> images,
      String? phone,
      String? address,
      String? area,
      Location? location,
      List<String> categories,
      List<String> tags,
      int priceRange,
      double rating,
      int totalRatings,
      int totalOrders,
      double minimumOrder,
      double deliveryFee,
      double? freeDeliveryAbove,
      EstimatedDeliveryTime? estimatedDeliveryTime,
      List<WorkingHours> workingHours,
      bool isApproved,
      bool isActive,
      bool isPaused,
      bool acceptsCash,
      bool acceptsOnlinePayment,
      bool isOpen,
      bool isFavorite,
      double? distance,
      DateTime? createdAt});

  @override
  $LocationCopyWith<$Res>? get location;
  @override
  $EstimatedDeliveryTimeCopyWith<$Res>? get estimatedDeliveryTime;
}

/// @nodoc
class __$$RestaurantImplCopyWithImpl<$Res>
    extends _$RestaurantCopyWithImpl<$Res, _$RestaurantImpl>
    implements _$$RestaurantImplCopyWith<$Res> {
  __$$RestaurantImplCopyWithImpl(
      _$RestaurantImpl _value, $Res Function(_$RestaurantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? slug = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? logo = freezed,
    Object? coverImage = freezed,
    Object? images = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? area = freezed,
    Object? location = freezed,
    Object? categories = null,
    Object? tags = null,
    Object? priceRange = null,
    Object? rating = null,
    Object? totalRatings = null,
    Object? totalOrders = null,
    Object? minimumOrder = null,
    Object? deliveryFee = null,
    Object? freeDeliveryAbove = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? workingHours = null,
    Object? isApproved = null,
    Object? isActive = null,
    Object? isPaused = null,
    Object? acceptsCash = null,
    Object? acceptsOnlinePayment = null,
    Object? isOpen = null,
    Object? isFavorite = null,
    Object? distance = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$RestaurantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceRange: null == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      minimumOrder: null == minimumOrder
          ? _value.minimumOrder
          : minimumOrder // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      freeDeliveryAbove: freezed == freeDeliveryAbove
          ? _value.freeDeliveryAbove
          : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as EstimatedDeliveryTime?,
      workingHours: null == workingHours
          ? _value._workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as List<WorkingHours>,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsCash: null == acceptsCash
          ? _value.acceptsCash
          : acceptsCash // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsOnlinePayment: null == acceptsOnlinePayment
          ? _value.acceptsOnlinePayment
          : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
              as bool,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantImpl implements _Restaurant {
  const _$RestaurantImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.name,
      this.nameAr,
      this.slug,
      this.description,
      this.descriptionAr,
      this.logo,
      this.coverImage,
      final List<String> images = const [],
      this.phone,
      this.address,
      this.area,
      this.location,
      final List<String> categories = const [],
      final List<String> tags = const [],
      this.priceRange = 2,
      this.rating = 0.0,
      this.totalRatings = 0,
      this.totalOrders = 0,
      this.minimumOrder = 0.0,
      this.deliveryFee = 0.0,
      this.freeDeliveryAbove,
      this.estimatedDeliveryTime,
      final List<WorkingHours> workingHours = const [],
      this.isApproved = true,
      this.isActive = true,
      this.isPaused = false,
      this.acceptsCash = true,
      this.acceptsOnlinePayment = false,
      this.isOpen = false,
      this.isFavorite = false,
      this.distance,
      this.createdAt})
      : _images = images,
        _categories = categories,
        _tags = tags,
        _workingHours = workingHours;

  factory _$RestaurantImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? slug;
  @override
  final String? description;
  @override
  final String? descriptionAr;
  @override
  final String? logo;
  @override
  final String? coverImage;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? phone;
  @override
  final String? address;
  @override
  final String? area;
  @override
  final Location? location;
  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int priceRange;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int totalRatings;
  @override
  @JsonKey()
  final int totalOrders;
  @override
  @JsonKey()
  final double minimumOrder;
  @override
  @JsonKey()
  final double deliveryFee;
  @override
  final double? freeDeliveryAbove;
  @override
  final EstimatedDeliveryTime? estimatedDeliveryTime;
  final List<WorkingHours> _workingHours;
  @override
  @JsonKey()
  List<WorkingHours> get workingHours {
    if (_workingHours is EqualUnmodifiableListView) return _workingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workingHours);
  }

  @override
  @JsonKey()
  final bool isApproved;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPaused;
  @override
  @JsonKey()
  final bool acceptsCash;
  @override
  @JsonKey()
  final bool acceptsOnlinePayment;
  @override
  @JsonKey()
  final bool isOpen;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final double? distance;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, nameAr: $nameAr, slug: $slug, description: $description, descriptionAr: $descriptionAr, logo: $logo, coverImage: $coverImage, images: $images, phone: $phone, address: $address, area: $area, location: $location, categories: $categories, tags: $tags, priceRange: $priceRange, rating: $rating, totalRatings: $totalRatings, totalOrders: $totalOrders, minimumOrder: $minimumOrder, deliveryFee: $deliveryFee, freeDeliveryAbove: $freeDeliveryAbove, estimatedDeliveryTime: $estimatedDeliveryTime, workingHours: $workingHours, isApproved: $isApproved, isActive: $isActive, isPaused: $isPaused, acceptsCash: $acceptsCash, acceptsOnlinePayment: $acceptsOnlinePayment, isOpen: $isOpen, isFavorite: $isFavorite, distance: $distance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionAr, descriptionAr) ||
                other.descriptionAr == descriptionAr) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalRatings, totalRatings) ||
                other.totalRatings == totalRatings) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.minimumOrder, minimumOrder) ||
                other.minimumOrder == minimumOrder) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.freeDeliveryAbove, freeDeliveryAbove) ||
                other.freeDeliveryAbove == freeDeliveryAbove) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            const DeepCollectionEquality()
                .equals(other._workingHours, _workingHours) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.acceptsCash, acceptsCash) ||
                other.acceptsCash == acceptsCash) &&
            (identical(other.acceptsOnlinePayment, acceptsOnlinePayment) ||
                other.acceptsOnlinePayment == acceptsOnlinePayment) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        nameAr,
        slug,
        description,
        descriptionAr,
        logo,
        coverImage,
        const DeepCollectionEquality().hash(_images),
        phone,
        address,
        area,
        location,
        const DeepCollectionEquality().hash(_categories),
        const DeepCollectionEquality().hash(_tags),
        priceRange,
        rating,
        totalRatings,
        totalOrders,
        minimumOrder,
        deliveryFee,
        freeDeliveryAbove,
        estimatedDeliveryTime,
        const DeepCollectionEquality().hash(_workingHours),
        isApproved,
        isActive,
        isPaused,
        acceptsCash,
        acceptsOnlinePayment,
        isOpen,
        isFavorite,
        distance,
        createdAt
      ]);

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantImplCopyWith<_$RestaurantImpl> get copyWith =>
      __$$RestaurantImplCopyWithImpl<_$RestaurantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantImplToJson(
      this,
    );
  }
}

abstract class _Restaurant implements Restaurant {
  const factory _Restaurant(
      {@JsonKey(name: '_id') required final String id,
      required final String name,
      final String? nameAr,
      final String? slug,
      final String? description,
      final String? descriptionAr,
      final String? logo,
      final String? coverImage,
      final List<String> images,
      final String? phone,
      final String? address,
      final String? area,
      final Location? location,
      final List<String> categories,
      final List<String> tags,
      final int priceRange,
      final double rating,
      final int totalRatings,
      final int totalOrders,
      final double minimumOrder,
      final double deliveryFee,
      final double? freeDeliveryAbove,
      final EstimatedDeliveryTime? estimatedDeliveryTime,
      final List<WorkingHours> workingHours,
      final bool isApproved,
      final bool isActive,
      final bool isPaused,
      final bool acceptsCash,
      final bool acceptsOnlinePayment,
      final bool isOpen,
      final bool isFavorite,
      final double? distance,
      final DateTime? createdAt}) = _$RestaurantImpl;

  factory _Restaurant.fromJson(Map<String, dynamic> json) =
      _$RestaurantImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get slug;
  @override
  String? get description;
  @override
  String? get descriptionAr;
  @override
  String? get logo;
  @override
  String? get coverImage;
  @override
  List<String> get images;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  String? get area;
  @override
  Location? get location;
  @override
  List<String> get categories;
  @override
  List<String> get tags;
  @override
  int get priceRange;
  @override
  double get rating;
  @override
  int get totalRatings;
  @override
  int get totalOrders;
  @override
  double get minimumOrder;
  @override
  double get deliveryFee;
  @override
  double? get freeDeliveryAbove;
  @override
  EstimatedDeliveryTime? get estimatedDeliveryTime;
  @override
  List<WorkingHours> get workingHours;
  @override
  bool get isApproved;
  @override
  bool get isActive;
  @override
  bool get isPaused;
  @override
  bool get acceptsCash;
  @override
  bool get acceptsOnlinePayment;
  @override
  bool get isOpen;
  @override
  bool get isFavorite;
  @override
  double? get distance;
  @override
  DateTime? get createdAt;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantImplCopyWith<_$RestaurantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  String get type => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({String type, List<double> coordinates});
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? coordinates = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
          _$LocationImpl value, $Res Function(_$LocationImpl) then) =
      __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, List<double> coordinates});
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
      _$LocationImpl _value, $Res Function(_$LocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? coordinates = null,
  }) {
    return _then(_$LocationImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl(
      {this.type = 'Point', final List<double> coordinates = const [0.0, 0.0]})
      : _coordinates = coordinates;

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  final List<double> _coordinates;
  @override
  @JsonKey()
  List<double> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  String toString() {
    return 'Location(type: $type, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_coordinates));

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(
      this,
    );
  }
}

abstract class _Location implements Location {
  const factory _Location({final String type, final List<double> coordinates}) =
      _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  String get type;
  @override
  List<double> get coordinates;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EstimatedDeliveryTime _$EstimatedDeliveryTimeFromJson(
    Map<String, dynamic> json) {
  return _EstimatedDeliveryTime.fromJson(json);
}

/// @nodoc
mixin _$EstimatedDeliveryTime {
  int get min => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;

  /// Serializes this EstimatedDeliveryTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EstimatedDeliveryTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstimatedDeliveryTimeCopyWith<EstimatedDeliveryTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstimatedDeliveryTimeCopyWith<$Res> {
  factory $EstimatedDeliveryTimeCopyWith(EstimatedDeliveryTime value,
          $Res Function(EstimatedDeliveryTime) then) =
      _$EstimatedDeliveryTimeCopyWithImpl<$Res, EstimatedDeliveryTime>;
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class _$EstimatedDeliveryTimeCopyWithImpl<$Res,
        $Val extends EstimatedDeliveryTime>
    implements $EstimatedDeliveryTimeCopyWith<$Res> {
  _$EstimatedDeliveryTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstimatedDeliveryTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as int,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstimatedDeliveryTimeImplCopyWith<$Res>
    implements $EstimatedDeliveryTimeCopyWith<$Res> {
  factory _$$EstimatedDeliveryTimeImplCopyWith(
          _$EstimatedDeliveryTimeImpl value,
          $Res Function(_$EstimatedDeliveryTimeImpl) then) =
      __$$EstimatedDeliveryTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class __$$EstimatedDeliveryTimeImplCopyWithImpl<$Res>
    extends _$EstimatedDeliveryTimeCopyWithImpl<$Res,
        _$EstimatedDeliveryTimeImpl>
    implements _$$EstimatedDeliveryTimeImplCopyWith<$Res> {
  __$$EstimatedDeliveryTimeImplCopyWithImpl(_$EstimatedDeliveryTimeImpl _value,
      $Res Function(_$EstimatedDeliveryTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstimatedDeliveryTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
  }) {
    return _then(_$EstimatedDeliveryTimeImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as int,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EstimatedDeliveryTimeImpl implements _EstimatedDeliveryTime {
  const _$EstimatedDeliveryTimeImpl({this.min = 20, this.max = 40});

  factory _$EstimatedDeliveryTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EstimatedDeliveryTimeImplFromJson(json);

  @override
  @JsonKey()
  final int min;
  @override
  @JsonKey()
  final int max;

  @override
  String toString() {
    return 'EstimatedDeliveryTime(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstimatedDeliveryTimeImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of EstimatedDeliveryTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstimatedDeliveryTimeImplCopyWith<_$EstimatedDeliveryTimeImpl>
      get copyWith => __$$EstimatedDeliveryTimeImplCopyWithImpl<
          _$EstimatedDeliveryTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EstimatedDeliveryTimeImplToJson(
      this,
    );
  }
}

abstract class _EstimatedDeliveryTime implements EstimatedDeliveryTime {
  const factory _EstimatedDeliveryTime({final int min, final int max}) =
      _$EstimatedDeliveryTimeImpl;

  factory _EstimatedDeliveryTime.fromJson(Map<String, dynamic> json) =
      _$EstimatedDeliveryTimeImpl.fromJson;

  @override
  int get min;
  @override
  int get max;

  /// Create a copy of EstimatedDeliveryTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstimatedDeliveryTimeImplCopyWith<_$EstimatedDeliveryTimeImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) {
  return _WorkingHours.fromJson(json);
}

/// @nodoc
mixin _$WorkingHours {
  int get day => throw _privateConstructorUsedError;
  bool get isOpen => throw _privateConstructorUsedError;
  List<WorkingShift> get shifts => throw _privateConstructorUsedError;

  /// Serializes this WorkingHours to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkingHoursCopyWith<WorkingHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingHoursCopyWith<$Res> {
  factory $WorkingHoursCopyWith(
          WorkingHours value, $Res Function(WorkingHours) then) =
      _$WorkingHoursCopyWithImpl<$Res, WorkingHours>;
  @useResult
  $Res call({int day, bool isOpen, List<WorkingShift> shifts});
}

/// @nodoc
class _$WorkingHoursCopyWithImpl<$Res, $Val extends WorkingHours>
    implements $WorkingHoursCopyWith<$Res> {
  _$WorkingHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? isOpen = null,
    Object? shifts = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      shifts: null == shifts
          ? _value.shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<WorkingShift>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkingHoursImplCopyWith<$Res>
    implements $WorkingHoursCopyWith<$Res> {
  factory _$$WorkingHoursImplCopyWith(
          _$WorkingHoursImpl value, $Res Function(_$WorkingHoursImpl) then) =
      __$$WorkingHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int day, bool isOpen, List<WorkingShift> shifts});
}

/// @nodoc
class __$$WorkingHoursImplCopyWithImpl<$Res>
    extends _$WorkingHoursCopyWithImpl<$Res, _$WorkingHoursImpl>
    implements _$$WorkingHoursImplCopyWith<$Res> {
  __$$WorkingHoursImplCopyWithImpl(
      _$WorkingHoursImpl _value, $Res Function(_$WorkingHoursImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? isOpen = null,
    Object? shifts = null,
  }) {
    return _then(_$WorkingHoursImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      isOpen: null == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      shifts: null == shifts
          ? _value._shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<WorkingShift>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingHoursImpl implements _WorkingHours {
  const _$WorkingHoursImpl(
      {required this.day,
      this.isOpen = true,
      final List<WorkingShift> shifts = const []})
      : _shifts = shifts;

  factory _$WorkingHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingHoursImplFromJson(json);

  @override
  final int day;
  @override
  @JsonKey()
  final bool isOpen;
  final List<WorkingShift> _shifts;
  @override
  @JsonKey()
  List<WorkingShift> get shifts {
    if (_shifts is EqualUnmodifiableListView) return _shifts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shifts);
  }

  @override
  String toString() {
    return 'WorkingHours(day: $day, isOpen: $isOpen, shifts: $shifts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingHoursImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            const DeepCollectionEquality().equals(other._shifts, _shifts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, day, isOpen, const DeepCollectionEquality().hash(_shifts));

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      __$$WorkingHoursImplCopyWithImpl<_$WorkingHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingHoursImplToJson(
      this,
    );
  }
}

abstract class _WorkingHours implements WorkingHours {
  const factory _WorkingHours(
      {required final int day,
      final bool isOpen,
      final List<WorkingShift> shifts}) = _$WorkingHoursImpl;

  factory _WorkingHours.fromJson(Map<String, dynamic> json) =
      _$WorkingHoursImpl.fromJson;

  @override
  int get day;
  @override
  bool get isOpen;
  @override
  List<WorkingShift> get shifts;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkingShift _$WorkingShiftFromJson(Map<String, dynamic> json) {
  return _WorkingShift.fromJson(json);
}

/// @nodoc
mixin _$WorkingShift {
  String get open => throw _privateConstructorUsedError;
  String get close => throw _privateConstructorUsedError;

  /// Serializes this WorkingShift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkingShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkingShiftCopyWith<WorkingShift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingShiftCopyWith<$Res> {
  factory $WorkingShiftCopyWith(
          WorkingShift value, $Res Function(WorkingShift) then) =
      _$WorkingShiftCopyWithImpl<$Res, WorkingShift>;
  @useResult
  $Res call({String open, String close});
}

/// @nodoc
class _$WorkingShiftCopyWithImpl<$Res, $Val extends WorkingShift>
    implements $WorkingShiftCopyWith<$Res> {
  _$WorkingShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkingShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
  }) {
    return _then(_value.copyWith(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkingShiftImplCopyWith<$Res>
    implements $WorkingShiftCopyWith<$Res> {
  factory _$$WorkingShiftImplCopyWith(
          _$WorkingShiftImpl value, $Res Function(_$WorkingShiftImpl) then) =
      __$$WorkingShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String open, String close});
}

/// @nodoc
class __$$WorkingShiftImplCopyWithImpl<$Res>
    extends _$WorkingShiftCopyWithImpl<$Res, _$WorkingShiftImpl>
    implements _$$WorkingShiftImplCopyWith<$Res> {
  __$$WorkingShiftImplCopyWithImpl(
      _$WorkingShiftImpl _value, $Res Function(_$WorkingShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkingShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
  }) {
    return _then(_$WorkingShiftImpl(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingShiftImpl implements _WorkingShift {
  const _$WorkingShiftImpl({required this.open, required this.close});

  factory _$WorkingShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingShiftImplFromJson(json);

  @override
  final String open;
  @override
  final String close;

  @override
  String toString() {
    return 'WorkingShift(open: $open, close: $close)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingShiftImpl &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.close, close) || other.close == close));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, open, close);

  /// Create a copy of WorkingShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingShiftImplCopyWith<_$WorkingShiftImpl> get copyWith =>
      __$$WorkingShiftImplCopyWithImpl<_$WorkingShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingShiftImplToJson(
      this,
    );
  }
}

abstract class _WorkingShift implements WorkingShift {
  const factory _WorkingShift(
      {required final String open,
      required final String close}) = _$WorkingShiftImpl;

  factory _WorkingShift.fromJson(Map<String, dynamic> json) =
      _$WorkingShiftImpl.fromJson;

  @override
  String get open;
  @override
  String get close;

  /// Create a copy of WorkingShift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkingShiftImplCopyWith<_$WorkingShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) {
  return _MenuCategory.fromJson(json);
}

/// @nodoc
mixin _$MenuCategory {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get restaurantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionAr => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<MenuItem> get items => throw _privateConstructorUsedError;

  /// Serializes this MenuCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuCategoryCopyWith<MenuCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuCategoryCopyWith<$Res> {
  factory $MenuCategoryCopyWith(
          MenuCategory value, $Res Function(MenuCategory) then) =
      _$MenuCategoryCopyWithImpl<$Res, MenuCategory>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String restaurantId,
      String name,
      String? nameAr,
      String? description,
      String? descriptionAr,
      String? image,
      int sortOrder,
      bool isActive,
      List<MenuItem> items});
}

/// @nodoc
class _$MenuCategoryCopyWithImpl<$Res, $Val extends MenuCategory>
    implements $MenuCategoryCopyWith<$Res> {
  _$MenuCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? image = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MenuItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuCategoryImplCopyWith<$Res>
    implements $MenuCategoryCopyWith<$Res> {
  factory _$$MenuCategoryImplCopyWith(
          _$MenuCategoryImpl value, $Res Function(_$MenuCategoryImpl) then) =
      __$$MenuCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String restaurantId,
      String name,
      String? nameAr,
      String? description,
      String? descriptionAr,
      String? image,
      int sortOrder,
      bool isActive,
      List<MenuItem> items});
}

/// @nodoc
class __$$MenuCategoryImplCopyWithImpl<$Res>
    extends _$MenuCategoryCopyWithImpl<$Res, _$MenuCategoryImpl>
    implements _$$MenuCategoryImplCopyWith<$Res> {
  __$$MenuCategoryImplCopyWithImpl(
      _$MenuCategoryImpl _value, $Res Function(_$MenuCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? image = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? items = null,
  }) {
    return _then(_$MenuCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MenuItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuCategoryImpl implements _MenuCategory {
  const _$MenuCategoryImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.restaurantId,
      required this.name,
      this.nameAr,
      this.description,
      this.descriptionAr,
      this.image,
      this.sortOrder = 0,
      this.isActive = true,
      final List<MenuItem> items = const []})
      : _items = items;

  factory _$MenuCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuCategoryImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String restaurantId;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? description;
  @override
  final String? descriptionAr;
  @override
  final String? image;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;
  final List<MenuItem> _items;
  @override
  @JsonKey()
  List<MenuItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MenuCategory(id: $id, restaurantId: $restaurantId, name: $name, nameAr: $nameAr, description: $description, descriptionAr: $descriptionAr, image: $image, sortOrder: $sortOrder, isActive: $isActive, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionAr, descriptionAr) ||
                other.descriptionAr == descriptionAr) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      restaurantId,
      name,
      nameAr,
      description,
      descriptionAr,
      image,
      sortOrder,
      isActive,
      const DeepCollectionEquality().hash(_items));

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      __$$MenuCategoryImplCopyWithImpl<_$MenuCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuCategoryImplToJson(
      this,
    );
  }
}

abstract class _MenuCategory implements MenuCategory {
  const factory _MenuCategory(
      {@JsonKey(name: '_id') required final String id,
      required final String restaurantId,
      required final String name,
      final String? nameAr,
      final String? description,
      final String? descriptionAr,
      final String? image,
      final int sortOrder,
      final bool isActive,
      final List<MenuItem> items}) = _$MenuCategoryImpl;

  factory _MenuCategory.fromJson(Map<String, dynamic> json) =
      _$MenuCategoryImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get restaurantId;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get description;
  @override
  String? get descriptionAr;
  @override
  String? get image;
  @override
  int get sortOrder;
  @override
  bool get isActive;
  @override
  List<MenuItem> get items;

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) {
  return _MenuItem.fromJson(json);
}

/// @nodoc
mixin _$MenuItem {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get restaurantId => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionAr => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get discountPrice => throw _privateConstructorUsedError;
  DateTime? get discountEndsAt => throw _privateConstructorUsedError;
  int get preparationTime => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  String? get servingSize => throw _privateConstructorUsedError;
  List<MenuAddon> get addons => throw _privateConstructorUsedError;
  List<MenuVariation> get variations => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;
  bool get isNew => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;

  /// Serializes this MenuItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuItemCopyWith<MenuItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemCopyWith<$Res> {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) then) =
      _$MenuItemCopyWithImpl<$Res, MenuItem>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String restaurantId,
      String categoryId,
      String name,
      String? nameAr,
      String? description,
      String? descriptionAr,
      String? image,
      double price,
      double? discountPrice,
      DateTime? discountEndsAt,
      int preparationTime,
      int? calories,
      String? servingSize,
      List<MenuAddon> addons,
      List<MenuVariation> variations,
      List<String> tags,
      bool isAvailable,
      bool isPopular,
      bool isNew,
      int sortOrder,
      int totalOrders});
}

/// @nodoc
class _$MenuItemCopyWithImpl<$Res, $Val extends MenuItem>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? categoryId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? image = freezed,
    Object? price = null,
    Object? discountPrice = freezed,
    Object? discountEndsAt = freezed,
    Object? preparationTime = null,
    Object? calories = freezed,
    Object? servingSize = freezed,
    Object? addons = null,
    Object? variations = null,
    Object? tags = null,
    Object? isAvailable = null,
    Object? isPopular = null,
    Object? isNew = null,
    Object? sortOrder = null,
    Object? totalOrders = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      discountEndsAt: freezed == discountEndsAt
          ? _value.discountEndsAt
          : discountEndsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preparationTime: null == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      servingSize: freezed == servingSize
          ? _value.servingSize
          : servingSize // ignore: cast_nullable_to_non_nullable
              as String?,
      addons: null == addons
          ? _value.addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<MenuAddon>,
      variations: null == variations
          ? _value.variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<MenuVariation>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuItemImplCopyWith<$Res>
    implements $MenuItemCopyWith<$Res> {
  factory _$$MenuItemImplCopyWith(
          _$MenuItemImpl value, $Res Function(_$MenuItemImpl) then) =
      __$$MenuItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String restaurantId,
      String categoryId,
      String name,
      String? nameAr,
      String? description,
      String? descriptionAr,
      String? image,
      double price,
      double? discountPrice,
      DateTime? discountEndsAt,
      int preparationTime,
      int? calories,
      String? servingSize,
      List<MenuAddon> addons,
      List<MenuVariation> variations,
      List<String> tags,
      bool isAvailable,
      bool isPopular,
      bool isNew,
      int sortOrder,
      int totalOrders});
}

/// @nodoc
class __$$MenuItemImplCopyWithImpl<$Res>
    extends _$MenuItemCopyWithImpl<$Res, _$MenuItemImpl>
    implements _$$MenuItemImplCopyWith<$Res> {
  __$$MenuItemImplCopyWithImpl(
      _$MenuItemImpl _value, $Res Function(_$MenuItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? categoryId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? description = freezed,
    Object? descriptionAr = freezed,
    Object? image = freezed,
    Object? price = null,
    Object? discountPrice = freezed,
    Object? discountEndsAt = freezed,
    Object? preparationTime = null,
    Object? calories = freezed,
    Object? servingSize = freezed,
    Object? addons = null,
    Object? variations = null,
    Object? tags = null,
    Object? isAvailable = null,
    Object? isPopular = null,
    Object? isNew = null,
    Object? sortOrder = null,
    Object? totalOrders = null,
  }) {
    return _then(_$MenuItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionAr: freezed == descriptionAr
          ? _value.descriptionAr
          : descriptionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      discountPrice: freezed == discountPrice
          ? _value.discountPrice
          : discountPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      discountEndsAt: freezed == discountEndsAt
          ? _value.discountEndsAt
          : discountEndsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preparationTime: null == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      servingSize: freezed == servingSize
          ? _value.servingSize
          : servingSize // ignore: cast_nullable_to_non_nullable
              as String?,
      addons: null == addons
          ? _value._addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<MenuAddon>,
      variations: null == variations
          ? _value._variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<MenuVariation>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemImpl extends _MenuItem {
  const _$MenuItemImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.restaurantId,
      required this.categoryId,
      required this.name,
      this.nameAr,
      this.description,
      this.descriptionAr,
      this.image,
      required this.price,
      this.discountPrice,
      this.discountEndsAt,
      this.preparationTime = 15,
      this.calories,
      this.servingSize,
      final List<MenuAddon> addons = const [],
      final List<MenuVariation> variations = const [],
      final List<String> tags = const [],
      this.isAvailable = true,
      this.isPopular = false,
      this.isNew = false,
      this.sortOrder = 0,
      this.totalOrders = 0})
      : _addons = addons,
        _variations = variations,
        _tags = tags,
        super._();

  factory _$MenuItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String restaurantId;
  @override
  final String categoryId;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? description;
  @override
  final String? descriptionAr;
  @override
  final String? image;
  @override
  final double price;
  @override
  final double? discountPrice;
  @override
  final DateTime? discountEndsAt;
  @override
  @JsonKey()
  final int preparationTime;
  @override
  final int? calories;
  @override
  final String? servingSize;
  final List<MenuAddon> _addons;
  @override
  @JsonKey()
  List<MenuAddon> get addons {
    if (_addons is EqualUnmodifiableListView) return _addons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addons);
  }

  final List<MenuVariation> _variations;
  @override
  @JsonKey()
  List<MenuVariation> get variations {
    if (_variations is EqualUnmodifiableListView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variations);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final bool isPopular;
  @override
  @JsonKey()
  final bool isNew;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final int totalOrders;

  @override
  String toString() {
    return 'MenuItem(id: $id, restaurantId: $restaurantId, categoryId: $categoryId, name: $name, nameAr: $nameAr, description: $description, descriptionAr: $descriptionAr, image: $image, price: $price, discountPrice: $discountPrice, discountEndsAt: $discountEndsAt, preparationTime: $preparationTime, calories: $calories, servingSize: $servingSize, addons: $addons, variations: $variations, tags: $tags, isAvailable: $isAvailable, isPopular: $isPopular, isNew: $isNew, sortOrder: $sortOrder, totalOrders: $totalOrders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionAr, descriptionAr) ||
                other.descriptionAr == descriptionAr) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.discountEndsAt, discountEndsAt) ||
                other.discountEndsAt == discountEndsAt) &&
            (identical(other.preparationTime, preparationTime) ||
                other.preparationTime == preparationTime) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.servingSize, servingSize) ||
                other.servingSize == servingSize) &&
            const DeepCollectionEquality().equals(other._addons, _addons) &&
            const DeepCollectionEquality()
                .equals(other._variations, _variations) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        restaurantId,
        categoryId,
        name,
        nameAr,
        description,
        descriptionAr,
        image,
        price,
        discountPrice,
        discountEndsAt,
        preparationTime,
        calories,
        servingSize,
        const DeepCollectionEquality().hash(_addons),
        const DeepCollectionEquality().hash(_variations),
        const DeepCollectionEquality().hash(_tags),
        isAvailable,
        isPopular,
        isNew,
        sortOrder,
        totalOrders
      ]);

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      __$$MenuItemImplCopyWithImpl<_$MenuItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemImplToJson(
      this,
    );
  }
}

abstract class _MenuItem extends MenuItem {
  const factory _MenuItem(
      {@JsonKey(name: '_id') required final String id,
      required final String restaurantId,
      required final String categoryId,
      required final String name,
      final String? nameAr,
      final String? description,
      final String? descriptionAr,
      final String? image,
      required final double price,
      final double? discountPrice,
      final DateTime? discountEndsAt,
      final int preparationTime,
      final int? calories,
      final String? servingSize,
      final List<MenuAddon> addons,
      final List<MenuVariation> variations,
      final List<String> tags,
      final bool isAvailable,
      final bool isPopular,
      final bool isNew,
      final int sortOrder,
      final int totalOrders}) = _$MenuItemImpl;
  const _MenuItem._() : super._();

  factory _MenuItem.fromJson(Map<String, dynamic> json) =
      _$MenuItemImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get restaurantId;
  @override
  String get categoryId;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get description;
  @override
  String? get descriptionAr;
  @override
  String? get image;
  @override
  double get price;
  @override
  double? get discountPrice;
  @override
  DateTime? get discountEndsAt;
  @override
  int get preparationTime;
  @override
  int? get calories;
  @override
  String? get servingSize;
  @override
  List<MenuAddon> get addons;
  @override
  List<MenuVariation> get variations;
  @override
  List<String> get tags;
  @override
  bool get isAvailable;
  @override
  bool get isPopular;
  @override
  bool get isNew;
  @override
  int get sortOrder;
  @override
  int get totalOrders;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuAddon _$MenuAddonFromJson(Map<String, dynamic> json) {
  return _MenuAddon.fromJson(json);
}

/// @nodoc
mixin _$MenuAddon {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  int get maxQuantity => throw _privateConstructorUsedError;

  /// Serializes this MenuAddon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuAddonCopyWith<MenuAddon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuAddonCopyWith<$Res> {
  factory $MenuAddonCopyWith(MenuAddon value, $Res Function(MenuAddon) then) =
      _$MenuAddonCopyWithImpl<$Res, MenuAddon>;
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      double price,
      bool isAvailable,
      int maxQuantity});
}

/// @nodoc
class _$MenuAddonCopyWithImpl<$Res, $Val extends MenuAddon>
    implements $MenuAddonCopyWith<$Res> {
  _$MenuAddonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
    Object? isAvailable = null,
    Object? maxQuantity = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      maxQuantity: null == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuAddonImplCopyWith<$Res>
    implements $MenuAddonCopyWith<$Res> {
  factory _$$MenuAddonImplCopyWith(
          _$MenuAddonImpl value, $Res Function(_$MenuAddonImpl) then) =
      __$$MenuAddonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      double price,
      bool isAvailable,
      int maxQuantity});
}

/// @nodoc
class __$$MenuAddonImplCopyWithImpl<$Res>
    extends _$MenuAddonCopyWithImpl<$Res, _$MenuAddonImpl>
    implements _$$MenuAddonImplCopyWith<$Res> {
  __$$MenuAddonImplCopyWithImpl(
      _$MenuAddonImpl _value, $Res Function(_$MenuAddonImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
    Object? isAvailable = null,
    Object? maxQuantity = null,
  }) {
    return _then(_$MenuAddonImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      maxQuantity: null == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuAddonImpl implements _MenuAddon {
  const _$MenuAddonImpl(
      {required this.name,
      this.nameAr,
      required this.price,
      this.isAvailable = true,
      this.maxQuantity = 5});

  factory _$MenuAddonImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuAddonImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final double price;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final int maxQuantity;

  @override
  String toString() {
    return 'MenuAddon(name: $name, nameAr: $nameAr, price: $price, isAvailable: $isAvailable, maxQuantity: $maxQuantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuAddonImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.maxQuantity, maxQuantity) ||
                other.maxQuantity == maxQuantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, nameAr, price, isAvailable, maxQuantity);

  /// Create a copy of MenuAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuAddonImplCopyWith<_$MenuAddonImpl> get copyWith =>
      __$$MenuAddonImplCopyWithImpl<_$MenuAddonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuAddonImplToJson(
      this,
    );
  }
}

abstract class _MenuAddon implements MenuAddon {
  const factory _MenuAddon(
      {required final String name,
      final String? nameAr,
      required final double price,
      final bool isAvailable,
      final int maxQuantity}) = _$MenuAddonImpl;

  factory _MenuAddon.fromJson(Map<String, dynamic> json) =
      _$MenuAddonImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  double get price;
  @override
  bool get isAvailable;
  @override
  int get maxQuantity;

  /// Create a copy of MenuAddon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuAddonImplCopyWith<_$MenuAddonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuVariation _$MenuVariationFromJson(Map<String, dynamic> json) {
  return _MenuVariation.fromJson(json);
}

/// @nodoc
mixin _$MenuVariation {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  List<VariationOption> get options => throw _privateConstructorUsedError;

  /// Serializes this MenuVariation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuVariationCopyWith<MenuVariation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuVariationCopyWith<$Res> {
  factory $MenuVariationCopyWith(
          MenuVariation value, $Res Function(MenuVariation) then) =
      _$MenuVariationCopyWithImpl<$Res, MenuVariation>;
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      bool isRequired,
      List<VariationOption> options});
}

/// @nodoc
class _$MenuVariationCopyWithImpl<$Res, $Val extends MenuVariation>
    implements $MenuVariationCopyWith<$Res> {
  _$MenuVariationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? isRequired = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<VariationOption>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuVariationImplCopyWith<$Res>
    implements $MenuVariationCopyWith<$Res> {
  factory _$$MenuVariationImplCopyWith(
          _$MenuVariationImpl value, $Res Function(_$MenuVariationImpl) then) =
      __$$MenuVariationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      bool isRequired,
      List<VariationOption> options});
}

/// @nodoc
class __$$MenuVariationImplCopyWithImpl<$Res>
    extends _$MenuVariationCopyWithImpl<$Res, _$MenuVariationImpl>
    implements _$$MenuVariationImplCopyWith<$Res> {
  __$$MenuVariationImplCopyWithImpl(
      _$MenuVariationImpl _value, $Res Function(_$MenuVariationImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? isRequired = null,
    Object? options = null,
  }) {
    return _then(_$MenuVariationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<VariationOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuVariationImpl implements _MenuVariation {
  const _$MenuVariationImpl(
      {required this.name,
      this.nameAr,
      this.isRequired = false,
      final List<VariationOption> options = const []})
      : _options = options;

  factory _$MenuVariationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuVariationImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  @JsonKey()
  final bool isRequired;
  final List<VariationOption> _options;
  @override
  @JsonKey()
  List<VariationOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'MenuVariation(name: $name, nameAr: $nameAr, isRequired: $isRequired, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuVariationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameAr, isRequired,
      const DeepCollectionEquality().hash(_options));

  /// Create a copy of MenuVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuVariationImplCopyWith<_$MenuVariationImpl> get copyWith =>
      __$$MenuVariationImplCopyWithImpl<_$MenuVariationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuVariationImplToJson(
      this,
    );
  }
}

abstract class _MenuVariation implements MenuVariation {
  const factory _MenuVariation(
      {required final String name,
      final String? nameAr,
      final bool isRequired,
      final List<VariationOption> options}) = _$MenuVariationImpl;

  factory _MenuVariation.fromJson(Map<String, dynamic> json) =
      _$MenuVariationImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  bool get isRequired;
  @override
  List<VariationOption> get options;

  /// Create a copy of MenuVariation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuVariationImplCopyWith<_$MenuVariationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VariationOption _$VariationOptionFromJson(Map<String, dynamic> json) {
  return _VariationOption.fromJson(json);
}

/// @nodoc
mixin _$VariationOption {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this VariationOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VariationOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VariationOptionCopyWith<VariationOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VariationOptionCopyWith<$Res> {
  factory $VariationOptionCopyWith(
          VariationOption value, $Res Function(VariationOption) then) =
      _$VariationOptionCopyWithImpl<$Res, VariationOption>;
  @useResult
  $Res call({String name, String? nameAr, double price});
}

/// @nodoc
class _$VariationOptionCopyWithImpl<$Res, $Val extends VariationOption>
    implements $VariationOptionCopyWith<$Res> {
  _$VariationOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VariationOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VariationOptionImplCopyWith<$Res>
    implements $VariationOptionCopyWith<$Res> {
  factory _$$VariationOptionImplCopyWith(_$VariationOptionImpl value,
          $Res Function(_$VariationOptionImpl) then) =
      __$$VariationOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? nameAr, double price});
}

/// @nodoc
class __$$VariationOptionImplCopyWithImpl<$Res>
    extends _$VariationOptionCopyWithImpl<$Res, _$VariationOptionImpl>
    implements _$$VariationOptionImplCopyWith<$Res> {
  __$$VariationOptionImplCopyWithImpl(
      _$VariationOptionImpl _value, $Res Function(_$VariationOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of VariationOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
  }) {
    return _then(_$VariationOptionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VariationOptionImpl implements _VariationOption {
  const _$VariationOptionImpl(
      {required this.name, this.nameAr, this.price = 0.0});

  factory _$VariationOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VariationOptionImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  @JsonKey()
  final double price;

  @override
  String toString() {
    return 'VariationOption(name: $name, nameAr: $nameAr, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VariationOptionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameAr, price);

  /// Create a copy of VariationOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VariationOptionImplCopyWith<_$VariationOptionImpl> get copyWith =>
      __$$VariationOptionImplCopyWithImpl<_$VariationOptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VariationOptionImplToJson(
      this,
    );
  }
}

abstract class _VariationOption implements VariationOption {
  const factory _VariationOption(
      {required final String name,
      final String? nameAr,
      final double price}) = _$VariationOptionImpl;

  factory _VariationOption.fromJson(Map<String, dynamic> json) =
      _$VariationOptionImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  double get price;

  /// Create a copy of VariationOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VariationOptionImplCopyWith<_$VariationOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestaurantSearchParams _$RestaurantSearchParamsFromJson(
    Map<String, dynamic> json) {
  return _RestaurantSearchParams.fromJson(json);
}

/// @nodoc
mixin _$RestaurantSearchParams {
  String? get search => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;
  int? get priceRange => throw _privateConstructorUsedError;
  bool? get isOpen => throw _privateConstructorUsedError;
  String? get sortBy => throw _privateConstructorUsedError;
  String? get sortOrder => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;
  double get maxDistance => throw _privateConstructorUsedError;

  /// Serializes this RestaurantSearchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestaurantSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantSearchParamsCopyWith<RestaurantSearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantSearchParamsCopyWith<$Res> {
  factory $RestaurantSearchParamsCopyWith(RestaurantSearchParams value,
          $Res Function(RestaurantSearchParams) then) =
      _$RestaurantSearchParamsCopyWithImpl<$Res, RestaurantSearchParams>;
  @useResult
  $Res call(
      {String? search,
      String? category,
      String? area,
      int? priceRange,
      bool? isOpen,
      String? sortBy,
      String? sortOrder,
      int page,
      int limit,
      double? lat,
      double? lng,
      double maxDistance});
}

/// @nodoc
class _$RestaurantSearchParamsCopyWithImpl<$Res,
        $Val extends RestaurantSearchParams>
    implements $RestaurantSearchParamsCopyWith<$Res> {
  _$RestaurantSearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestaurantSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? category = freezed,
    Object? area = freezed,
    Object? priceRange = freezed,
    Object? isOpen = freezed,
    Object? sortBy = freezed,
    Object? sortOrder = freezed,
    Object? page = null,
    Object? limit = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? maxDistance = null,
  }) {
    return _then(_value.copyWith(
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int?,
      isOpen: freezed == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool?,
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestaurantSearchParamsImplCopyWith<$Res>
    implements $RestaurantSearchParamsCopyWith<$Res> {
  factory _$$RestaurantSearchParamsImplCopyWith(
          _$RestaurantSearchParamsImpl value,
          $Res Function(_$RestaurantSearchParamsImpl) then) =
      __$$RestaurantSearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? search,
      String? category,
      String? area,
      int? priceRange,
      bool? isOpen,
      String? sortBy,
      String? sortOrder,
      int page,
      int limit,
      double? lat,
      double? lng,
      double maxDistance});
}

/// @nodoc
class __$$RestaurantSearchParamsImplCopyWithImpl<$Res>
    extends _$RestaurantSearchParamsCopyWithImpl<$Res,
        _$RestaurantSearchParamsImpl>
    implements _$$RestaurantSearchParamsImplCopyWith<$Res> {
  __$$RestaurantSearchParamsImplCopyWithImpl(
      _$RestaurantSearchParamsImpl _value,
      $Res Function(_$RestaurantSearchParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestaurantSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? category = freezed,
    Object? area = freezed,
    Object? priceRange = freezed,
    Object? isOpen = freezed,
    Object? sortBy = freezed,
    Object? sortOrder = freezed,
    Object? page = null,
    Object? limit = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? maxDistance = null,
  }) {
    return _then(_$RestaurantSearchParamsImpl(
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int?,
      isOpen: freezed == isOpen
          ? _value.isOpen
          : isOpen // ignore: cast_nullable_to_non_nullable
              as bool?,
      sortBy: freezed == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantSearchParamsImpl implements _RestaurantSearchParams {
  const _$RestaurantSearchParamsImpl(
      {this.search,
      this.category,
      this.area,
      this.priceRange,
      this.isOpen,
      this.sortBy,
      this.sortOrder,
      this.page = 1,
      this.limit = 20,
      this.lat,
      this.lng,
      this.maxDistance = 10});

  factory _$RestaurantSearchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantSearchParamsImplFromJson(json);

  @override
  final String? search;
  @override
  final String? category;
  @override
  final String? area;
  @override
  final int? priceRange;
  @override
  final bool? isOpen;
  @override
  final String? sortBy;
  @override
  final String? sortOrder;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  final double? lat;
  @override
  final double? lng;
  @override
  @JsonKey()
  final double maxDistance;

  @override
  String toString() {
    return 'RestaurantSearchParams(search: $search, category: $category, area: $area, priceRange: $priceRange, isOpen: $isOpen, sortBy: $sortBy, sortOrder: $sortOrder, page: $page, limit: $limit, lat: $lat, lng: $lng, maxDistance: $maxDistance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantSearchParamsImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      search,
      category,
      area,
      priceRange,
      isOpen,
      sortBy,
      sortOrder,
      page,
      limit,
      lat,
      lng,
      maxDistance);

  /// Create a copy of RestaurantSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantSearchParamsImplCopyWith<_$RestaurantSearchParamsImpl>
      get copyWith => __$$RestaurantSearchParamsImplCopyWithImpl<
          _$RestaurantSearchParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantSearchParamsImplToJson(
      this,
    );
  }
}

abstract class _RestaurantSearchParams implements RestaurantSearchParams {
  const factory _RestaurantSearchParams(
      {final String? search,
      final String? category,
      final String? area,
      final int? priceRange,
      final bool? isOpen,
      final String? sortBy,
      final String? sortOrder,
      final int page,
      final int limit,
      final double? lat,
      final double? lng,
      final double maxDistance}) = _$RestaurantSearchParamsImpl;

  factory _RestaurantSearchParams.fromJson(Map<String, dynamic> json) =
      _$RestaurantSearchParamsImpl.fromJson;

  @override
  String? get search;
  @override
  String? get category;
  @override
  String? get area;
  @override
  int? get priceRange;
  @override
  bool? get isOpen;
  @override
  String? get sortBy;
  @override
  String? get sortOrder;
  @override
  int get page;
  @override
  int get limit;
  @override
  double? get lat;
  @override
  double? get lng;
  @override
  double get maxDistance;

  /// Create a copy of RestaurantSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantSearchParamsImplCopyWith<_$RestaurantSearchParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
