// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  bool get isPhoneVerified => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      UserRole role,
      String? avatar,
      bool isPhoneVerified,
      bool isEmailVerified,
      bool isActive});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? role = null,
    Object? avatar = freezed,
    Object? isPhoneVerified = null,
    Object? isEmailVerified = null,
    Object? isActive = null,
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
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      UserRole role,
      String? avatar,
      bool isPhoneVerified,
      bool isEmailVerified,
      bool isActive});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? role = null,
    Object? avatar = freezed,
    Object? isPhoneVerified = null,
    Object? isEmailVerified = null,
    Object? isActive = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.role,
      this.avatar,
      this.isPhoneVerified = false,
      this.isEmailVerified = false,
      this.isActive = true});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String phone;
  @override
  final UserRole role;
  @override
  final String? avatar;
  @override
  @JsonKey()
  final bool isPhoneVerified;
  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, role: $role, avatar: $avatar, isPhoneVerified: $isPhoneVerified, isEmailVerified: $isEmailVerified, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.isPhoneVerified, isPhoneVerified) ||
                other.isPhoneVerified == isPhoneVerified) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, phone, role,
      avatar, isPhoneVerified, isEmailVerified, isActive);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String name,
      required final String email,
      required final String phone,
      required final UserRole role,
      final String? avatar,
      final bool isPhoneVerified,
      final bool isEmailVerified,
      final bool isActive}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get phone;
  @override
  UserRole get role;
  @override
  String? get avatar;
  @override
  bool get isPhoneVerified;
  @override
  bool get isEmailVerified;
  @override
  bool get isActive;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerProfile _$CustomerProfileFromJson(Map<String, dynamic> json) {
  return _CustomerProfile.fromJson(json);
}

/// @nodoc
mixin _$CustomerProfile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get referralCode => throw _privateConstructorUsedError;
  String? get referredBy => throw _privateConstructorUsedError;
  int get loyaltyPoints => throw _privateConstructorUsedError;
  double get walletBalance => throw _privateConstructorUsedError;
  List<String> get favoriteRestaurants => throw _privateConstructorUsedError;

  /// Serializes this CustomerProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerProfileCopyWith<CustomerProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerProfileCopyWith<$Res> {
  factory $CustomerProfileCopyWith(
          CustomerProfile value, $Res Function(CustomerProfile) then) =
      _$CustomerProfileCopyWithImpl<$Res, CustomerProfile>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? referralCode,
      String? referredBy,
      int loyaltyPoints,
      double walletBalance,
      List<String> favoriteRestaurants});
}

/// @nodoc
class _$CustomerProfileCopyWithImpl<$Res, $Val extends CustomerProfile>
    implements $CustomerProfileCopyWith<$Res> {
  _$CustomerProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referralCode = freezed,
    Object? referredBy = freezed,
    Object? loyaltyPoints = null,
    Object? walletBalance = null,
    Object? favoriteRestaurants = null,
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
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referredBy: freezed == referredBy
          ? _value.referredBy
          : referredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      loyaltyPoints: null == loyaltyPoints
          ? _value.loyaltyPoints
          : loyaltyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      favoriteRestaurants: null == favoriteRestaurants
          ? _value.favoriteRestaurants
          : favoriteRestaurants // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerProfileImplCopyWith<$Res>
    implements $CustomerProfileCopyWith<$Res> {
  factory _$$CustomerProfileImplCopyWith(_$CustomerProfileImpl value,
          $Res Function(_$CustomerProfileImpl) then) =
      __$$CustomerProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? referralCode,
      String? referredBy,
      int loyaltyPoints,
      double walletBalance,
      List<String> favoriteRestaurants});
}

/// @nodoc
class __$$CustomerProfileImplCopyWithImpl<$Res>
    extends _$CustomerProfileCopyWithImpl<$Res, _$CustomerProfileImpl>
    implements _$$CustomerProfileImplCopyWith<$Res> {
  __$$CustomerProfileImplCopyWithImpl(
      _$CustomerProfileImpl _value, $Res Function(_$CustomerProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referralCode = freezed,
    Object? referredBy = freezed,
    Object? loyaltyPoints = null,
    Object? walletBalance = null,
    Object? favoriteRestaurants = null,
  }) {
    return _then(_$CustomerProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referredBy: freezed == referredBy
          ? _value.referredBy
          : referredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      loyaltyPoints: null == loyaltyPoints
          ? _value.loyaltyPoints
          : loyaltyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      favoriteRestaurants: null == favoriteRestaurants
          ? _value._favoriteRestaurants
          : favoriteRestaurants // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerProfileImpl implements _CustomerProfile {
  const _$CustomerProfileImpl(
      {required this.id,
      required this.userId,
      this.referralCode,
      this.referredBy,
      this.loyaltyPoints = 0,
      this.walletBalance = 0.0,
      final List<String> favoriteRestaurants = const []})
      : _favoriteRestaurants = favoriteRestaurants;

  factory _$CustomerProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? referralCode;
  @override
  final String? referredBy;
  @override
  @JsonKey()
  final int loyaltyPoints;
  @override
  @JsonKey()
  final double walletBalance;
  final List<String> _favoriteRestaurants;
  @override
  @JsonKey()
  List<String> get favoriteRestaurants {
    if (_favoriteRestaurants is EqualUnmodifiableListView)
      return _favoriteRestaurants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteRestaurants);
  }

  @override
  String toString() {
    return 'CustomerProfile(id: $id, userId: $userId, referralCode: $referralCode, referredBy: $referredBy, loyaltyPoints: $loyaltyPoints, walletBalance: $walletBalance, favoriteRestaurants: $favoriteRestaurants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.referredBy, referredBy) ||
                other.referredBy == referredBy) &&
            (identical(other.loyaltyPoints, loyaltyPoints) ||
                other.loyaltyPoints == loyaltyPoints) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            const DeepCollectionEquality()
                .equals(other._favoriteRestaurants, _favoriteRestaurants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      referralCode,
      referredBy,
      loyaltyPoints,
      walletBalance,
      const DeepCollectionEquality().hash(_favoriteRestaurants));

  /// Create a copy of CustomerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerProfileImplCopyWith<_$CustomerProfileImpl> get copyWith =>
      __$$CustomerProfileImplCopyWithImpl<_$CustomerProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerProfileImplToJson(
      this,
    );
  }
}

abstract class _CustomerProfile implements CustomerProfile {
  const factory _CustomerProfile(
      {required final String id,
      required final String userId,
      final String? referralCode,
      final String? referredBy,
      final int loyaltyPoints,
      final double walletBalance,
      final List<String> favoriteRestaurants}) = _$CustomerProfileImpl;

  factory _CustomerProfile.fromJson(Map<String, dynamic> json) =
      _$CustomerProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get referralCode;
  @override
  String? get referredBy;
  @override
  int get loyaltyPoints;
  @override
  double get walletBalance;
  @override
  List<String> get favoriteRestaurants;

  /// Create a copy of CustomerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerProfileImplCopyWith<_$CustomerProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
