// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return _Review.fromJson(json);
}

/// @nodoc
mixin _$Review {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get restaurantId => throw _privateConstructorUsedError;
  String? get driverId => throw _privateConstructorUsedError;
  double get restaurantRating => throw _privateConstructorUsedError;
  double get foodRating => throw _privateConstructorUsedError;
  double? get driverRating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get restaurantReply => throw _privateConstructorUsedError;
  DateTime? get repliedAt => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;
  bool get isReported => throw _privateConstructorUsedError;
  String? get reportReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCopyWith<Review> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCopyWith<$Res> {
  factory $ReviewCopyWith(Review value, $Res Function(Review) then) =
      _$ReviewCopyWithImpl<$Res, Review>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String customerId,
      String restaurantId,
      String? driverId,
      double restaurantRating,
      double foodRating,
      double? driverRating,
      String? comment,
      List<String> images,
      String? restaurantReply,
      DateTime? repliedAt,
      bool isVisible,
      bool isReported,
      String? reportReason,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ReviewCopyWithImpl<$Res, $Val extends Review>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? customerId = null,
    Object? restaurantId = null,
    Object? driverId = freezed,
    Object? restaurantRating = null,
    Object? foodRating = null,
    Object? driverRating = freezed,
    Object? comment = freezed,
    Object? images = null,
    Object? restaurantReply = freezed,
    Object? repliedAt = freezed,
    Object? isVisible = null,
    Object? isReported = null,
    Object? reportReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantRating: null == restaurantRating
          ? _value.restaurantRating
          : restaurantRating // ignore: cast_nullable_to_non_nullable
              as double,
      foodRating: null == foodRating
          ? _value.foodRating
          : foodRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: freezed == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      restaurantReply: freezed == restaurantReply
          ? _value.restaurantReply
          : restaurantReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _value.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isReported: null == isReported
          ? _value.isReported
          : isReported // ignore: cast_nullable_to_non_nullable
              as bool,
      reportReason: freezed == reportReason
          ? _value.reportReason
          : reportReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewImplCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$$ReviewImplCopyWith(
          _$ReviewImpl value, $Res Function(_$ReviewImpl) then) =
      __$$ReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String customerId,
      String restaurantId,
      String? driverId,
      double restaurantRating,
      double foodRating,
      double? driverRating,
      String? comment,
      List<String> images,
      String? restaurantReply,
      DateTime? repliedAt,
      bool isVisible,
      bool isReported,
      String? reportReason,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$ReviewImplCopyWithImpl<$Res>
    extends _$ReviewCopyWithImpl<$Res, _$ReviewImpl>
    implements _$$ReviewImplCopyWith<$Res> {
  __$$ReviewImplCopyWithImpl(
      _$ReviewImpl _value, $Res Function(_$ReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? customerId = null,
    Object? restaurantId = null,
    Object? driverId = freezed,
    Object? restaurantRating = null,
    Object? foodRating = null,
    Object? driverRating = freezed,
    Object? comment = freezed,
    Object? images = null,
    Object? restaurantReply = freezed,
    Object? repliedAt = freezed,
    Object? isVisible = null,
    Object? isReported = null,
    Object? reportReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantRating: null == restaurantRating
          ? _value.restaurantRating
          : restaurantRating // ignore: cast_nullable_to_non_nullable
              as double,
      foodRating: null == foodRating
          ? _value.foodRating
          : foodRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: freezed == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      restaurantReply: freezed == restaurantReply
          ? _value.restaurantReply
          : restaurantReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _value.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isReported: null == isReported
          ? _value.isReported
          : isReported // ignore: cast_nullable_to_non_nullable
              as bool,
      reportReason: freezed == reportReason
          ? _value.reportReason
          : reportReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewImpl implements _Review {
  const _$ReviewImpl(
      {required this.id,
      required this.orderId,
      required this.customerId,
      required this.restaurantId,
      this.driverId,
      required this.restaurantRating,
      required this.foodRating,
      this.driverRating,
      this.comment,
      final List<String> images = const [],
      this.restaurantReply,
      this.repliedAt,
      this.isVisible = true,
      this.isReported = false,
      this.reportReason,
      required this.createdAt,
      required this.updatedAt})
      : _images = images;

  factory _$ReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String customerId;
  @override
  final String restaurantId;
  @override
  final String? driverId;
  @override
  final double restaurantRating;
  @override
  final double foodRating;
  @override
  final double? driverRating;
  @override
  final String? comment;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? restaurantReply;
  @override
  final DateTime? repliedAt;
  @override
  @JsonKey()
  final bool isVisible;
  @override
  @JsonKey()
  final bool isReported;
  @override
  final String? reportReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Review(id: $id, orderId: $orderId, customerId: $customerId, restaurantId: $restaurantId, driverId: $driverId, restaurantRating: $restaurantRating, foodRating: $foodRating, driverRating: $driverRating, comment: $comment, images: $images, restaurantReply: $restaurantReply, repliedAt: $repliedAt, isVisible: $isVisible, isReported: $isReported, reportReason: $reportReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.restaurantRating, restaurantRating) ||
                other.restaurantRating == restaurantRating) &&
            (identical(other.foodRating, foodRating) ||
                other.foodRating == foodRating) &&
            (identical(other.driverRating, driverRating) ||
                other.driverRating == driverRating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.restaurantReply, restaurantReply) ||
                other.restaurantReply == restaurantReply) &&
            (identical(other.repliedAt, repliedAt) ||
                other.repliedAt == repliedAt) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.isReported, isReported) ||
                other.isReported == isReported) &&
            (identical(other.reportReason, reportReason) ||
                other.reportReason == reportReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      customerId,
      restaurantId,
      driverId,
      restaurantRating,
      foodRating,
      driverRating,
      comment,
      const DeepCollectionEquality().hash(_images),
      restaurantReply,
      repliedAt,
      isVisible,
      isReported,
      reportReason,
      createdAt,
      updatedAt);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      __$$ReviewImplCopyWithImpl<_$ReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewImplToJson(
      this,
    );
  }
}

abstract class _Review implements Review {
  const factory _Review(
      {required final String id,
      required final String orderId,
      required final String customerId,
      required final String restaurantId,
      final String? driverId,
      required final double restaurantRating,
      required final double foodRating,
      final double? driverRating,
      final String? comment,
      final List<String> images,
      final String? restaurantReply,
      final DateTime? repliedAt,
      final bool isVisible,
      final bool isReported,
      final String? reportReason,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ReviewImpl;

  factory _Review.fromJson(Map<String, dynamic> json) = _$ReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get customerId;
  @override
  String get restaurantId;
  @override
  String? get driverId;
  @override
  double get restaurantRating;
  @override
  double get foodRating;
  @override
  double? get driverRating;
  @override
  String? get comment;
  @override
  List<String> get images;
  @override
  String? get restaurantReply;
  @override
  DateTime? get repliedAt;
  @override
  bool get isVisible;
  @override
  bool get isReported;
  @override
  String? get reportReason;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RateOrderRequest _$RateOrderRequestFromJson(Map<String, dynamic> json) {
  return _RateOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$RateOrderRequest {
  double? get restaurant => throw _privateConstructorUsedError;
  double? get driver => throw _privateConstructorUsedError;
  double? get food => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;

  /// Serializes this RateOrderRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RateOrderRequestCopyWith<RateOrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateOrderRequestCopyWith<$Res> {
  factory $RateOrderRequestCopyWith(
          RateOrderRequest value, $Res Function(RateOrderRequest) then) =
      _$RateOrderRequestCopyWithImpl<$Res, RateOrderRequest>;
  @useResult
  $Res call({double? restaurant, double? driver, double? food, String comment});
}

/// @nodoc
class _$RateOrderRequestCopyWithImpl<$Res, $Val extends RateOrderRequest>
    implements $RateOrderRequestCopyWith<$Res> {
  _$RateOrderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? driver = freezed,
    Object? food = freezed,
    Object? comment = null,
  }) {
    return _then(_value.copyWith(
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as double?,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as double?,
      food: freezed == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RateOrderRequestImplCopyWith<$Res>
    implements $RateOrderRequestCopyWith<$Res> {
  factory _$$RateOrderRequestImplCopyWith(_$RateOrderRequestImpl value,
          $Res Function(_$RateOrderRequestImpl) then) =
      __$$RateOrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? restaurant, double? driver, double? food, String comment});
}

/// @nodoc
class __$$RateOrderRequestImplCopyWithImpl<$Res>
    extends _$RateOrderRequestCopyWithImpl<$Res, _$RateOrderRequestImpl>
    implements _$$RateOrderRequestImplCopyWith<$Res> {
  __$$RateOrderRequestImplCopyWithImpl(_$RateOrderRequestImpl _value,
      $Res Function(_$RateOrderRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? driver = freezed,
    Object? food = freezed,
    Object? comment = null,
  }) {
    return _then(_$RateOrderRequestImpl(
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as double?,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as double?,
      food: freezed == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RateOrderRequestImpl implements _RateOrderRequest {
  const _$RateOrderRequestImpl(
      {this.restaurant, this.driver, this.food, this.comment = ''});

  factory _$RateOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateOrderRequestImplFromJson(json);

  @override
  final double? restaurant;
  @override
  final double? driver;
  @override
  final double? food;
  @override
  @JsonKey()
  final String comment;

  @override
  String toString() {
    return 'RateOrderRequest(restaurant: $restaurant, driver: $driver, food: $food, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateOrderRequestImpl &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.food, food) || other.food == food) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, restaurant, driver, food, comment);

  /// Create a copy of RateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateOrderRequestImplCopyWith<_$RateOrderRequestImpl> get copyWith =>
      __$$RateOrderRequestImplCopyWithImpl<_$RateOrderRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateOrderRequestImplToJson(
      this,
    );
  }
}

abstract class _RateOrderRequest implements RateOrderRequest {
  const factory _RateOrderRequest(
      {final double? restaurant,
      final double? driver,
      final double? food,
      final String comment}) = _$RateOrderRequestImpl;

  factory _RateOrderRequest.fromJson(Map<String, dynamic> json) =
      _$RateOrderRequestImpl.fromJson;

  @override
  double? get restaurant;
  @override
  double? get driver;
  @override
  double? get food;
  @override
  String get comment;

  /// Create a copy of RateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateOrderRequestImplCopyWith<_$RateOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerReview _$CustomerReviewFromJson(Map<String, dynamic> json) {
  return _CustomerReview.fromJson(json);
}

/// @nodoc
mixin _$CustomerReview {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  String get restaurantId => throw _privateConstructorUsedError;
  String get restaurantName => throw _privateConstructorUsedError;
  String? get restaurantLogo => throw _privateConstructorUsedError;
  double get restaurantRating => throw _privateConstructorUsedError;
  double get foodRating => throw _privateConstructorUsedError;
  double? get driverRating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  String? get restaurantReply => throw _privateConstructorUsedError;
  DateTime? get repliedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerReviewCopyWith<CustomerReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerReviewCopyWith<$Res> {
  factory $CustomerReviewCopyWith(
          CustomerReview value, $Res Function(CustomerReview) then) =
      _$CustomerReviewCopyWithImpl<$Res, CustomerReview>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String orderNumber,
      String restaurantId,
      String restaurantName,
      String? restaurantLogo,
      double restaurantRating,
      double foodRating,
      double? driverRating,
      String? comment,
      String? restaurantReply,
      DateTime? repliedAt,
      DateTime createdAt});
}

/// @nodoc
class _$CustomerReviewCopyWithImpl<$Res, $Val extends CustomerReview>
    implements $CustomerReviewCopyWith<$Res> {
  _$CustomerReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? orderNumber = null,
    Object? restaurantId = null,
    Object? restaurantName = null,
    Object? restaurantLogo = freezed,
    Object? restaurantRating = null,
    Object? foodRating = null,
    Object? driverRating = freezed,
    Object? comment = freezed,
    Object? restaurantReply = freezed,
    Object? repliedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantLogo: freezed == restaurantLogo
          ? _value.restaurantLogo
          : restaurantLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantRating: null == restaurantRating
          ? _value.restaurantRating
          : restaurantRating // ignore: cast_nullable_to_non_nullable
              as double,
      foodRating: null == foodRating
          ? _value.foodRating
          : foodRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: freezed == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantReply: freezed == restaurantReply
          ? _value.restaurantReply
          : restaurantReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _value.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerReviewImplCopyWith<$Res>
    implements $CustomerReviewCopyWith<$Res> {
  factory _$$CustomerReviewImplCopyWith(_$CustomerReviewImpl value,
          $Res Function(_$CustomerReviewImpl) then) =
      __$$CustomerReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String orderNumber,
      String restaurantId,
      String restaurantName,
      String? restaurantLogo,
      double restaurantRating,
      double foodRating,
      double? driverRating,
      String? comment,
      String? restaurantReply,
      DateTime? repliedAt,
      DateTime createdAt});
}

/// @nodoc
class __$$CustomerReviewImplCopyWithImpl<$Res>
    extends _$CustomerReviewCopyWithImpl<$Res, _$CustomerReviewImpl>
    implements _$$CustomerReviewImplCopyWith<$Res> {
  __$$CustomerReviewImplCopyWithImpl(
      _$CustomerReviewImpl _value, $Res Function(_$CustomerReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomerReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? orderNumber = null,
    Object? restaurantId = null,
    Object? restaurantName = null,
    Object? restaurantLogo = freezed,
    Object? restaurantRating = null,
    Object? foodRating = null,
    Object? driverRating = freezed,
    Object? comment = freezed,
    Object? restaurantReply = freezed,
    Object? repliedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$CustomerReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantLogo: freezed == restaurantLogo
          ? _value.restaurantLogo
          : restaurantLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantRating: null == restaurantRating
          ? _value.restaurantRating
          : restaurantRating // ignore: cast_nullable_to_non_nullable
              as double,
      foodRating: null == foodRating
          ? _value.foodRating
          : foodRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: freezed == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantReply: freezed == restaurantReply
          ? _value.restaurantReply
          : restaurantReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _value.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerReviewImpl implements _CustomerReview {
  const _$CustomerReviewImpl(
      {required this.id,
      required this.orderId,
      required this.orderNumber,
      required this.restaurantId,
      required this.restaurantName,
      this.restaurantLogo,
      required this.restaurantRating,
      required this.foodRating,
      this.driverRating,
      this.comment,
      this.restaurantReply,
      this.repliedAt,
      required this.createdAt});

  factory _$CustomerReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String orderNumber;
  @override
  final String restaurantId;
  @override
  final String restaurantName;
  @override
  final String? restaurantLogo;
  @override
  final double restaurantRating;
  @override
  final double foodRating;
  @override
  final double? driverRating;
  @override
  final String? comment;
  @override
  final String? restaurantReply;
  @override
  final DateTime? repliedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CustomerReview(id: $id, orderId: $orderId, orderNumber: $orderNumber, restaurantId: $restaurantId, restaurantName: $restaurantName, restaurantLogo: $restaurantLogo, restaurantRating: $restaurantRating, foodRating: $foodRating, driverRating: $driverRating, comment: $comment, restaurantReply: $restaurantReply, repliedAt: $repliedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.restaurantLogo, restaurantLogo) ||
                other.restaurantLogo == restaurantLogo) &&
            (identical(other.restaurantRating, restaurantRating) ||
                other.restaurantRating == restaurantRating) &&
            (identical(other.foodRating, foodRating) ||
                other.foodRating == foodRating) &&
            (identical(other.driverRating, driverRating) ||
                other.driverRating == driverRating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.restaurantReply, restaurantReply) ||
                other.restaurantReply == restaurantReply) &&
            (identical(other.repliedAt, repliedAt) ||
                other.repliedAt == repliedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      orderNumber,
      restaurantId,
      restaurantName,
      restaurantLogo,
      restaurantRating,
      foodRating,
      driverRating,
      comment,
      restaurantReply,
      repliedAt,
      createdAt);

  /// Create a copy of CustomerReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerReviewImplCopyWith<_$CustomerReviewImpl> get copyWith =>
      __$$CustomerReviewImplCopyWithImpl<_$CustomerReviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerReviewImplToJson(
      this,
    );
  }
}

abstract class _CustomerReview implements CustomerReview {
  const factory _CustomerReview(
      {required final String id,
      required final String orderId,
      required final String orderNumber,
      required final String restaurantId,
      required final String restaurantName,
      final String? restaurantLogo,
      required final double restaurantRating,
      required final double foodRating,
      final double? driverRating,
      final String? comment,
      final String? restaurantReply,
      final DateTime? repliedAt,
      required final DateTime createdAt}) = _$CustomerReviewImpl;

  factory _CustomerReview.fromJson(Map<String, dynamic> json) =
      _$CustomerReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get orderNumber;
  @override
  String get restaurantId;
  @override
  String get restaurantName;
  @override
  String? get restaurantLogo;
  @override
  double get restaurantRating;
  @override
  double get foodRating;
  @override
  double? get driverRating;
  @override
  String? get comment;
  @override
  String? get restaurantReply;
  @override
  DateTime? get repliedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of CustomerReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerReviewImplCopyWith<_$CustomerReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
