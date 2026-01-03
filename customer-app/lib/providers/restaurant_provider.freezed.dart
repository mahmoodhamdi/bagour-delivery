// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeaturedRestaurantsState {
  List<Restaurant> get restaurants => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of FeaturedRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeaturedRestaurantsStateCopyWith<FeaturedRestaurantsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturedRestaurantsStateCopyWith<$Res> {
  factory $FeaturedRestaurantsStateCopyWith(FeaturedRestaurantsState value,
          $Res Function(FeaturedRestaurantsState) then) =
      _$FeaturedRestaurantsStateCopyWithImpl<$Res, FeaturedRestaurantsState>;
  @useResult
  $Res call({List<Restaurant> restaurants, bool isLoading, String? error});
}

/// @nodoc
class _$FeaturedRestaurantsStateCopyWithImpl<$Res,
        $Val extends FeaturedRestaurantsState>
    implements $FeaturedRestaurantsStateCopyWith<$Res> {
  _$FeaturedRestaurantsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeaturedRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      restaurants: null == restaurants
          ? _value.restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeaturedRestaurantsStateImplCopyWith<$Res>
    implements $FeaturedRestaurantsStateCopyWith<$Res> {
  factory _$$FeaturedRestaurantsStateImplCopyWith(
          _$FeaturedRestaurantsStateImpl value,
          $Res Function(_$FeaturedRestaurantsStateImpl) then) =
      __$$FeaturedRestaurantsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Restaurant> restaurants, bool isLoading, String? error});
}

/// @nodoc
class __$$FeaturedRestaurantsStateImplCopyWithImpl<$Res>
    extends _$FeaturedRestaurantsStateCopyWithImpl<$Res,
        _$FeaturedRestaurantsStateImpl>
    implements _$$FeaturedRestaurantsStateImplCopyWith<$Res> {
  __$$FeaturedRestaurantsStateImplCopyWithImpl(
      _$FeaturedRestaurantsStateImpl _value,
      $Res Function(_$FeaturedRestaurantsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeaturedRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$FeaturedRestaurantsStateImpl(
      restaurants: null == restaurants
          ? _value._restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$FeaturedRestaurantsStateImpl implements _FeaturedRestaurantsState {
  const _$FeaturedRestaurantsStateImpl(
      {final List<Restaurant> restaurants = const [],
      this.isLoading = false,
      this.error})
      : _restaurants = restaurants;

  final List<Restaurant> _restaurants;
  @override
  @JsonKey()
  List<Restaurant> get restaurants {
    if (_restaurants is EqualUnmodifiableListView) return _restaurants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_restaurants);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'FeaturedRestaurantsState(restaurants: $restaurants, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeaturedRestaurantsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._restaurants, _restaurants) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_restaurants), isLoading, error);

  /// Create a copy of FeaturedRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeaturedRestaurantsStateImplCopyWith<_$FeaturedRestaurantsStateImpl>
      get copyWith => __$$FeaturedRestaurantsStateImplCopyWithImpl<
          _$FeaturedRestaurantsStateImpl>(this, _$identity);
}

abstract class _FeaturedRestaurantsState implements FeaturedRestaurantsState {
  const factory _FeaturedRestaurantsState(
      {final List<Restaurant> restaurants,
      final bool isLoading,
      final String? error}) = _$FeaturedRestaurantsStateImpl;

  @override
  List<Restaurant> get restaurants;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of FeaturedRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeaturedRestaurantsStateImplCopyWith<_$FeaturedRestaurantsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NearbyRestaurantsState {
  List<Restaurant> get restaurants => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;

  /// Create a copy of NearbyRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NearbyRestaurantsStateCopyWith<NearbyRestaurantsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NearbyRestaurantsStateCopyWith<$Res> {
  factory $NearbyRestaurantsStateCopyWith(NearbyRestaurantsState value,
          $Res Function(NearbyRestaurantsState) then) =
      _$NearbyRestaurantsStateCopyWithImpl<$Res, NearbyRestaurantsState>;
  @useResult
  $Res call(
      {List<Restaurant> restaurants,
      bool isLoading,
      String? error,
      double? lat,
      double? lng});
}

/// @nodoc
class _$NearbyRestaurantsStateCopyWithImpl<$Res,
        $Val extends NearbyRestaurantsState>
    implements $NearbyRestaurantsStateCopyWith<$Res> {
  _$NearbyRestaurantsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NearbyRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_value.copyWith(
      restaurants: null == restaurants
          ? _value.restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NearbyRestaurantsStateImplCopyWith<$Res>
    implements $NearbyRestaurantsStateCopyWith<$Res> {
  factory _$$NearbyRestaurantsStateImplCopyWith(
          _$NearbyRestaurantsStateImpl value,
          $Res Function(_$NearbyRestaurantsStateImpl) then) =
      __$$NearbyRestaurantsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Restaurant> restaurants,
      bool isLoading,
      String? error,
      double? lat,
      double? lng});
}

/// @nodoc
class __$$NearbyRestaurantsStateImplCopyWithImpl<$Res>
    extends _$NearbyRestaurantsStateCopyWithImpl<$Res,
        _$NearbyRestaurantsStateImpl>
    implements _$$NearbyRestaurantsStateImplCopyWith<$Res> {
  __$$NearbyRestaurantsStateImplCopyWithImpl(
      _$NearbyRestaurantsStateImpl _value,
      $Res Function(_$NearbyRestaurantsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NearbyRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_$NearbyRestaurantsStateImpl(
      restaurants: null == restaurants
          ? _value._restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$NearbyRestaurantsStateImpl implements _NearbyRestaurantsState {
  const _$NearbyRestaurantsStateImpl(
      {final List<Restaurant> restaurants = const [],
      this.isLoading = false,
      this.error,
      this.lat,
      this.lng})
      : _restaurants = restaurants;

  final List<Restaurant> _restaurants;
  @override
  @JsonKey()
  List<Restaurant> get restaurants {
    if (_restaurants is EqualUnmodifiableListView) return _restaurants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_restaurants);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final double? lat;
  @override
  final double? lng;

  @override
  String toString() {
    return 'NearbyRestaurantsState(restaurants: $restaurants, isLoading: $isLoading, error: $error, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NearbyRestaurantsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._restaurants, _restaurants) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_restaurants),
      isLoading,
      error,
      lat,
      lng);

  /// Create a copy of NearbyRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NearbyRestaurantsStateImplCopyWith<_$NearbyRestaurantsStateImpl>
      get copyWith => __$$NearbyRestaurantsStateImplCopyWithImpl<
          _$NearbyRestaurantsStateImpl>(this, _$identity);
}

abstract class _NearbyRestaurantsState implements NearbyRestaurantsState {
  const factory _NearbyRestaurantsState(
      {final List<Restaurant> restaurants,
      final bool isLoading,
      final String? error,
      final double? lat,
      final double? lng}) = _$NearbyRestaurantsStateImpl;

  @override
  List<Restaurant> get restaurants;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  double? get lat;
  @override
  double? get lng;

  /// Create a copy of NearbyRestaurantsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NearbyRestaurantsStateImplCopyWith<_$NearbyRestaurantsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestaurantSearchState {
  List<Restaurant> get restaurants => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  RestaurantSearchParams? get params => throw _privateConstructorUsedError;

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantSearchStateCopyWith<RestaurantSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantSearchStateCopyWith<$Res> {
  factory $RestaurantSearchStateCopyWith(RestaurantSearchState value,
          $Res Function(RestaurantSearchState) then) =
      _$RestaurantSearchStateCopyWithImpl<$Res, RestaurantSearchState>;
  @useResult
  $Res call(
      {List<Restaurant> restaurants,
      bool isLoading,
      String? error,
      int currentPage,
      int totalPages,
      bool hasMore,
      RestaurantSearchParams? params});

  $RestaurantSearchParamsCopyWith<$Res>? get params;
}

/// @nodoc
class _$RestaurantSearchStateCopyWithImpl<$Res,
        $Val extends RestaurantSearchState>
    implements $RestaurantSearchStateCopyWith<$Res> {
  _$RestaurantSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? hasMore = null,
    Object? params = freezed,
  }) {
    return _then(_value.copyWith(
      restaurants: null == restaurants
          ? _value.restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      params: freezed == params
          ? _value.params
          : params // ignore: cast_nullable_to_non_nullable
              as RestaurantSearchParams?,
    ) as $Val);
  }

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestaurantSearchParamsCopyWith<$Res>? get params {
    if (_value.params == null) {
      return null;
    }

    return $RestaurantSearchParamsCopyWith<$Res>(_value.params!, (value) {
      return _then(_value.copyWith(params: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestaurantSearchStateImplCopyWith<$Res>
    implements $RestaurantSearchStateCopyWith<$Res> {
  factory _$$RestaurantSearchStateImplCopyWith(
          _$RestaurantSearchStateImpl value,
          $Res Function(_$RestaurantSearchStateImpl) then) =
      __$$RestaurantSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Restaurant> restaurants,
      bool isLoading,
      String? error,
      int currentPage,
      int totalPages,
      bool hasMore,
      RestaurantSearchParams? params});

  @override
  $RestaurantSearchParamsCopyWith<$Res>? get params;
}

/// @nodoc
class __$$RestaurantSearchStateImplCopyWithImpl<$Res>
    extends _$RestaurantSearchStateCopyWithImpl<$Res,
        _$RestaurantSearchStateImpl>
    implements _$$RestaurantSearchStateImplCopyWith<$Res> {
  __$$RestaurantSearchStateImplCopyWithImpl(_$RestaurantSearchStateImpl _value,
      $Res Function(_$RestaurantSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? hasMore = null,
    Object? params = freezed,
  }) {
    return _then(_$RestaurantSearchStateImpl(
      restaurants: null == restaurants
          ? _value._restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      params: freezed == params
          ? _value.params
          : params // ignore: cast_nullable_to_non_nullable
              as RestaurantSearchParams?,
    ));
  }
}

/// @nodoc

class _$RestaurantSearchStateImpl implements _RestaurantSearchState {
  const _$RestaurantSearchStateImpl(
      {final List<Restaurant> restaurants = const [],
      this.isLoading = false,
      this.error,
      this.currentPage = 1,
      this.totalPages = 1,
      this.hasMore = false,
      this.params})
      : _restaurants = restaurants;

  final List<Restaurant> _restaurants;
  @override
  @JsonKey()
  List<Restaurant> get restaurants {
    if (_restaurants is EqualUnmodifiableListView) return _restaurants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_restaurants);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final RestaurantSearchParams? params;

  @override
  String toString() {
    return 'RestaurantSearchState(restaurants: $restaurants, isLoading: $isLoading, error: $error, currentPage: $currentPage, totalPages: $totalPages, hasMore: $hasMore, params: $params)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantSearchStateImpl &&
            const DeepCollectionEquality()
                .equals(other._restaurants, _restaurants) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.params, params) || other.params == params));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_restaurants),
      isLoading,
      error,
      currentPage,
      totalPages,
      hasMore,
      params);

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantSearchStateImplCopyWith<_$RestaurantSearchStateImpl>
      get copyWith => __$$RestaurantSearchStateImplCopyWithImpl<
          _$RestaurantSearchStateImpl>(this, _$identity);
}

abstract class _RestaurantSearchState implements RestaurantSearchState {
  const factory _RestaurantSearchState(
      {final List<Restaurant> restaurants,
      final bool isLoading,
      final String? error,
      final int currentPage,
      final int totalPages,
      final bool hasMore,
      final RestaurantSearchParams? params}) = _$RestaurantSearchStateImpl;

  @override
  List<Restaurant> get restaurants;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get hasMore;
  @override
  RestaurantSearchParams? get params;

  /// Create a copy of RestaurantSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantSearchStateImplCopyWith<_$RestaurantSearchStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestaurantDetailsState {
  Restaurant? get restaurant => throw _privateConstructorUsedError;
  List<MenuCategory> get menu => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantDetailsStateCopyWith<RestaurantDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantDetailsStateCopyWith<$Res> {
  factory $RestaurantDetailsStateCopyWith(RestaurantDetailsState value,
          $Res Function(RestaurantDetailsState) then) =
      _$RestaurantDetailsStateCopyWithImpl<$Res, RestaurantDetailsState>;
  @useResult
  $Res call(
      {Restaurant? restaurant,
      List<MenuCategory> menu,
      bool isLoading,
      String? error});

  $RestaurantCopyWith<$Res>? get restaurant;
}

/// @nodoc
class _$RestaurantDetailsStateCopyWithImpl<$Res,
        $Val extends RestaurantDetailsState>
    implements $RestaurantDetailsStateCopyWith<$Res> {
  _$RestaurantDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? menu = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as Restaurant?,
      menu: null == menu
          ? _value.menu
          : menu // ignore: cast_nullable_to_non_nullable
              as List<MenuCategory>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestaurantCopyWith<$Res>? get restaurant {
    if (_value.restaurant == null) {
      return null;
    }

    return $RestaurantCopyWith<$Res>(_value.restaurant!, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestaurantDetailsStateImplCopyWith<$Res>
    implements $RestaurantDetailsStateCopyWith<$Res> {
  factory _$$RestaurantDetailsStateImplCopyWith(
          _$RestaurantDetailsStateImpl value,
          $Res Function(_$RestaurantDetailsStateImpl) then) =
      __$$RestaurantDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Restaurant? restaurant,
      List<MenuCategory> menu,
      bool isLoading,
      String? error});

  @override
  $RestaurantCopyWith<$Res>? get restaurant;
}

/// @nodoc
class __$$RestaurantDetailsStateImplCopyWithImpl<$Res>
    extends _$RestaurantDetailsStateCopyWithImpl<$Res,
        _$RestaurantDetailsStateImpl>
    implements _$$RestaurantDetailsStateImplCopyWith<$Res> {
  __$$RestaurantDetailsStateImplCopyWithImpl(
      _$RestaurantDetailsStateImpl _value,
      $Res Function(_$RestaurantDetailsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? menu = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$RestaurantDetailsStateImpl(
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as Restaurant?,
      menu: null == menu
          ? _value._menu
          : menu // ignore: cast_nullable_to_non_nullable
              as List<MenuCategory>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RestaurantDetailsStateImpl implements _RestaurantDetailsState {
  const _$RestaurantDetailsStateImpl(
      {this.restaurant,
      final List<MenuCategory> menu = const [],
      this.isLoading = false,
      this.error})
      : _menu = menu;

  @override
  final Restaurant? restaurant;
  final List<MenuCategory> _menu;
  @override
  @JsonKey()
  List<MenuCategory> get menu {
    if (_menu is EqualUnmodifiableListView) return _menu;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_menu);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'RestaurantDetailsState(restaurant: $restaurant, menu: $menu, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantDetailsStateImpl &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            const DeepCollectionEquality().equals(other._menu, _menu) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, restaurant,
      const DeepCollectionEquality().hash(_menu), isLoading, error);

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantDetailsStateImplCopyWith<_$RestaurantDetailsStateImpl>
      get copyWith => __$$RestaurantDetailsStateImplCopyWithImpl<
          _$RestaurantDetailsStateImpl>(this, _$identity);
}

abstract class _RestaurantDetailsState implements RestaurantDetailsState {
  const factory _RestaurantDetailsState(
      {final Restaurant? restaurant,
      final List<MenuCategory> menu,
      final bool isLoading,
      final String? error}) = _$RestaurantDetailsStateImpl;

  @override
  Restaurant? get restaurant;
  @override
  List<MenuCategory> get menu;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of RestaurantDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantDetailsStateImplCopyWith<_$RestaurantDetailsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FavoritesState {
  List<Restaurant> get restaurants => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoritesStateCopyWith<FavoritesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoritesStateCopyWith<$Res> {
  factory $FavoritesStateCopyWith(
          FavoritesState value, $Res Function(FavoritesState) then) =
      _$FavoritesStateCopyWithImpl<$Res, FavoritesState>;
  @useResult
  $Res call({List<Restaurant> restaurants, bool isLoading, String? error});
}

/// @nodoc
class _$FavoritesStateCopyWithImpl<$Res, $Val extends FavoritesState>
    implements $FavoritesStateCopyWith<$Res> {
  _$FavoritesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      restaurants: null == restaurants
          ? _value.restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FavoritesStateImplCopyWith<$Res>
    implements $FavoritesStateCopyWith<$Res> {
  factory _$$FavoritesStateImplCopyWith(_$FavoritesStateImpl value,
          $Res Function(_$FavoritesStateImpl) then) =
      __$$FavoritesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Restaurant> restaurants, bool isLoading, String? error});
}

/// @nodoc
class __$$FavoritesStateImplCopyWithImpl<$Res>
    extends _$FavoritesStateCopyWithImpl<$Res, _$FavoritesStateImpl>
    implements _$$FavoritesStateImplCopyWith<$Res> {
  __$$FavoritesStateImplCopyWithImpl(
      _$FavoritesStateImpl _value, $Res Function(_$FavoritesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurants = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$FavoritesStateImpl(
      restaurants: null == restaurants
          ? _value._restaurants
          : restaurants // ignore: cast_nullable_to_non_nullable
              as List<Restaurant>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$FavoritesStateImpl implements _FavoritesState {
  const _$FavoritesStateImpl(
      {final List<Restaurant> restaurants = const [],
      this.isLoading = false,
      this.error})
      : _restaurants = restaurants;

  final List<Restaurant> _restaurants;
  @override
  @JsonKey()
  List<Restaurant> get restaurants {
    if (_restaurants is EqualUnmodifiableListView) return _restaurants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_restaurants);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'FavoritesState(restaurants: $restaurants, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoritesStateImpl &&
            const DeepCollectionEquality()
                .equals(other._restaurants, _restaurants) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_restaurants), isLoading, error);

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoritesStateImplCopyWith<_$FavoritesStateImpl> get copyWith =>
      __$$FavoritesStateImplCopyWithImpl<_$FavoritesStateImpl>(
          this, _$identity);
}

abstract class _FavoritesState implements FavoritesState {
  const factory _FavoritesState(
      {final List<Restaurant> restaurants,
      final bool isLoading,
      final String? error}) = _$FavoritesStateImpl;

  @override
  List<Restaurant> get restaurants;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of FavoritesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoritesStateImplCopyWith<_$FavoritesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
