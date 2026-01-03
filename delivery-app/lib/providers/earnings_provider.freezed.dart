// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EarningsState {
  EarningsSummary get summary => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarningsStateCopyWith<EarningsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningsStateCopyWith<$Res> {
  factory $EarningsStateCopyWith(
          EarningsState value, $Res Function(EarningsState) then) =
      _$EarningsStateCopyWithImpl<$Res, EarningsState>;
  @useResult
  $Res call({EarningsSummary summary, bool isLoading, String? error});

  $EarningsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$EarningsStateCopyWithImpl<$Res, $Val extends EarningsState>
    implements $EarningsStateCopyWith<$Res> {
  _$EarningsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as EarningsSummary,
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

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EarningsSummaryCopyWith<$Res> get summary {
    return $EarningsSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EarningsStateImplCopyWith<$Res>
    implements $EarningsStateCopyWith<$Res> {
  factory _$$EarningsStateImplCopyWith(
          _$EarningsStateImpl value, $Res Function(_$EarningsStateImpl) then) =
      __$$EarningsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EarningsSummary summary, bool isLoading, String? error});

  @override
  $EarningsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$EarningsStateImplCopyWithImpl<$Res>
    extends _$EarningsStateCopyWithImpl<$Res, _$EarningsStateImpl>
    implements _$$EarningsStateImplCopyWith<$Res> {
  __$$EarningsStateImplCopyWithImpl(
      _$EarningsStateImpl _value, $Res Function(_$EarningsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$EarningsStateImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as EarningsSummary,
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

class _$EarningsStateImpl implements _EarningsState {
  const _$EarningsStateImpl(
      {this.summary = const EarningsSummary(
          todayEarnings: 0,
          weekEarnings: 0,
          monthEarnings: 0,
          totalEarnings: 0,
          todayDeliveries: 0,
          weekDeliveries: 0,
          monthDeliveries: 0,
          totalDeliveries: 0,
          averageRating: 0,
          totalRatings: 0),
      this.isLoading = false,
      this.error});

  @override
  @JsonKey()
  final EarningsSummary summary;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'EarningsState(summary: $summary, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningsStateImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, summary, isLoading, error);

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningsStateImplCopyWith<_$EarningsStateImpl> get copyWith =>
      __$$EarningsStateImplCopyWithImpl<_$EarningsStateImpl>(this, _$identity);
}

abstract class _EarningsState implements EarningsState {
  const factory _EarningsState(
      {final EarningsSummary summary,
      final bool isLoading,
      final String? error}) = _$EarningsStateImpl;

  @override
  EarningsSummary get summary;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of EarningsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarningsStateImplCopyWith<_$EarningsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WithdrawalRequest {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get bankName => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawalRequestCopyWith<WithdrawalRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawalRequestCopyWith<$Res> {
  factory $WithdrawalRequestCopyWith(
          WithdrawalRequest value, $Res Function(WithdrawalRequest) then) =
      _$WithdrawalRequestCopyWithImpl<$Res, WithdrawalRequest>;
  @useResult
  $Res call(
      {String id,
      double amount,
      String status,
      String bankName,
      String accountNumber,
      DateTime createdAt,
      DateTime? processedAt,
      String? notes});
}

/// @nodoc
class _$WithdrawalRequestCopyWithImpl<$Res, $Val extends WithdrawalRequest>
    implements $WithdrawalRequestCopyWith<$Res> {
  _$WithdrawalRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? bankName = null,
    Object? accountNumber = null,
    Object? createdAt = null,
    Object? processedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawalRequestImplCopyWith<$Res>
    implements $WithdrawalRequestCopyWith<$Res> {
  factory _$$WithdrawalRequestImplCopyWith(_$WithdrawalRequestImpl value,
          $Res Function(_$WithdrawalRequestImpl) then) =
      __$$WithdrawalRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      String status,
      String bankName,
      String accountNumber,
      DateTime createdAt,
      DateTime? processedAt,
      String? notes});
}

/// @nodoc
class __$$WithdrawalRequestImplCopyWithImpl<$Res>
    extends _$WithdrawalRequestCopyWithImpl<$Res, _$WithdrawalRequestImpl>
    implements _$$WithdrawalRequestImplCopyWith<$Res> {
  __$$WithdrawalRequestImplCopyWithImpl(_$WithdrawalRequestImpl _value,
      $Res Function(_$WithdrawalRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? bankName = null,
    Object? accountNumber = null,
    Object? createdAt = null,
    Object? processedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$WithdrawalRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WithdrawalRequestImpl implements _WithdrawalRequest {
  const _$WithdrawalRequestImpl(
      {required this.id,
      required this.amount,
      required this.status,
      required this.bankName,
      required this.accountNumber,
      required this.createdAt,
      this.processedAt,
      this.notes});

  @override
  final String id;
  @override
  final double amount;
  @override
  final String status;
  @override
  final String bankName;
  @override
  final String accountNumber;
  @override
  final DateTime createdAt;
  @override
  final DateTime? processedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'WithdrawalRequest(id: $id, amount: $amount, status: $status, bankName: $bankName, accountNumber: $accountNumber, createdAt: $createdAt, processedAt: $processedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawalRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, amount, status, bankName,
      accountNumber, createdAt, processedAt, notes);

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawalRequestImplCopyWith<_$WithdrawalRequestImpl> get copyWith =>
      __$$WithdrawalRequestImplCopyWithImpl<_$WithdrawalRequestImpl>(
          this, _$identity);
}

abstract class _WithdrawalRequest implements WithdrawalRequest {
  const factory _WithdrawalRequest(
      {required final String id,
      required final double amount,
      required final String status,
      required final String bankName,
      required final String accountNumber,
      required final DateTime createdAt,
      final DateTime? processedAt,
      final String? notes}) = _$WithdrawalRequestImpl;

  @override
  String get id;
  @override
  double get amount;
  @override
  String get status;
  @override
  String get bankName;
  @override
  String get accountNumber;
  @override
  DateTime get createdAt;
  @override
  DateTime? get processedAt;
  @override
  String? get notes;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawalRequestImplCopyWith<_$WithdrawalRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WithdrawalsState {
  List<WithdrawalRequest> get requests => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawalsStateCopyWith<WithdrawalsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawalsStateCopyWith<$Res> {
  factory $WithdrawalsStateCopyWith(
          WithdrawalsState value, $Res Function(WithdrawalsState) then) =
      _$WithdrawalsStateCopyWithImpl<$Res, WithdrawalsState>;
  @useResult
  $Res call(
      {List<WithdrawalRequest> requests,
      bool isLoading,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class _$WithdrawalsStateCopyWithImpl<$Res, $Val extends WithdrawalsState>
    implements $WithdrawalsStateCopyWith<$Res> {
  _$WithdrawalsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawalsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      requests: null == requests
          ? _value.requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<WithdrawalRequest>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawalsStateImplCopyWith<$Res>
    implements $WithdrawalsStateCopyWith<$Res> {
  factory _$$WithdrawalsStateImplCopyWith(_$WithdrawalsStateImpl value,
          $Res Function(_$WithdrawalsStateImpl) then) =
      __$$WithdrawalsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WithdrawalRequest> requests,
      bool isLoading,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class __$$WithdrawalsStateImplCopyWithImpl<$Res>
    extends _$WithdrawalsStateCopyWithImpl<$Res, _$WithdrawalsStateImpl>
    implements _$$WithdrawalsStateImplCopyWith<$Res> {
  __$$WithdrawalsStateImplCopyWithImpl(_$WithdrawalsStateImpl _value,
      $Res Function(_$WithdrawalsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawalsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? isLoading = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_$WithdrawalsStateImpl(
      requests: null == requests
          ? _value._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<WithdrawalRequest>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WithdrawalsStateImpl implements _WithdrawalsState {
  const _$WithdrawalsStateImpl(
      {final List<WithdrawalRequest> requests = const [],
      this.isLoading = false,
      this.isSubmitting = false,
      this.error})
      : _requests = requests;

  final List<WithdrawalRequest> _requests;
  @override
  @JsonKey()
  List<WithdrawalRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  @override
  String toString() {
    return 'WithdrawalsState(requests: $requests, isLoading: $isLoading, isSubmitting: $isSubmitting, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawalsStateImpl &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_requests),
      isLoading,
      isSubmitting,
      error);

  /// Create a copy of WithdrawalsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawalsStateImplCopyWith<_$WithdrawalsStateImpl> get copyWith =>
      __$$WithdrawalsStateImplCopyWithImpl<_$WithdrawalsStateImpl>(
          this, _$identity);
}

abstract class _WithdrawalsState implements WithdrawalsState {
  const factory _WithdrawalsState(
      {final List<WithdrawalRequest> requests,
      final bool isLoading,
      final bool isSubmitting,
      final String? error}) = _$WithdrawalsStateImpl;

  @override
  List<WithdrawalRequest> get requests;
  @override
  bool get isLoading;
  @override
  bool get isSubmitting;
  @override
  String? get error;

  /// Create a copy of WithdrawalsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawalsStateImplCopyWith<_$WithdrawalsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
