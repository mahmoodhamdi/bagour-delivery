// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) {
  return _DriverProfile.fromJson(json);
}

/// @nodoc
mixin _$DriverProfile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get nationalId => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  String? get vehicleColor => throw _privateConstructorUsedError;
  String get licenseNumber => throw _privateConstructorUsedError;
  DateTime get licenseExpiryDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get totalDeliveries => throw _privateConstructorUsedError;
  double get currentBalance => throw _privateConstructorUsedError;

  /// Serializes this DriverProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverProfileCopyWith<DriverProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverProfileCopyWith<$Res> {
  factory $DriverProfileCopyWith(
          DriverProfile value, $Res Function(DriverProfile) then) =
      _$DriverProfileCopyWithImpl<$Res, DriverProfile>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String nationalId,
      String vehicleType,
      String? vehiclePlate,
      String? vehicleModel,
      String? vehicleColor,
      String licenseNumber,
      DateTime licenseExpiryDate,
      String status,
      bool isOnline,
      bool isAvailable,
      double rating,
      int totalDeliveries,
      double currentBalance});
}

/// @nodoc
class _$DriverProfileCopyWithImpl<$Res, $Val extends DriverProfile>
    implements $DriverProfileCopyWith<$Res> {
  _$DriverProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nationalId = null,
    Object? vehicleType = null,
    Object? vehiclePlate = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleColor = freezed,
    Object? licenseNumber = null,
    Object? licenseExpiryDate = null,
    Object? status = null,
    Object? isOnline = null,
    Object? isAvailable = null,
    Object? rating = null,
    Object? totalDeliveries = null,
    Object? currentBalance = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleColor: freezed == vehicleColor
          ? _value.vehicleColor
          : vehicleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseExpiryDate: null == licenseExpiryDate
          ? _value.licenseExpiryDate
          : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      currentBalance: null == currentBalance
          ? _value.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverProfileImplCopyWith<$Res>
    implements $DriverProfileCopyWith<$Res> {
  factory _$$DriverProfileImplCopyWith(
          _$DriverProfileImpl value, $Res Function(_$DriverProfileImpl) then) =
      __$$DriverProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String nationalId,
      String vehicleType,
      String? vehiclePlate,
      String? vehicleModel,
      String? vehicleColor,
      String licenseNumber,
      DateTime licenseExpiryDate,
      String status,
      bool isOnline,
      bool isAvailable,
      double rating,
      int totalDeliveries,
      double currentBalance});
}

/// @nodoc
class __$$DriverProfileImplCopyWithImpl<$Res>
    extends _$DriverProfileCopyWithImpl<$Res, _$DriverProfileImpl>
    implements _$$DriverProfileImplCopyWith<$Res> {
  __$$DriverProfileImplCopyWithImpl(
      _$DriverProfileImpl _value, $Res Function(_$DriverProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nationalId = null,
    Object? vehicleType = null,
    Object? vehiclePlate = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleColor = freezed,
    Object? licenseNumber = null,
    Object? licenseExpiryDate = null,
    Object? status = null,
    Object? isOnline = null,
    Object? isAvailable = null,
    Object? rating = null,
    Object? totalDeliveries = null,
    Object? currentBalance = null,
  }) {
    return _then(_$DriverProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      vehiclePlate: freezed == vehiclePlate
          ? _value.vehiclePlate
          : vehiclePlate // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleColor: freezed == vehicleColor
          ? _value.vehicleColor
          : vehicleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseExpiryDate: null == licenseExpiryDate
          ? _value.licenseExpiryDate
          : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      currentBalance: null == currentBalance
          ? _value.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverProfileImpl implements _DriverProfile {
  const _$DriverProfileImpl(
      {required this.id,
      required this.userId,
      required this.nationalId,
      required this.vehicleType,
      this.vehiclePlate,
      this.vehicleModel,
      this.vehicleColor,
      required this.licenseNumber,
      required this.licenseExpiryDate,
      this.status = 'pending',
      this.isOnline = false,
      this.isAvailable = false,
      this.rating = 0.0,
      this.totalDeliveries = 0,
      this.currentBalance = 0.0});

  factory _$DriverProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String nationalId;
  @override
  final String vehicleType;
  @override
  final String? vehiclePlate;
  @override
  final String? vehicleModel;
  @override
  final String? vehicleColor;
  @override
  final String licenseNumber;
  @override
  final DateTime licenseExpiryDate;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int totalDeliveries;
  @override
  @JsonKey()
  final double currentBalance;

  @override
  String toString() {
    return 'DriverProfile(id: $id, userId: $userId, nationalId: $nationalId, vehicleType: $vehicleType, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, vehicleColor: $vehicleColor, licenseNumber: $licenseNumber, licenseExpiryDate: $licenseExpiryDate, status: $status, isOnline: $isOnline, isAvailable: $isAvailable, rating: $rating, totalDeliveries: $totalDeliveries, currentBalance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nationalId, nationalId) ||
                other.nationalId == nationalId) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.vehiclePlate, vehiclePlate) ||
                other.vehiclePlate == vehiclePlate) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.vehicleColor, vehicleColor) ||
                other.vehicleColor == vehicleColor) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licenseExpiryDate, licenseExpiryDate) ||
                other.licenseExpiryDate == licenseExpiryDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      nationalId,
      vehicleType,
      vehiclePlate,
      vehicleModel,
      vehicleColor,
      licenseNumber,
      licenseExpiryDate,
      status,
      isOnline,
      isAvailable,
      rating,
      totalDeliveries,
      currentBalance);

  /// Create a copy of DriverProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverProfileImplCopyWith<_$DriverProfileImpl> get copyWith =>
      __$$DriverProfileImplCopyWithImpl<_$DriverProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverProfileImplToJson(
      this,
    );
  }
}

abstract class _DriverProfile implements DriverProfile {
  const factory _DriverProfile(
      {required final String id,
      required final String userId,
      required final String nationalId,
      required final String vehicleType,
      final String? vehiclePlate,
      final String? vehicleModel,
      final String? vehicleColor,
      required final String licenseNumber,
      required final DateTime licenseExpiryDate,
      final String status,
      final bool isOnline,
      final bool isAvailable,
      final double rating,
      final int totalDeliveries,
      final double currentBalance}) = _$DriverProfileImpl;

  factory _DriverProfile.fromJson(Map<String, dynamic> json) =
      _$DriverProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get nationalId;
  @override
  String get vehicleType;
  @override
  String? get vehiclePlate;
  @override
  String? get vehicleModel;
  @override
  String? get vehicleColor;
  @override
  String get licenseNumber;
  @override
  DateTime get licenseExpiryDate;
  @override
  String get status;
  @override
  bool get isOnline;
  @override
  bool get isAvailable;
  @override
  double get rating;
  @override
  int get totalDeliveries;
  @override
  double get currentBalance;

  /// Create a copy of DriverProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverProfileImplCopyWith<_$DriverProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  User get user => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  DriverProfile? get driver => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
          AuthResponse value, $Res Function(AuthResponse) then) =
      _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call(
      {User user,
      String accessToken,
      String refreshToken,
      DriverProfile? driver});

  $UserCopyWith<$Res> get user;
  $DriverProfileCopyWith<$Res>? get driver;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? driver = freezed,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as DriverProfile?,
    ) as $Val);
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverProfileCopyWith<$Res>? get driver {
    if (_value.driver == null) {
      return null;
    }

    return $DriverProfileCopyWith<$Res>(_value.driver!, (value) {
      return _then(_value.copyWith(driver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
          _$AuthResponseImpl value, $Res Function(_$AuthResponseImpl) then) =
      __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User user,
      String accessToken,
      String refreshToken,
      DriverProfile? driver});

  @override
  $UserCopyWith<$Res> get user;
  @override
  $DriverProfileCopyWith<$Res>? get driver;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
      _$AuthResponseImpl _value, $Res Function(_$AuthResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? driver = freezed,
  }) {
    return _then(_$AuthResponseImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as DriverProfile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl(
      {required this.user,
      required this.accessToken,
      required this.refreshToken,
      this.driver});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final User user;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DriverProfile? driver;

  @override
  String toString() {
    return 'AuthResponse(user: $user, accessToken: $accessToken, refreshToken: $refreshToken, driver: $driver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.driver, driver) || other.driver == driver));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user, accessToken, refreshToken, driver);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse(
      {required final User user,
      required final String accessToken,
      required final String refreshToken,
      final DriverProfile? driver}) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  User get user;
  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  DriverProfile? get driver;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) {
  return _TokenPair.fromJson(json);
}

/// @nodoc
mixin _$TokenPair {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this TokenPair to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenPairCopyWith<TokenPair> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenPairCopyWith<$Res> {
  factory $TokenPairCopyWith(TokenPair value, $Res Function(TokenPair) then) =
      _$TokenPairCopyWithImpl<$Res, TokenPair>;
  @useResult
  $Res call({String accessToken, String refreshToken});
}

/// @nodoc
class _$TokenPairCopyWithImpl<$Res, $Val extends TokenPair>
    implements $TokenPairCopyWith<$Res> {
  _$TokenPairCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenPairImplCopyWith<$Res>
    implements $TokenPairCopyWith<$Res> {
  factory _$$TokenPairImplCopyWith(
          _$TokenPairImpl value, $Res Function(_$TokenPairImpl) then) =
      __$$TokenPairImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String refreshToken});
}

/// @nodoc
class __$$TokenPairImplCopyWithImpl<$Res>
    extends _$TokenPairCopyWithImpl<$Res, _$TokenPairImpl>
    implements _$$TokenPairImplCopyWith<$Res> {
  __$$TokenPairImplCopyWithImpl(
      _$TokenPairImpl _value, $Res Function(_$TokenPairImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(_$TokenPairImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenPairImpl implements _TokenPair {
  const _$TokenPairImpl(
      {required this.accessToken, required this.refreshToken});

  factory _$TokenPairImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenPairImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;

  @override
  String toString() {
    return 'TokenPair(accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenPairImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken);

  /// Create a copy of TokenPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenPairImplCopyWith<_$TokenPairImpl> get copyWith =>
      __$$TokenPairImplCopyWithImpl<_$TokenPairImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenPairImplToJson(
      this,
    );
  }
}

abstract class _TokenPair implements TokenPair {
  const factory _TokenPair(
      {required final String accessToken,
      required final String refreshToken}) = _$TokenPairImpl;

  factory _TokenPair.fromJson(Map<String, dynamic> json) =
      _$TokenPairImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;

  /// Create a copy of TokenPair
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenPairImplCopyWith<_$TokenPairImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverRegisterRequest _$DriverRegisterRequestFromJson(
    Map<String, dynamic> json) {
  return _DriverRegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$DriverRegisterRequest {
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get nationalId => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  String? get vehicleColor => throw _privateConstructorUsedError;
  String get vehiclePlateNumber => throw _privateConstructorUsedError;
  String get licenseNumber => throw _privateConstructorUsedError;
  DateTime get licenseExpiryDate => throw _privateConstructorUsedError;

  /// Serializes this DriverRegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverRegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverRegisterRequestCopyWith<DriverRegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverRegisterRequestCopyWith<$Res> {
  factory $DriverRegisterRequestCopyWith(DriverRegisterRequest value,
          $Res Function(DriverRegisterRequest) then) =
      _$DriverRegisterRequestCopyWithImpl<$Res, DriverRegisterRequest>;
  @useResult
  $Res call(
      {String name,
      String email,
      String phone,
      String password,
      String nationalId,
      String vehicleType,
      String? vehicleModel,
      String? vehicleColor,
      String vehiclePlateNumber,
      String licenseNumber,
      DateTime licenseExpiryDate});
}

/// @nodoc
class _$DriverRegisterRequestCopyWithImpl<$Res,
        $Val extends DriverRegisterRequest>
    implements $DriverRegisterRequestCopyWith<$Res> {
  _$DriverRegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverRegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? password = null,
    Object? nationalId = null,
    Object? vehicleType = null,
    Object? vehicleModel = freezed,
    Object? vehicleColor = freezed,
    Object? vehiclePlateNumber = null,
    Object? licenseNumber = null,
    Object? licenseExpiryDate = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleColor: freezed == vehicleColor
          ? _value.vehicleColor
          : vehicleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      vehiclePlateNumber: null == vehiclePlateNumber
          ? _value.vehiclePlateNumber
          : vehiclePlateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseExpiryDate: null == licenseExpiryDate
          ? _value.licenseExpiryDate
          : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverRegisterRequestImplCopyWith<$Res>
    implements $DriverRegisterRequestCopyWith<$Res> {
  factory _$$DriverRegisterRequestImplCopyWith(
          _$DriverRegisterRequestImpl value,
          $Res Function(_$DriverRegisterRequestImpl) then) =
      __$$DriverRegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String email,
      String phone,
      String password,
      String nationalId,
      String vehicleType,
      String? vehicleModel,
      String? vehicleColor,
      String vehiclePlateNumber,
      String licenseNumber,
      DateTime licenseExpiryDate});
}

/// @nodoc
class __$$DriverRegisterRequestImplCopyWithImpl<$Res>
    extends _$DriverRegisterRequestCopyWithImpl<$Res,
        _$DriverRegisterRequestImpl>
    implements _$$DriverRegisterRequestImplCopyWith<$Res> {
  __$$DriverRegisterRequestImplCopyWithImpl(_$DriverRegisterRequestImpl _value,
      $Res Function(_$DriverRegisterRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverRegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? password = null,
    Object? nationalId = null,
    Object? vehicleType = null,
    Object? vehicleModel = freezed,
    Object? vehicleColor = freezed,
    Object? vehiclePlateNumber = null,
    Object? licenseNumber = null,
    Object? licenseExpiryDate = null,
  }) {
    return _then(_$DriverRegisterRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      nationalId: null == nationalId
          ? _value.nationalId
          : nationalId // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleModel: freezed == vehicleModel
          ? _value.vehicleModel
          : vehicleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleColor: freezed == vehicleColor
          ? _value.vehicleColor
          : vehicleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      vehiclePlateNumber: null == vehiclePlateNumber
          ? _value.vehiclePlateNumber
          : vehiclePlateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licenseExpiryDate: null == licenseExpiryDate
          ? _value.licenseExpiryDate
          : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverRegisterRequestImpl implements _DriverRegisterRequest {
  const _$DriverRegisterRequestImpl(
      {required this.name,
      required this.email,
      required this.phone,
      required this.password,
      required this.nationalId,
      required this.vehicleType,
      this.vehicleModel,
      this.vehicleColor,
      required this.vehiclePlateNumber,
      required this.licenseNumber,
      required this.licenseExpiryDate});

  factory _$DriverRegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverRegisterRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String email;
  @override
  final String phone;
  @override
  final String password;
  @override
  final String nationalId;
  @override
  final String vehicleType;
  @override
  final String? vehicleModel;
  @override
  final String? vehicleColor;
  @override
  final String vehiclePlateNumber;
  @override
  final String licenseNumber;
  @override
  final DateTime licenseExpiryDate;

  @override
  String toString() {
    return 'DriverRegisterRequest(name: $name, email: $email, phone: $phone, password: $password, nationalId: $nationalId, vehicleType: $vehicleType, vehicleModel: $vehicleModel, vehicleColor: $vehicleColor, vehiclePlateNumber: $vehiclePlateNumber, licenseNumber: $licenseNumber, licenseExpiryDate: $licenseExpiryDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverRegisterRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.nationalId, nationalId) ||
                other.nationalId == nationalId) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.vehicleColor, vehicleColor) ||
                other.vehicleColor == vehicleColor) &&
            (identical(other.vehiclePlateNumber, vehiclePlateNumber) ||
                other.vehiclePlateNumber == vehiclePlateNumber) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licenseExpiryDate, licenseExpiryDate) ||
                other.licenseExpiryDate == licenseExpiryDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      email,
      phone,
      password,
      nationalId,
      vehicleType,
      vehicleModel,
      vehicleColor,
      vehiclePlateNumber,
      licenseNumber,
      licenseExpiryDate);

  /// Create a copy of DriverRegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverRegisterRequestImplCopyWith<_$DriverRegisterRequestImpl>
      get copyWith => __$$DriverRegisterRequestImplCopyWithImpl<
          _$DriverRegisterRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverRegisterRequestImplToJson(
      this,
    );
  }
}

abstract class _DriverRegisterRequest implements DriverRegisterRequest {
  const factory _DriverRegisterRequest(
      {required final String name,
      required final String email,
      required final String phone,
      required final String password,
      required final String nationalId,
      required final String vehicleType,
      final String? vehicleModel,
      final String? vehicleColor,
      required final String vehiclePlateNumber,
      required final String licenseNumber,
      required final DateTime licenseExpiryDate}) = _$DriverRegisterRequestImpl;

  factory _DriverRegisterRequest.fromJson(Map<String, dynamic> json) =
      _$DriverRegisterRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get email;
  @override
  String get phone;
  @override
  String get password;
  @override
  String get nationalId;
  @override
  String get vehicleType;
  @override
  String? get vehicleModel;
  @override
  String? get vehicleColor;
  @override
  String get vehiclePlateNumber;
  @override
  String get licenseNumber;
  @override
  DateTime get licenseExpiryDate;

  /// Create a copy of DriverRegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverRegisterRequestImplCopyWith<_$DriverRegisterRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
          LoginRequest value, $Res Function(LoginRequest) then) =
      _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
          _$LoginRequestImpl value, $Res Function(_$LoginRequestImpl) then) =
      __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
      _$LoginRequestImpl _value, $Res Function(_$LoginRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl({required this.email, required this.password});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest(
      {required final String email,
      required final String password}) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) {
  return _VerifyOtpRequest.fromJson(json);
}

/// @nodoc
mixin _$VerifyOtpRequest {
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this VerifyOtpRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyOtpRequestCopyWith<VerifyOtpRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyOtpRequestCopyWith<$Res> {
  factory $VerifyOtpRequestCopyWith(
          VerifyOtpRequest value, $Res Function(VerifyOtpRequest) then) =
      _$VerifyOtpRequestCopyWithImpl<$Res, VerifyOtpRequest>;
  @useResult
  $Res call({String? phone, String? email, String otp, String type});
}

/// @nodoc
class _$VerifyOtpRequestCopyWithImpl<$Res, $Val extends VerifyOtpRequest>
    implements $VerifyOtpRequestCopyWith<$Res> {
  _$VerifyOtpRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = freezed,
    Object? email = freezed,
    Object? otp = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerifyOtpRequestImplCopyWith<$Res>
    implements $VerifyOtpRequestCopyWith<$Res> {
  factory _$$VerifyOtpRequestImplCopyWith(_$VerifyOtpRequestImpl value,
          $Res Function(_$VerifyOtpRequestImpl) then) =
      __$$VerifyOtpRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? phone, String? email, String otp, String type});
}

/// @nodoc
class __$$VerifyOtpRequestImplCopyWithImpl<$Res>
    extends _$VerifyOtpRequestCopyWithImpl<$Res, _$VerifyOtpRequestImpl>
    implements _$$VerifyOtpRequestImplCopyWith<$Res> {
  __$$VerifyOtpRequestImplCopyWithImpl(_$VerifyOtpRequestImpl _value,
      $Res Function(_$VerifyOtpRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerifyOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = freezed,
    Object? email = freezed,
    Object? otp = null,
    Object? type = null,
  }) {
    return _then(_$VerifyOtpRequestImpl(
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyOtpRequestImpl implements _VerifyOtpRequest {
  const _$VerifyOtpRequestImpl(
      {this.phone, this.email, required this.otp, required this.type});

  factory _$VerifyOtpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyOtpRequestImplFromJson(json);

  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String otp;
  @override
  final String type;

  @override
  String toString() {
    return 'VerifyOtpRequest(phone: $phone, email: $email, otp: $otp, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyOtpRequestImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phone, email, otp, type);

  /// Create a copy of VerifyOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyOtpRequestImplCopyWith<_$VerifyOtpRequestImpl> get copyWith =>
      __$$VerifyOtpRequestImplCopyWithImpl<_$VerifyOtpRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyOtpRequestImplToJson(
      this,
    );
  }
}

abstract class _VerifyOtpRequest implements VerifyOtpRequest {
  const factory _VerifyOtpRequest(
      {final String? phone,
      final String? email,
      required final String otp,
      required final String type}) = _$VerifyOtpRequestImpl;

  factory _VerifyOtpRequest.fromJson(Map<String, dynamic> json) =
      _$VerifyOtpRequestImpl.fromJson;

  @override
  String? get phone;
  @override
  String? get email;
  @override
  String get otp;
  @override
  String get type;

  /// Create a copy of VerifyOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyOtpRequestImplCopyWith<_$VerifyOtpRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResendOtpRequest _$ResendOtpRequestFromJson(Map<String, dynamic> json) {
  return _ResendOtpRequest.fromJson(json);
}

/// @nodoc
mixin _$ResendOtpRequest {
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this ResendOtpRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResendOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResendOtpRequestCopyWith<ResendOtpRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResendOtpRequestCopyWith<$Res> {
  factory $ResendOtpRequestCopyWith(
          ResendOtpRequest value, $Res Function(ResendOtpRequest) then) =
      _$ResendOtpRequestCopyWithImpl<$Res, ResendOtpRequest>;
  @useResult
  $Res call({String? phone, String? email, String type});
}

/// @nodoc
class _$ResendOtpRequestCopyWithImpl<$Res, $Val extends ResendOtpRequest>
    implements $ResendOtpRequestCopyWith<$Res> {
  _$ResendOtpRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResendOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = freezed,
    Object? email = freezed,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResendOtpRequestImplCopyWith<$Res>
    implements $ResendOtpRequestCopyWith<$Res> {
  factory _$$ResendOtpRequestImplCopyWith(_$ResendOtpRequestImpl value,
          $Res Function(_$ResendOtpRequestImpl) then) =
      __$$ResendOtpRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? phone, String? email, String type});
}

/// @nodoc
class __$$ResendOtpRequestImplCopyWithImpl<$Res>
    extends _$ResendOtpRequestCopyWithImpl<$Res, _$ResendOtpRequestImpl>
    implements _$$ResendOtpRequestImplCopyWith<$Res> {
  __$$ResendOtpRequestImplCopyWithImpl(_$ResendOtpRequestImpl _value,
      $Res Function(_$ResendOtpRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResendOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = freezed,
    Object? email = freezed,
    Object? type = null,
  }) {
    return _then(_$ResendOtpRequestImpl(
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResendOtpRequestImpl implements _ResendOtpRequest {
  const _$ResendOtpRequestImpl({this.phone, this.email, required this.type});

  factory _$ResendOtpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResendOtpRequestImplFromJson(json);

  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String type;

  @override
  String toString() {
    return 'ResendOtpRequest(phone: $phone, email: $email, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResendOtpRequestImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phone, email, type);

  /// Create a copy of ResendOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResendOtpRequestImplCopyWith<_$ResendOtpRequestImpl> get copyWith =>
      __$$ResendOtpRequestImplCopyWithImpl<_$ResendOtpRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResendOtpRequestImplToJson(
      this,
    );
  }
}

abstract class _ResendOtpRequest implements ResendOtpRequest {
  const factory _ResendOtpRequest(
      {final String? phone,
      final String? email,
      required final String type}) = _$ResendOtpRequestImpl;

  factory _ResendOtpRequest.fromJson(Map<String, dynamic> json) =
      _$ResendOtpRequestImpl.fromJson;

  @override
  String? get phone;
  @override
  String? get email;
  @override
  String get type;

  /// Create a copy of ResendOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResendOtpRequestImplCopyWith<_$ResendOtpRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
    Map<String, dynamic> json) {
  return _ForgotPasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ForgotPasswordRequest {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this ForgotPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgotPasswordRequestCopyWith<ForgotPasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgotPasswordRequestCopyWith<$Res> {
  factory $ForgotPasswordRequestCopyWith(ForgotPasswordRequest value,
          $Res Function(ForgotPasswordRequest) then) =
      _$ForgotPasswordRequestCopyWithImpl<$Res, ForgotPasswordRequest>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ForgotPasswordRequestCopyWithImpl<$Res,
        $Val extends ForgotPasswordRequest>
    implements $ForgotPasswordRequestCopyWith<$Res> {
  _$ForgotPasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ForgotPasswordRequestImplCopyWith<$Res>
    implements $ForgotPasswordRequestCopyWith<$Res> {
  factory _$$ForgotPasswordRequestImplCopyWith(
          _$ForgotPasswordRequestImpl value,
          $Res Function(_$ForgotPasswordRequestImpl) then) =
      __$$ForgotPasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ForgotPasswordRequestImplCopyWithImpl<$Res>
    extends _$ForgotPasswordRequestCopyWithImpl<$Res,
        _$ForgotPasswordRequestImpl>
    implements _$$ForgotPasswordRequestImplCopyWith<$Res> {
  __$$ForgotPasswordRequestImplCopyWithImpl(_$ForgotPasswordRequestImpl _value,
      $Res Function(_$ForgotPasswordRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$ForgotPasswordRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ForgotPasswordRequestImpl implements _ForgotPasswordRequest {
  const _$ForgotPasswordRequestImpl({required this.email});

  factory _$ForgotPasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForgotPasswordRequestImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'ForgotPasswordRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordRequestImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordRequestImplCopyWith<_$ForgotPasswordRequestImpl>
      get copyWith => __$$ForgotPasswordRequestImplCopyWithImpl<
          _$ForgotPasswordRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ForgotPasswordRequestImplToJson(
      this,
    );
  }
}

abstract class _ForgotPasswordRequest implements ForgotPasswordRequest {
  const factory _ForgotPasswordRequest({required final String email}) =
      _$ForgotPasswordRequestImpl;

  factory _ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ForgotPasswordRequestImpl.fromJson;

  @override
  String get email;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordRequestImplCopyWith<_$ForgotPasswordRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ResetPasswordRequest _$ResetPasswordRequestFromJson(Map<String, dynamic> json) {
  return _ResetPasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ResetPasswordRequest {
  String get email => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;

  /// Serializes this ResetPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResetPasswordRequestCopyWith<ResetPasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetPasswordRequestCopyWith<$Res> {
  factory $ResetPasswordRequestCopyWith(ResetPasswordRequest value,
          $Res Function(ResetPasswordRequest) then) =
      _$ResetPasswordRequestCopyWithImpl<$Res, ResetPasswordRequest>;
  @useResult
  $Res call({String email, String otp, String newPassword});
}

/// @nodoc
class _$ResetPasswordRequestCopyWithImpl<$Res,
        $Val extends ResetPasswordRequest>
    implements $ResetPasswordRequestCopyWith<$Res> {
  _$ResetPasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? otp = null,
    Object? newPassword = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResetPasswordRequestImplCopyWith<$Res>
    implements $ResetPasswordRequestCopyWith<$Res> {
  factory _$$ResetPasswordRequestImplCopyWith(_$ResetPasswordRequestImpl value,
          $Res Function(_$ResetPasswordRequestImpl) then) =
      __$$ResetPasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String otp, String newPassword});
}

/// @nodoc
class __$$ResetPasswordRequestImplCopyWithImpl<$Res>
    extends _$ResetPasswordRequestCopyWithImpl<$Res, _$ResetPasswordRequestImpl>
    implements _$$ResetPasswordRequestImplCopyWith<$Res> {
  __$$ResetPasswordRequestImplCopyWithImpl(_$ResetPasswordRequestImpl _value,
      $Res Function(_$ResetPasswordRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? otp = null,
    Object? newPassword = null,
  }) {
    return _then(_$ResetPasswordRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResetPasswordRequestImpl implements _ResetPasswordRequest {
  const _$ResetPasswordRequestImpl(
      {required this.email, required this.otp, required this.newPassword});

  factory _$ResetPasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResetPasswordRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String otp;
  @override
  final String newPassword;

  @override
  String toString() {
    return 'ResetPasswordRequest(email: $email, otp: $otp, newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, otp, newPassword);

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordRequestImplCopyWith<_$ResetPasswordRequestImpl>
      get copyWith =>
          __$$ResetPasswordRequestImplCopyWithImpl<_$ResetPasswordRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResetPasswordRequestImplToJson(
      this,
    );
  }
}

abstract class _ResetPasswordRequest implements ResetPasswordRequest {
  const factory _ResetPasswordRequest(
      {required final String email,
      required final String otp,
      required final String newPassword}) = _$ResetPasswordRequestImpl;

  factory _ResetPasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ResetPasswordRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get otp;
  @override
  String get newPassword;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordRequestImplCopyWith<_$ResetPasswordRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ChangePasswordRequest _$ChangePasswordRequestFromJson(
    Map<String, dynamic> json) {
  return _ChangePasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ChangePasswordRequest {
  String get currentPassword => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;

  /// Serializes this ChangePasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangePasswordRequestCopyWith<ChangePasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangePasswordRequestCopyWith<$Res> {
  factory $ChangePasswordRequestCopyWith(ChangePasswordRequest value,
          $Res Function(ChangePasswordRequest) then) =
      _$ChangePasswordRequestCopyWithImpl<$Res, ChangePasswordRequest>;
  @useResult
  $Res call({String currentPassword, String newPassword});
}

/// @nodoc
class _$ChangePasswordRequestCopyWithImpl<$Res,
        $Val extends ChangePasswordRequest>
    implements $ChangePasswordRequestCopyWith<$Res> {
  _$ChangePasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
  }) {
    return _then(_value.copyWith(
      currentPassword: null == currentPassword
          ? _value.currentPassword
          : currentPassword // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChangePasswordRequestImplCopyWith<$Res>
    implements $ChangePasswordRequestCopyWith<$Res> {
  factory _$$ChangePasswordRequestImplCopyWith(
          _$ChangePasswordRequestImpl value,
          $Res Function(_$ChangePasswordRequestImpl) then) =
      __$$ChangePasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String currentPassword, String newPassword});
}

/// @nodoc
class __$$ChangePasswordRequestImplCopyWithImpl<$Res>
    extends _$ChangePasswordRequestCopyWithImpl<$Res,
        _$ChangePasswordRequestImpl>
    implements _$$ChangePasswordRequestImplCopyWith<$Res> {
  __$$ChangePasswordRequestImplCopyWithImpl(_$ChangePasswordRequestImpl _value,
      $Res Function(_$ChangePasswordRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
  }) {
    return _then(_$ChangePasswordRequestImpl(
      currentPassword: null == currentPassword
          ? _value.currentPassword
          : currentPassword // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangePasswordRequestImpl implements _ChangePasswordRequest {
  const _$ChangePasswordRequestImpl(
      {required this.currentPassword, required this.newPassword});

  factory _$ChangePasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangePasswordRequestImplFromJson(json);

  @override
  final String currentPassword;
  @override
  final String newPassword;

  @override
  String toString() {
    return 'ChangePasswordRequest(currentPassword: $currentPassword, newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangePasswordRequestImpl &&
            (identical(other.currentPassword, currentPassword) ||
                other.currentPassword == currentPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentPassword, newPassword);

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangePasswordRequestImplCopyWith<_$ChangePasswordRequestImpl>
      get copyWith => __$$ChangePasswordRequestImplCopyWithImpl<
          _$ChangePasswordRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangePasswordRequestImplToJson(
      this,
    );
  }
}

abstract class _ChangePasswordRequest implements ChangePasswordRequest {
  const factory _ChangePasswordRequest(
      {required final String currentPassword,
      required final String newPassword}) = _$ChangePasswordRequestImpl;

  factory _ChangePasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ChangePasswordRequestImpl.fromJson;

  @override
  String get currentPassword;
  @override
  String get newPassword;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangePasswordRequestImplCopyWith<_$ChangePasswordRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) {
  return _RefreshTokenRequest.fromJson(json);
}

/// @nodoc
mixin _$RefreshTokenRequest {
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this RefreshTokenRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefreshTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefreshTokenRequestCopyWith<RefreshTokenRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshTokenRequestCopyWith<$Res> {
  factory $RefreshTokenRequestCopyWith(
          RefreshTokenRequest value, $Res Function(RefreshTokenRequest) then) =
      _$RefreshTokenRequestCopyWithImpl<$Res, RefreshTokenRequest>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$RefreshTokenRequestCopyWithImpl<$Res, $Val extends RefreshTokenRequest>
    implements $RefreshTokenRequestCopyWith<$Res> {
  _$RefreshTokenRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefreshTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(_value.copyWith(
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefreshTokenRequestImplCopyWith<$Res>
    implements $RefreshTokenRequestCopyWith<$Res> {
  factory _$$RefreshTokenRequestImplCopyWith(_$RefreshTokenRequestImpl value,
          $Res Function(_$RefreshTokenRequestImpl) then) =
      __$$RefreshTokenRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$RefreshTokenRequestImplCopyWithImpl<$Res>
    extends _$RefreshTokenRequestCopyWithImpl<$Res, _$RefreshTokenRequestImpl>
    implements _$$RefreshTokenRequestImplCopyWith<$Res> {
  __$$RefreshTokenRequestImplCopyWithImpl(_$RefreshTokenRequestImpl _value,
      $Res Function(_$RefreshTokenRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RefreshTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(_$RefreshTokenRequestImpl(
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefreshTokenRequestImpl implements _RefreshTokenRequest {
  const _$RefreshTokenRequestImpl({required this.refreshToken});

  factory _$RefreshTokenRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefreshTokenRequestImplFromJson(json);

  @override
  final String refreshToken;

  @override
  String toString() {
    return 'RefreshTokenRequest(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshTokenRequestImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of RefreshTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshTokenRequestImplCopyWith<_$RefreshTokenRequestImpl> get copyWith =>
      __$$RefreshTokenRequestImplCopyWithImpl<_$RefreshTokenRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefreshTokenRequestImplToJson(
      this,
    );
  }
}

abstract class _RefreshTokenRequest implements RefreshTokenRequest {
  const factory _RefreshTokenRequest({required final String refreshToken}) =
      _$RefreshTokenRequestImpl;

  factory _RefreshTokenRequest.fromJson(Map<String, dynamic> json) =
      _$RefreshTokenRequestImpl.fromJson;

  @override
  String get refreshToken;

  /// Create a copy of RefreshTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshTokenRequestImplCopyWith<_$RefreshTokenRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateFcmTokenRequest _$UpdateFcmTokenRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateFcmTokenRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateFcmTokenRequest {
  String get fcmToken => throw _privateConstructorUsedError;
  String? get deviceType => throw _privateConstructorUsedError;

  /// Serializes this UpdateFcmTokenRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateFcmTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateFcmTokenRequestCopyWith<UpdateFcmTokenRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateFcmTokenRequestCopyWith<$Res> {
  factory $UpdateFcmTokenRequestCopyWith(UpdateFcmTokenRequest value,
          $Res Function(UpdateFcmTokenRequest) then) =
      _$UpdateFcmTokenRequestCopyWithImpl<$Res, UpdateFcmTokenRequest>;
  @useResult
  $Res call({String fcmToken, String? deviceType});
}

/// @nodoc
class _$UpdateFcmTokenRequestCopyWithImpl<$Res,
        $Val extends UpdateFcmTokenRequest>
    implements $UpdateFcmTokenRequestCopyWith<$Res> {
  _$UpdateFcmTokenRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateFcmTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fcmToken = null,
    Object? deviceType = freezed,
  }) {
    return _then(_value.copyWith(
      fcmToken: null == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateFcmTokenRequestImplCopyWith<$Res>
    implements $UpdateFcmTokenRequestCopyWith<$Res> {
  factory _$$UpdateFcmTokenRequestImplCopyWith(
          _$UpdateFcmTokenRequestImpl value,
          $Res Function(_$UpdateFcmTokenRequestImpl) then) =
      __$$UpdateFcmTokenRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fcmToken, String? deviceType});
}

/// @nodoc
class __$$UpdateFcmTokenRequestImplCopyWithImpl<$Res>
    extends _$UpdateFcmTokenRequestCopyWithImpl<$Res,
        _$UpdateFcmTokenRequestImpl>
    implements _$$UpdateFcmTokenRequestImplCopyWith<$Res> {
  __$$UpdateFcmTokenRequestImplCopyWithImpl(_$UpdateFcmTokenRequestImpl _value,
      $Res Function(_$UpdateFcmTokenRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateFcmTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fcmToken = null,
    Object? deviceType = freezed,
  }) {
    return _then(_$UpdateFcmTokenRequestImpl(
      fcmToken: null == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: freezed == deviceType
          ? _value.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateFcmTokenRequestImpl implements _UpdateFcmTokenRequest {
  const _$UpdateFcmTokenRequestImpl({required this.fcmToken, this.deviceType});

  factory _$UpdateFcmTokenRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateFcmTokenRequestImplFromJson(json);

  @override
  final String fcmToken;
  @override
  final String? deviceType;

  @override
  String toString() {
    return 'UpdateFcmTokenRequest(fcmToken: $fcmToken, deviceType: $deviceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateFcmTokenRequestImpl &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fcmToken, deviceType);

  /// Create a copy of UpdateFcmTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateFcmTokenRequestImplCopyWith<_$UpdateFcmTokenRequestImpl>
      get copyWith => __$$UpdateFcmTokenRequestImplCopyWithImpl<
          _$UpdateFcmTokenRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateFcmTokenRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateFcmTokenRequest implements UpdateFcmTokenRequest {
  const factory _UpdateFcmTokenRequest(
      {required final String fcmToken,
      final String? deviceType}) = _$UpdateFcmTokenRequestImpl;

  factory _UpdateFcmTokenRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateFcmTokenRequestImpl.fromJson;

  @override
  String get fcmToken;
  @override
  String? get deviceType;

  /// Create a copy of UpdateFcmTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateFcmTokenRequestImplCopyWith<_$UpdateFcmTokenRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
