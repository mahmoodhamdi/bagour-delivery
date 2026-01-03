// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AvailableOrdersState {
  List<AvailableOrder> get orders => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of AvailableOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailableOrdersStateCopyWith<AvailableOrdersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailableOrdersStateCopyWith<$Res> {
  factory $AvailableOrdersStateCopyWith(AvailableOrdersState value,
          $Res Function(AvailableOrdersState) then) =
      _$AvailableOrdersStateCopyWithImpl<$Res, AvailableOrdersState>;
  @useResult
  $Res call(
      {List<AvailableOrder> orders,
      bool isLoading,
      bool isRefreshing,
      String? error});
}

/// @nodoc
class _$AvailableOrdersStateCopyWithImpl<$Res,
        $Val extends AvailableOrdersState>
    implements $AvailableOrdersStateCopyWith<$Res> {
  _$AvailableOrdersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailableOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<AvailableOrder>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AvailableOrdersStateImplCopyWith<$Res>
    implements $AvailableOrdersStateCopyWith<$Res> {
  factory _$$AvailableOrdersStateImplCopyWith(_$AvailableOrdersStateImpl value,
          $Res Function(_$AvailableOrdersStateImpl) then) =
      __$$AvailableOrdersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AvailableOrder> orders,
      bool isLoading,
      bool isRefreshing,
      String? error});
}

/// @nodoc
class __$$AvailableOrdersStateImplCopyWithImpl<$Res>
    extends _$AvailableOrdersStateCopyWithImpl<$Res, _$AvailableOrdersStateImpl>
    implements _$$AvailableOrdersStateImplCopyWith<$Res> {
  __$$AvailableOrdersStateImplCopyWithImpl(_$AvailableOrdersStateImpl _value,
      $Res Function(_$AvailableOrdersStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AvailableOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
  }) {
    return _then(_$AvailableOrdersStateImpl(
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<AvailableOrder>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AvailableOrdersStateImpl implements _AvailableOrdersState {
  const _$AvailableOrdersStateImpl(
      {final List<AvailableOrder> orders = const [],
      this.isLoading = false,
      this.isRefreshing = false,
      this.error})
      : _orders = orders;

  final List<AvailableOrder> _orders;
  @override
  @JsonKey()
  List<AvailableOrder> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final String? error;

  @override
  String toString() {
    return 'AvailableOrdersState(orders: $orders, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableOrdersStateImpl &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_orders),
      isLoading,
      isRefreshing,
      error);

  /// Create a copy of AvailableOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableOrdersStateImplCopyWith<_$AvailableOrdersStateImpl>
      get copyWith =>
          __$$AvailableOrdersStateImplCopyWithImpl<_$AvailableOrdersStateImpl>(
              this, _$identity);
}

abstract class _AvailableOrdersState implements AvailableOrdersState {
  const factory _AvailableOrdersState(
      {final List<AvailableOrder> orders,
      final bool isLoading,
      final bool isRefreshing,
      final String? error}) = _$AvailableOrdersStateImpl;

  @override
  List<AvailableOrder> get orders;
  @override
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override
  String? get error;

  /// Create a copy of AvailableOrdersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailableOrdersStateImplCopyWith<_$AvailableOrdersStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CurrentOrderState {
  DriverOrder? get order => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isUpdating => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentOrderStateCopyWith<CurrentOrderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentOrderStateCopyWith<$Res> {
  factory $CurrentOrderStateCopyWith(
          CurrentOrderState value, $Res Function(CurrentOrderState) then) =
      _$CurrentOrderStateCopyWithImpl<$Res, CurrentOrderState>;
  @useResult
  $Res call(
      {DriverOrder? order, bool isLoading, bool isUpdating, String? error});

  $DriverOrderCopyWith<$Res>? get order;
}

/// @nodoc
class _$CurrentOrderStateCopyWithImpl<$Res, $Val extends CurrentOrderState>
    implements $CurrentOrderStateCopyWith<$Res> {
  _$CurrentOrderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = freezed,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as DriverOrder?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverOrderCopyWith<$Res>? get order {
    if (_value.order == null) {
      return null;
    }

    return $DriverOrderCopyWith<$Res>(_value.order!, (value) {
      return _then(_value.copyWith(order: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CurrentOrderStateImplCopyWith<$Res>
    implements $CurrentOrderStateCopyWith<$Res> {
  factory _$$CurrentOrderStateImplCopyWith(_$CurrentOrderStateImpl value,
          $Res Function(_$CurrentOrderStateImpl) then) =
      __$$CurrentOrderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DriverOrder? order, bool isLoading, bool isUpdating, String? error});

  @override
  $DriverOrderCopyWith<$Res>? get order;
}

/// @nodoc
class __$$CurrentOrderStateImplCopyWithImpl<$Res>
    extends _$CurrentOrderStateCopyWithImpl<$Res, _$CurrentOrderStateImpl>
    implements _$$CurrentOrderStateImplCopyWith<$Res> {
  __$$CurrentOrderStateImplCopyWithImpl(_$CurrentOrderStateImpl _value,
      $Res Function(_$CurrentOrderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = freezed,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
  }) {
    return _then(_$CurrentOrderStateImpl(
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as DriverOrder?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CurrentOrderStateImpl implements _CurrentOrderState {
  const _$CurrentOrderStateImpl(
      {this.order,
      this.isLoading = false,
      this.isUpdating = false,
      this.error});

  @override
  final DriverOrder? order;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  final String? error;

  @override
  String toString() {
    return 'CurrentOrderState(order: $order, isLoading: $isLoading, isUpdating: $isUpdating, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentOrderStateImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, order, isLoading, isUpdating, error);

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentOrderStateImplCopyWith<_$CurrentOrderStateImpl> get copyWith =>
      __$$CurrentOrderStateImplCopyWithImpl<_$CurrentOrderStateImpl>(
          this, _$identity);
}

abstract class _CurrentOrderState implements CurrentOrderState {
  const factory _CurrentOrderState(
      {final DriverOrder? order,
      final bool isLoading,
      final bool isUpdating,
      final String? error}) = _$CurrentOrderStateImpl;

  @override
  DriverOrder? get order;
  @override
  bool get isLoading;
  @override
  bool get isUpdating;
  @override
  String? get error;

  /// Create a copy of CurrentOrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentOrderStateImplCopyWith<_$CurrentOrderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DriverStatsState {
  DriverStats get stats => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverStatsStateCopyWith<DriverStatsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverStatsStateCopyWith<$Res> {
  factory $DriverStatsStateCopyWith(
          DriverStatsState value, $Res Function(DriverStatsState) then) =
      _$DriverStatsStateCopyWithImpl<$Res, DriverStatsState>;
  @useResult
  $Res call({DriverStats stats, bool isLoading, String? error});

  $DriverStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$DriverStatsStateCopyWithImpl<$Res, $Val extends DriverStatsState>
    implements $DriverStatsStateCopyWith<$Res> {
  _$DriverStatsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stats = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as DriverStats,
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

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverStatsCopyWith<$Res> get stats {
    return $DriverStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverStatsStateImplCopyWith<$Res>
    implements $DriverStatsStateCopyWith<$Res> {
  factory _$$DriverStatsStateImplCopyWith(_$DriverStatsStateImpl value,
          $Res Function(_$DriverStatsStateImpl) then) =
      __$$DriverStatsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DriverStats stats, bool isLoading, String? error});

  @override
  $DriverStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$DriverStatsStateImplCopyWithImpl<$Res>
    extends _$DriverStatsStateCopyWithImpl<$Res, _$DriverStatsStateImpl>
    implements _$$DriverStatsStateImplCopyWith<$Res> {
  __$$DriverStatsStateImplCopyWithImpl(_$DriverStatsStateImpl _value,
      $Res Function(_$DriverStatsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stats = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$DriverStatsStateImpl(
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as DriverStats,
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

class _$DriverStatsStateImpl implements _DriverStatsState {
  const _$DriverStatsStateImpl(
      {this.stats = const DriverStats(), this.isLoading = false, this.error});

  @override
  @JsonKey()
  final DriverStats stats;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'DriverStatsState(stats: $stats, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverStatsStateImpl &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, stats, isLoading, error);

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverStatsStateImplCopyWith<_$DriverStatsStateImpl> get copyWith =>
      __$$DriverStatsStateImplCopyWithImpl<_$DriverStatsStateImpl>(
          this, _$identity);
}

abstract class _DriverStatsState implements DriverStatsState {
  const factory _DriverStatsState(
      {final DriverStats stats,
      final bool isLoading,
      final String? error}) = _$DriverStatsStateImpl;

  @override
  DriverStats get stats;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of DriverStatsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverStatsStateImplCopyWith<_$DriverStatsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderHistoryState {
  List<DriverOrder> get orders => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of OrderHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderHistoryStateCopyWith<OrderHistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderHistoryStateCopyWith<$Res> {
  factory $OrderHistoryStateCopyWith(
          OrderHistoryState value, $Res Function(OrderHistoryState) then) =
      _$OrderHistoryStateCopyWithImpl<$Res, OrderHistoryState>;
  @useResult
  $Res call(
      {List<DriverOrder> orders,
      bool isLoading,
      bool hasMore,
      int currentPage,
      String? error});
}

/// @nodoc
class _$OrderHistoryStateCopyWithImpl<$Res, $Val extends OrderHistoryState>
    implements $OrderHistoryStateCopyWith<$Res> {
  _$OrderHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? currentPage = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<DriverOrder>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderHistoryStateImplCopyWith<$Res>
    implements $OrderHistoryStateCopyWith<$Res> {
  factory _$$OrderHistoryStateImplCopyWith(_$OrderHistoryStateImpl value,
          $Res Function(_$OrderHistoryStateImpl) then) =
      __$$OrderHistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DriverOrder> orders,
      bool isLoading,
      bool hasMore,
      int currentPage,
      String? error});
}

/// @nodoc
class __$$OrderHistoryStateImplCopyWithImpl<$Res>
    extends _$OrderHistoryStateCopyWithImpl<$Res, _$OrderHistoryStateImpl>
    implements _$$OrderHistoryStateImplCopyWith<$Res> {
  __$$OrderHistoryStateImplCopyWithImpl(_$OrderHistoryStateImpl _value,
      $Res Function(_$OrderHistoryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? currentPage = null,
    Object? error = freezed,
  }) {
    return _then(_$OrderHistoryStateImpl(
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<DriverOrder>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OrderHistoryStateImpl implements _OrderHistoryState {
  const _$OrderHistoryStateImpl(
      {final List<DriverOrder> orders = const [],
      this.isLoading = false,
      this.hasMore = false,
      this.currentPage = 1,
      this.error})
      : _orders = orders;

  final List<DriverOrder> _orders;
  @override
  @JsonKey()
  List<DriverOrder> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int currentPage;
  @override
  final String? error;

  @override
  String toString() {
    return 'OrderHistoryState(orders: $orders, isLoading: $isLoading, hasMore: $hasMore, currentPage: $currentPage, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderHistoryStateImpl &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_orders),
      isLoading,
      hasMore,
      currentPage,
      error);

  /// Create a copy of OrderHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderHistoryStateImplCopyWith<_$OrderHistoryStateImpl> get copyWith =>
      __$$OrderHistoryStateImplCopyWithImpl<_$OrderHistoryStateImpl>(
          this, _$identity);
}

abstract class _OrderHistoryState implements OrderHistoryState {
  const factory _OrderHistoryState(
      {final List<DriverOrder> orders,
      final bool isLoading,
      final bool hasMore,
      final int currentPage,
      final String? error}) = _$OrderHistoryStateImpl;

  @override
  List<DriverOrder> get orders;
  @override
  bool get isLoading;
  @override
  bool get hasMore;
  @override
  int get currentPage;
  @override
  String? get error;

  /// Create a copy of OrderHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderHistoryStateImplCopyWith<_$OrderHistoryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
