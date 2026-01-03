// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverOrderItem _$DriverOrderItemFromJson(Map<String, dynamic> json) {
  return _DriverOrderItem.fromJson(json);
}

/// @nodoc
mixin _$DriverOrderItem {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;

  /// Serializes this DriverOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverOrderItemCopyWith<DriverOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverOrderItemCopyWith<$Res> {
  factory $DriverOrderItemCopyWith(
          DriverOrderItem value, $Res Function(DriverOrderItem) then) =
      _$DriverOrderItemCopyWithImpl<$Res, DriverOrderItem>;
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      int quantity,
      double price,
      String? specialInstructions});
}

/// @nodoc
class _$DriverOrderItemCopyWithImpl<$Res, $Val extends DriverOrderItem>
    implements $DriverOrderItemCopyWith<$Res> {
  _$DriverOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? quantity = null,
    Object? price = null,
    Object? specialInstructions = freezed,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverOrderItemImplCopyWith<$Res>
    implements $DriverOrderItemCopyWith<$Res> {
  factory _$$DriverOrderItemImplCopyWith(_$DriverOrderItemImpl value,
          $Res Function(_$DriverOrderItemImpl) then) =
      __$$DriverOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      int quantity,
      double price,
      String? specialInstructions});
}

/// @nodoc
class __$$DriverOrderItemImplCopyWithImpl<$Res>
    extends _$DriverOrderItemCopyWithImpl<$Res, _$DriverOrderItemImpl>
    implements _$$DriverOrderItemImplCopyWith<$Res> {
  __$$DriverOrderItemImplCopyWithImpl(
      _$DriverOrderItemImpl _value, $Res Function(_$DriverOrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? quantity = null,
    Object? price = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_$DriverOrderItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverOrderItemImpl extends _DriverOrderItem {
  const _$DriverOrderItemImpl(
      {required this.name,
      this.nameAr,
      required this.quantity,
      required this.price,
      this.specialInstructions})
      : super._();

  factory _$DriverOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverOrderItemImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final int quantity;
  @override
  final double price;
  @override
  final String? specialInstructions;

  @override
  String toString() {
    return 'DriverOrderItem(name: $name, nameAr: $nameAr, quantity: $quantity, price: $price, specialInstructions: $specialInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverOrderItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, nameAr, quantity, price, specialInstructions);

  /// Create a copy of DriverOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverOrderItemImplCopyWith<_$DriverOrderItemImpl> get copyWith =>
      __$$DriverOrderItemImplCopyWithImpl<_$DriverOrderItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverOrderItemImplToJson(
      this,
    );
  }
}

abstract class _DriverOrderItem extends DriverOrderItem {
  const factory _DriverOrderItem(
      {required final String name,
      final String? nameAr,
      required final int quantity,
      required final double price,
      final String? specialInstructions}) = _$DriverOrderItemImpl;
  const _DriverOrderItem._() : super._();

  factory _DriverOrderItem.fromJson(Map<String, dynamic> json) =
      _$DriverOrderItemImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  int get quantity;
  @override
  double get price;
  @override
  String? get specialInstructions;

  /// Create a copy of DriverOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverOrderItemImplCopyWith<_$DriverOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderRestaurant _$OrderRestaurantFromJson(Map<String, dynamic> json) {
  return _OrderRestaurant.fromJson(json);
}

/// @nodoc
mixin _$OrderRestaurant {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  List<double> get location => throw _privateConstructorUsedError;

  /// Serializes this OrderRestaurant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderRestaurantCopyWith<OrderRestaurant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderRestaurantCopyWith<$Res> {
  factory $OrderRestaurantCopyWith(
          OrderRestaurant value, $Res Function(OrderRestaurant) then) =
      _$OrderRestaurantCopyWithImpl<$Res, OrderRestaurant>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? nameAr,
      String? logo,
      String phone,
      String address,
      String area,
      List<double> location});
}

/// @nodoc
class _$OrderRestaurantCopyWithImpl<$Res, $Val extends OrderRestaurant>
    implements $OrderRestaurantCopyWith<$Res> {
  _$OrderRestaurantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? logo = freezed,
    Object? phone = null,
    Object? address = null,
    Object? area = null,
    Object? location = null,
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
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderRestaurantImplCopyWith<$Res>
    implements $OrderRestaurantCopyWith<$Res> {
  factory _$$OrderRestaurantImplCopyWith(_$OrderRestaurantImpl value,
          $Res Function(_$OrderRestaurantImpl) then) =
      __$$OrderRestaurantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? nameAr,
      String? logo,
      String phone,
      String address,
      String area,
      List<double> location});
}

/// @nodoc
class __$$OrderRestaurantImplCopyWithImpl<$Res>
    extends _$OrderRestaurantCopyWithImpl<$Res, _$OrderRestaurantImpl>
    implements _$$OrderRestaurantImplCopyWith<$Res> {
  __$$OrderRestaurantImplCopyWithImpl(
      _$OrderRestaurantImpl _value, $Res Function(_$OrderRestaurantImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? logo = freezed,
    Object? phone = null,
    Object? address = null,
    Object? area = null,
    Object? location = null,
  }) {
    return _then(_$OrderRestaurantImpl(
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
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderRestaurantImpl extends _OrderRestaurant {
  const _$OrderRestaurantImpl(
      {required this.id,
      required this.name,
      this.nameAr,
      this.logo,
      required this.phone,
      required this.address,
      required this.area,
      required final List<double> location})
      : _location = location,
        super._();

  factory _$OrderRestaurantImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderRestaurantImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? logo;
  @override
  final String phone;
  @override
  final String address;
  @override
  final String area;
  final List<double> _location;
  @override
  List<double> get location {
    if (_location is EqualUnmodifiableListView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_location);
  }

  @override
  String toString() {
    return 'OrderRestaurant(id: $id, name: $name, nameAr: $nameAr, logo: $logo, phone: $phone, address: $address, area: $area, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderRestaurantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.area, area) || other.area == area) &&
            const DeepCollectionEquality().equals(other._location, _location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, nameAr, logo, phone,
      address, area, const DeepCollectionEquality().hash(_location));

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderRestaurantImplCopyWith<_$OrderRestaurantImpl> get copyWith =>
      __$$OrderRestaurantImplCopyWithImpl<_$OrderRestaurantImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderRestaurantImplToJson(
      this,
    );
  }
}

abstract class _OrderRestaurant extends OrderRestaurant {
  const factory _OrderRestaurant(
      {required final String id,
      required final String name,
      final String? nameAr,
      final String? logo,
      required final String phone,
      required final String address,
      required final String area,
      required final List<double> location}) = _$OrderRestaurantImpl;
  const _OrderRestaurant._() : super._();

  factory _OrderRestaurant.fromJson(Map<String, dynamic> json) =
      _$OrderRestaurantImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get logo;
  @override
  String get phone;
  @override
  String get address;
  @override
  String get area;
  @override
  List<double> get location;

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderRestaurantImplCopyWith<_$OrderRestaurantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderCustomer _$OrderCustomerFromJson(Map<String, dynamic> json) {
  return _OrderCustomer.fromJson(json);
}

/// @nodoc
mixin _$OrderCustomer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Serializes this OrderCustomer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCustomerCopyWith<OrderCustomer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCustomerCopyWith<$Res> {
  factory $OrderCustomerCopyWith(
          OrderCustomer value, $Res Function(OrderCustomer) then) =
      _$OrderCustomerCopyWithImpl<$Res, OrderCustomer>;
  @useResult
  $Res call({String id, String name, String phone});
}

/// @nodoc
class _$OrderCustomerCopyWithImpl<$Res, $Val extends OrderCustomer>
    implements $OrderCustomerCopyWith<$Res> {
  _$OrderCustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
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
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderCustomerImplCopyWith<$Res>
    implements $OrderCustomerCopyWith<$Res> {
  factory _$$OrderCustomerImplCopyWith(
          _$OrderCustomerImpl value, $Res Function(_$OrderCustomerImpl) then) =
      __$$OrderCustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String phone});
}

/// @nodoc
class __$$OrderCustomerImplCopyWithImpl<$Res>
    extends _$OrderCustomerCopyWithImpl<$Res, _$OrderCustomerImpl>
    implements _$$OrderCustomerImplCopyWith<$Res> {
  __$$OrderCustomerImplCopyWithImpl(
      _$OrderCustomerImpl _value, $Res Function(_$OrderCustomerImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
  }) {
    return _then(_$OrderCustomerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderCustomerImpl implements _OrderCustomer {
  const _$OrderCustomerImpl(
      {required this.id, required this.name, required this.phone});

  factory _$OrderCustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderCustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;

  @override
  String toString() {
    return 'OrderCustomer(id: $id, name: $name, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderCustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phone);

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderCustomerImplCopyWith<_$OrderCustomerImpl> get copyWith =>
      __$$OrderCustomerImplCopyWithImpl<_$OrderCustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderCustomerImplToJson(
      this,
    );
  }
}

abstract class _OrderCustomer implements OrderCustomer {
  const factory _OrderCustomer(
      {required final String id,
      required final String name,
      required final String phone}) = _$OrderCustomerImpl;

  factory _OrderCustomer.fromJson(Map<String, dynamic> json) =
      _$OrderCustomerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phone;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderCustomerImplCopyWith<_$OrderCustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeliveryAddress _$DeliveryAddressFromJson(Map<String, dynamic> json) {
  return _DeliveryAddress.fromJson(json);
}

/// @nodoc
mixin _$DeliveryAddress {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;

  /// Serializes this DeliveryAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryAddressCopyWith<DeliveryAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryAddressCopyWith<$Res> {
  factory $DeliveryAddressCopyWith(
          DeliveryAddress value, $Res Function(DeliveryAddress) then) =
      _$DeliveryAddressCopyWithImpl<$Res, DeliveryAddress>;
  @useResult
  $Res call(
      {String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      List<double> coordinates});
}

/// @nodoc
class _$DeliveryAddressCopyWithImpl<$Res, $Val extends DeliveryAddress>
    implements $DeliveryAddressCopyWith<$Res> {
  _$DeliveryAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? coordinates = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      apartment: freezed == apartment
          ? _value.apartment
          : apartment // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeliveryAddressImplCopyWith<$Res>
    implements $DeliveryAddressCopyWith<$Res> {
  factory _$$DeliveryAddressImplCopyWith(_$DeliveryAddressImpl value,
          $Res Function(_$DeliveryAddressImpl) then) =
      __$$DeliveryAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      List<double> coordinates});
}

/// @nodoc
class __$$DeliveryAddressImplCopyWithImpl<$Res>
    extends _$DeliveryAddressCopyWithImpl<$Res, _$DeliveryAddressImpl>
    implements _$$DeliveryAddressImplCopyWith<$Res> {
  __$$DeliveryAddressImplCopyWithImpl(
      _$DeliveryAddressImpl _value, $Res Function(_$DeliveryAddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? coordinates = null,
  }) {
    return _then(_$DeliveryAddressImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      apartment: freezed == apartment
          ? _value.apartment
          : apartment // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryAddressImpl extends _DeliveryAddress {
  const _$DeliveryAddressImpl(
      {required this.name,
      required this.address,
      required this.area,
      required this.city,
      this.building,
      this.floor,
      this.apartment,
      this.landmark,
      required final List<double> coordinates})
      : _coordinates = coordinates,
        super._();

  factory _$DeliveryAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryAddressImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final String area;
  @override
  final String city;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final String? apartment;
  @override
  final String? landmark;
  final List<double> _coordinates;
  @override
  List<double> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  String toString() {
    return 'DeliveryAddress(name: $name, address: $address, area: $area, city: $city, building: $building, floor: $floor, apartment: $apartment, landmark: $landmark, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryAddressImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.apartment, apartment) ||
                other.apartment == apartment) &&
            (identical(other.landmark, landmark) ||
                other.landmark == landmark) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      address,
      area,
      city,
      building,
      floor,
      apartment,
      landmark,
      const DeepCollectionEquality().hash(_coordinates));

  /// Create a copy of DeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryAddressImplCopyWith<_$DeliveryAddressImpl> get copyWith =>
      __$$DeliveryAddressImplCopyWithImpl<_$DeliveryAddressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryAddressImplToJson(
      this,
    );
  }
}

abstract class _DeliveryAddress extends DeliveryAddress {
  const factory _DeliveryAddress(
      {required final String name,
      required final String address,
      required final String area,
      required final String city,
      final String? building,
      final String? floor,
      final String? apartment,
      final String? landmark,
      required final List<double> coordinates}) = _$DeliveryAddressImpl;
  const _DeliveryAddress._() : super._();

  factory _DeliveryAddress.fromJson(Map<String, dynamic> json) =
      _$DeliveryAddressImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String get area;
  @override
  String get city;
  @override
  String? get building;
  @override
  String? get floor;
  @override
  String? get apartment;
  @override
  String? get landmark;
  @override
  List<double> get coordinates;

  /// Create a copy of DeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryAddressImplCopyWith<_$DeliveryAddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverOrder _$DriverOrderFromJson(Map<String, dynamic> json) {
  return _DriverOrder.fromJson(json);
}

/// @nodoc
mixin _$DriverOrder {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  OrderRestaurant get restaurant => throw _privateConstructorUsedError;
  OrderCustomer get customer => throw _privateConstructorUsedError;
  List<DriverOrderItem> get items => throw _privateConstructorUsedError;
  DeliveryAddress get deliveryAddress => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime? get estimatedDeliveryTime => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Driver-specific fields
  double? get driverEarnings => throw _privateConstructorUsedError;
  double? get tip => throw _privateConstructorUsedError;
  double? get distanceKm => throw _privateConstructorUsedError;

  /// Serializes this DriverOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverOrderCopyWith<DriverOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverOrderCopyWith<$Res> {
  factory $DriverOrderCopyWith(
          DriverOrder value, $Res Function(DriverOrder) then) =
      _$DriverOrderCopyWithImpl<$Res, DriverOrder>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      OrderCustomer customer,
      List<DriverOrderItem> items,
      DeliveryAddress deliveryAddress,
      OrderStatus status,
      PaymentMethod paymentMethod,
      double subtotal,
      double deliveryFee,
      double discount,
      double total,
      String? notes,
      String? cancellationReason,
      DateTime? estimatedDeliveryTime,
      DateTime createdAt,
      DateTime? updatedAt,
      double? driverEarnings,
      double? tip,
      double? distanceKm});

  $OrderRestaurantCopyWith<$Res> get restaurant;
  $OrderCustomerCopyWith<$Res> get customer;
  $DeliveryAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class _$DriverOrderCopyWithImpl<$Res, $Val extends DriverOrder>
    implements $DriverOrderCopyWith<$Res> {
  _$DriverOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? customer = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? total = null,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? driverEarnings = freezed,
    Object? tip = freezed,
    Object? distanceKm = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as OrderRestaurant,
      customer: null == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as OrderCustomer,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DriverOrderItem>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as DeliveryAddress,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      driverEarnings: freezed == driverEarnings
          ? _value.driverEarnings
          : driverEarnings // ignore: cast_nullable_to_non_nullable
              as double?,
      tip: freezed == tip
          ? _value.tip
          : tip // ignore: cast_nullable_to_non_nullable
              as double?,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderRestaurantCopyWith<$Res> get restaurant {
    return $OrderRestaurantCopyWith<$Res>(_value.restaurant, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCustomerCopyWith<$Res> get customer {
    return $OrderCustomerCopyWith<$Res>(_value.customer, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryAddressCopyWith<$Res> get deliveryAddress {
    return $DeliveryAddressCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverOrderImplCopyWith<$Res>
    implements $DriverOrderCopyWith<$Res> {
  factory _$$DriverOrderImplCopyWith(
          _$DriverOrderImpl value, $Res Function(_$DriverOrderImpl) then) =
      __$$DriverOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      OrderCustomer customer,
      List<DriverOrderItem> items,
      DeliveryAddress deliveryAddress,
      OrderStatus status,
      PaymentMethod paymentMethod,
      double subtotal,
      double deliveryFee,
      double discount,
      double total,
      String? notes,
      String? cancellationReason,
      DateTime? estimatedDeliveryTime,
      DateTime createdAt,
      DateTime? updatedAt,
      double? driverEarnings,
      double? tip,
      double? distanceKm});

  @override
  $OrderRestaurantCopyWith<$Res> get restaurant;
  @override
  $OrderCustomerCopyWith<$Res> get customer;
  @override
  $DeliveryAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class __$$DriverOrderImplCopyWithImpl<$Res>
    extends _$DriverOrderCopyWithImpl<$Res, _$DriverOrderImpl>
    implements _$$DriverOrderImplCopyWith<$Res> {
  __$$DriverOrderImplCopyWithImpl(
      _$DriverOrderImpl _value, $Res Function(_$DriverOrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? customer = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? total = null,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? driverEarnings = freezed,
    Object? tip = freezed,
    Object? distanceKm = freezed,
  }) {
    return _then(_$DriverOrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as OrderRestaurant,
      customer: null == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as OrderCustomer,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DriverOrderItem>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as DeliveryAddress,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      driverEarnings: freezed == driverEarnings
          ? _value.driverEarnings
          : driverEarnings // ignore: cast_nullable_to_non_nullable
              as double?,
      tip: freezed == tip
          ? _value.tip
          : tip // ignore: cast_nullable_to_non_nullable
              as double?,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverOrderImpl extends _DriverOrder {
  const _$DriverOrderImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.orderNumber,
      required this.restaurant,
      required this.customer,
      required final List<DriverOrderItem> items,
      required this.deliveryAddress,
      required this.status,
      required this.paymentMethod,
      required this.subtotal,
      required this.deliveryFee,
      this.discount = 0.0,
      required this.total,
      this.notes,
      this.cancellationReason,
      this.estimatedDeliveryTime,
      required this.createdAt,
      this.updatedAt,
      this.driverEarnings,
      this.tip,
      this.distanceKm})
      : _items = items,
        super._();

  factory _$DriverOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverOrderImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String orderNumber;
  @override
  final OrderRestaurant restaurant;
  @override
  final OrderCustomer customer;
  final List<DriverOrderItem> _items;
  @override
  List<DriverOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DeliveryAddress deliveryAddress;
  @override
  final OrderStatus status;
  @override
  final PaymentMethod paymentMethod;
  @override
  final double subtotal;
  @override
  final double deliveryFee;
  @override
  @JsonKey()
  final double discount;
  @override
  final double total;
  @override
  final String? notes;
  @override
  final String? cancellationReason;
  @override
  final DateTime? estimatedDeliveryTime;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// Driver-specific fields
  @override
  final double? driverEarnings;
  @override
  final double? tip;
  @override
  final double? distanceKm;

  @override
  String toString() {
    return 'DriverOrder(id: $id, orderNumber: $orderNumber, restaurant: $restaurant, customer: $customer, items: $items, deliveryAddress: $deliveryAddress, status: $status, paymentMethod: $paymentMethod, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, total: $total, notes: $notes, cancellationReason: $cancellationReason, estimatedDeliveryTime: $estimatedDeliveryTime, createdAt: $createdAt, updatedAt: $updatedAt, driverEarnings: $driverEarnings, tip: $tip, distanceKm: $distanceKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.driverEarnings, driverEarnings) ||
                other.driverEarnings == driverEarnings) &&
            (identical(other.tip, tip) || other.tip == tip) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        orderNumber,
        restaurant,
        customer,
        const DeepCollectionEquality().hash(_items),
        deliveryAddress,
        status,
        paymentMethod,
        subtotal,
        deliveryFee,
        discount,
        total,
        notes,
        cancellationReason,
        estimatedDeliveryTime,
        createdAt,
        updatedAt,
        driverEarnings,
        tip,
        distanceKm
      ]);

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverOrderImplCopyWith<_$DriverOrderImpl> get copyWith =>
      __$$DriverOrderImplCopyWithImpl<_$DriverOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverOrderImplToJson(
      this,
    );
  }
}

abstract class _DriverOrder extends DriverOrder {
  const factory _DriverOrder(
      {@JsonKey(name: '_id') required final String id,
      required final String orderNumber,
      required final OrderRestaurant restaurant,
      required final OrderCustomer customer,
      required final List<DriverOrderItem> items,
      required final DeliveryAddress deliveryAddress,
      required final OrderStatus status,
      required final PaymentMethod paymentMethod,
      required final double subtotal,
      required final double deliveryFee,
      final double discount,
      required final double total,
      final String? notes,
      final String? cancellationReason,
      final DateTime? estimatedDeliveryTime,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final double? driverEarnings,
      final double? tip,
      final double? distanceKm}) = _$DriverOrderImpl;
  const _DriverOrder._() : super._();

  factory _DriverOrder.fromJson(Map<String, dynamic> json) =
      _$DriverOrderImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get orderNumber;
  @override
  OrderRestaurant get restaurant;
  @override
  OrderCustomer get customer;
  @override
  List<DriverOrderItem> get items;
  @override
  DeliveryAddress get deliveryAddress;
  @override
  OrderStatus get status;
  @override
  PaymentMethod get paymentMethod;
  @override
  double get subtotal;
  @override
  double get deliveryFee;
  @override
  double get discount;
  @override
  double get total;
  @override
  String? get notes;
  @override
  String? get cancellationReason;
  @override
  DateTime? get estimatedDeliveryTime;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // Driver-specific fields
  @override
  double? get driverEarnings;
  @override
  double? get tip;
  @override
  double? get distanceKm;

  /// Create a copy of DriverOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverOrderImplCopyWith<_$DriverOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailableOrder _$AvailableOrderFromJson(Map<String, dynamic> json) {
  return _AvailableOrder.fromJson(json);
}

/// @nodoc
mixin _$AvailableOrder {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  OrderRestaurant get restaurant => throw _privateConstructorUsedError;
  DeliveryAddress get deliveryAddress => throw _privateConstructorUsedError;
  int get itemsCount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double? get distanceKm => throw _privateConstructorUsedError;
  double? get estimatedEarnings => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this AvailableOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailableOrderCopyWith<AvailableOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailableOrderCopyWith<$Res> {
  factory $AvailableOrderCopyWith(
          AvailableOrder value, $Res Function(AvailableOrder) then) =
      _$AvailableOrderCopyWithImpl<$Res, AvailableOrder>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      DeliveryAddress deliveryAddress,
      int itemsCount,
      double total,
      PaymentMethod paymentMethod,
      double deliveryFee,
      double? distanceKm,
      double? estimatedEarnings,
      DateTime createdAt,
      DateTime? expiresAt});

  $OrderRestaurantCopyWith<$Res> get restaurant;
  $DeliveryAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class _$AvailableOrderCopyWithImpl<$Res, $Val extends AvailableOrder>
    implements $AvailableOrderCopyWith<$Res> {
  _$AvailableOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? deliveryAddress = null,
    Object? itemsCount = null,
    Object? total = null,
    Object? paymentMethod = null,
    Object? deliveryFee = null,
    Object? distanceKm = freezed,
    Object? estimatedEarnings = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as OrderRestaurant,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as DeliveryAddress,
      itemsCount: null == itemsCount
          ? _value.itemsCount
          : itemsCount // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedEarnings: freezed == estimatedEarnings
          ? _value.estimatedEarnings
          : estimatedEarnings // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderRestaurantCopyWith<$Res> get restaurant {
    return $OrderRestaurantCopyWith<$Res>(_value.restaurant, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryAddressCopyWith<$Res> get deliveryAddress {
    return $DeliveryAddressCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AvailableOrderImplCopyWith<$Res>
    implements $AvailableOrderCopyWith<$Res> {
  factory _$$AvailableOrderImplCopyWith(_$AvailableOrderImpl value,
          $Res Function(_$AvailableOrderImpl) then) =
      __$$AvailableOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      DeliveryAddress deliveryAddress,
      int itemsCount,
      double total,
      PaymentMethod paymentMethod,
      double deliveryFee,
      double? distanceKm,
      double? estimatedEarnings,
      DateTime createdAt,
      DateTime? expiresAt});

  @override
  $OrderRestaurantCopyWith<$Res> get restaurant;
  @override
  $DeliveryAddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class __$$AvailableOrderImplCopyWithImpl<$Res>
    extends _$AvailableOrderCopyWithImpl<$Res, _$AvailableOrderImpl>
    implements _$$AvailableOrderImplCopyWith<$Res> {
  __$$AvailableOrderImplCopyWithImpl(
      _$AvailableOrderImpl _value, $Res Function(_$AvailableOrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? deliveryAddress = null,
    Object? itemsCount = null,
    Object? total = null,
    Object? paymentMethod = null,
    Object? deliveryFee = null,
    Object? distanceKm = freezed,
    Object? estimatedEarnings = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$AvailableOrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as OrderRestaurant,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as DeliveryAddress,
      itemsCount: null == itemsCount
          ? _value.itemsCount
          : itemsCount // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedEarnings: freezed == estimatedEarnings
          ? _value.estimatedEarnings
          : estimatedEarnings // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailableOrderImpl extends _AvailableOrder {
  const _$AvailableOrderImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.orderNumber,
      required this.restaurant,
      required this.deliveryAddress,
      required this.itemsCount,
      required this.total,
      required this.paymentMethod,
      required this.deliveryFee,
      this.distanceKm,
      this.estimatedEarnings,
      required this.createdAt,
      this.expiresAt})
      : super._();

  factory _$AvailableOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailableOrderImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String orderNumber;
  @override
  final OrderRestaurant restaurant;
  @override
  final DeliveryAddress deliveryAddress;
  @override
  final int itemsCount;
  @override
  final double total;
  @override
  final PaymentMethod paymentMethod;
  @override
  final double deliveryFee;
  @override
  final double? distanceKm;
  @override
  final double? estimatedEarnings;
  @override
  final DateTime createdAt;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'AvailableOrder(id: $id, orderNumber: $orderNumber, restaurant: $restaurant, deliveryAddress: $deliveryAddress, itemsCount: $itemsCount, total: $total, paymentMethod: $paymentMethod, deliveryFee: $deliveryFee, distanceKm: $distanceKm, estimatedEarnings: $estimatedEarnings, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.itemsCount, itemsCount) ||
                other.itemsCount == itemsCount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.estimatedEarnings, estimatedEarnings) ||
                other.estimatedEarnings == estimatedEarnings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderNumber,
      restaurant,
      deliveryAddress,
      itemsCount,
      total,
      paymentMethod,
      deliveryFee,
      distanceKm,
      estimatedEarnings,
      createdAt,
      expiresAt);

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableOrderImplCopyWith<_$AvailableOrderImpl> get copyWith =>
      __$$AvailableOrderImplCopyWithImpl<_$AvailableOrderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailableOrderImplToJson(
      this,
    );
  }
}

abstract class _AvailableOrder extends AvailableOrder {
  const factory _AvailableOrder(
      {@JsonKey(name: '_id') required final String id,
      required final String orderNumber,
      required final OrderRestaurant restaurant,
      required final DeliveryAddress deliveryAddress,
      required final int itemsCount,
      required final double total,
      required final PaymentMethod paymentMethod,
      required final double deliveryFee,
      final double? distanceKm,
      final double? estimatedEarnings,
      required final DateTime createdAt,
      final DateTime? expiresAt}) = _$AvailableOrderImpl;
  const _AvailableOrder._() : super._();

  factory _AvailableOrder.fromJson(Map<String, dynamic> json) =
      _$AvailableOrderImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get orderNumber;
  @override
  OrderRestaurant get restaurant;
  @override
  DeliveryAddress get deliveryAddress;
  @override
  int get itemsCount;
  @override
  double get total;
  @override
  PaymentMethod get paymentMethod;
  @override
  double get deliveryFee;
  @override
  double? get distanceKm;
  @override
  double? get estimatedEarnings;
  @override
  DateTime get createdAt;
  @override
  DateTime? get expiresAt;

  /// Create a copy of AvailableOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailableOrderImplCopyWith<_$AvailableOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) {
  return _EarningsSummary.fromJson(json);
}

/// @nodoc
mixin _$EarningsSummary {
  double get todayEarnings => throw _privateConstructorUsedError;
  double get weekEarnings => throw _privateConstructorUsedError;
  double get monthEarnings => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;
  int get todayDeliveries => throw _privateConstructorUsedError;
  int get weekDeliveries => throw _privateConstructorUsedError;
  int get monthDeliveries => throw _privateConstructorUsedError;
  int get totalDeliveries => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalRatings => throw _privateConstructorUsedError;
  double get pendingBalance => throw _privateConstructorUsedError;
  double get availableBalance => throw _privateConstructorUsedError;

  /// Serializes this EarningsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EarningsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarningsSummaryCopyWith<EarningsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningsSummaryCopyWith<$Res> {
  factory $EarningsSummaryCopyWith(
          EarningsSummary value, $Res Function(EarningsSummary) then) =
      _$EarningsSummaryCopyWithImpl<$Res, EarningsSummary>;
  @useResult
  $Res call(
      {double todayEarnings,
      double weekEarnings,
      double monthEarnings,
      double totalEarnings,
      int todayDeliveries,
      int weekDeliveries,
      int monthDeliveries,
      int totalDeliveries,
      double averageRating,
      int totalRatings,
      double pendingBalance,
      double availableBalance});
}

/// @nodoc
class _$EarningsSummaryCopyWithImpl<$Res, $Val extends EarningsSummary>
    implements $EarningsSummaryCopyWith<$Res> {
  _$EarningsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarningsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayEarnings = null,
    Object? weekEarnings = null,
    Object? monthEarnings = null,
    Object? totalEarnings = null,
    Object? todayDeliveries = null,
    Object? weekDeliveries = null,
    Object? monthDeliveries = null,
    Object? totalDeliveries = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? pendingBalance = null,
    Object? availableBalance = null,
  }) {
    return _then(_value.copyWith(
      todayEarnings: null == todayEarnings
          ? _value.todayEarnings
          : todayEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      weekEarnings: null == weekEarnings
          ? _value.weekEarnings
          : weekEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      monthEarnings: null == monthEarnings
          ? _value.monthEarnings
          : monthEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      todayDeliveries: null == todayDeliveries
          ? _value.todayDeliveries
          : todayDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      weekDeliveries: null == weekDeliveries
          ? _value.weekDeliveries
          : weekDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      monthDeliveries: null == monthDeliveries
          ? _value.monthDeliveries
          : monthDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EarningsSummaryImplCopyWith<$Res>
    implements $EarningsSummaryCopyWith<$Res> {
  factory _$$EarningsSummaryImplCopyWith(_$EarningsSummaryImpl value,
          $Res Function(_$EarningsSummaryImpl) then) =
      __$$EarningsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double todayEarnings,
      double weekEarnings,
      double monthEarnings,
      double totalEarnings,
      int todayDeliveries,
      int weekDeliveries,
      int monthDeliveries,
      int totalDeliveries,
      double averageRating,
      int totalRatings,
      double pendingBalance,
      double availableBalance});
}

/// @nodoc
class __$$EarningsSummaryImplCopyWithImpl<$Res>
    extends _$EarningsSummaryCopyWithImpl<$Res, _$EarningsSummaryImpl>
    implements _$$EarningsSummaryImplCopyWith<$Res> {
  __$$EarningsSummaryImplCopyWithImpl(
      _$EarningsSummaryImpl _value, $Res Function(_$EarningsSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of EarningsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayEarnings = null,
    Object? weekEarnings = null,
    Object? monthEarnings = null,
    Object? totalEarnings = null,
    Object? todayDeliveries = null,
    Object? weekDeliveries = null,
    Object? monthDeliveries = null,
    Object? totalDeliveries = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? pendingBalance = null,
    Object? availableBalance = null,
  }) {
    return _then(_$EarningsSummaryImpl(
      todayEarnings: null == todayEarnings
          ? _value.todayEarnings
          : todayEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      weekEarnings: null == weekEarnings
          ? _value.weekEarnings
          : weekEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      monthEarnings: null == monthEarnings
          ? _value.monthEarnings
          : monthEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      todayDeliveries: null == todayDeliveries
          ? _value.todayDeliveries
          : todayDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      weekDeliveries: null == weekDeliveries
          ? _value.weekDeliveries
          : weekDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      monthDeliveries: null == monthDeliveries
          ? _value.monthDeliveries
          : monthDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EarningsSummaryImpl implements _EarningsSummary {
  const _$EarningsSummaryImpl(
      {required this.todayEarnings,
      required this.weekEarnings,
      required this.monthEarnings,
      required this.totalEarnings,
      required this.todayDeliveries,
      required this.weekDeliveries,
      required this.monthDeliveries,
      required this.totalDeliveries,
      required this.averageRating,
      required this.totalRatings,
      this.pendingBalance = 0.0,
      this.availableBalance = 0.0});

  factory _$EarningsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarningsSummaryImplFromJson(json);

  @override
  final double todayEarnings;
  @override
  final double weekEarnings;
  @override
  final double monthEarnings;
  @override
  final double totalEarnings;
  @override
  final int todayDeliveries;
  @override
  final int weekDeliveries;
  @override
  final int monthDeliveries;
  @override
  final int totalDeliveries;
  @override
  final double averageRating;
  @override
  final int totalRatings;
  @override
  @JsonKey()
  final double pendingBalance;
  @override
  @JsonKey()
  final double availableBalance;

  @override
  String toString() {
    return 'EarningsSummary(todayEarnings: $todayEarnings, weekEarnings: $weekEarnings, monthEarnings: $monthEarnings, totalEarnings: $totalEarnings, todayDeliveries: $todayDeliveries, weekDeliveries: $weekDeliveries, monthDeliveries: $monthDeliveries, totalDeliveries: $totalDeliveries, averageRating: $averageRating, totalRatings: $totalRatings, pendingBalance: $pendingBalance, availableBalance: $availableBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningsSummaryImpl &&
            (identical(other.todayEarnings, todayEarnings) ||
                other.todayEarnings == todayEarnings) &&
            (identical(other.weekEarnings, weekEarnings) ||
                other.weekEarnings == weekEarnings) &&
            (identical(other.monthEarnings, monthEarnings) ||
                other.monthEarnings == monthEarnings) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.todayDeliveries, todayDeliveries) ||
                other.todayDeliveries == todayDeliveries) &&
            (identical(other.weekDeliveries, weekDeliveries) ||
                other.weekDeliveries == weekDeliveries) &&
            (identical(other.monthDeliveries, monthDeliveries) ||
                other.monthDeliveries == monthDeliveries) &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalRatings, totalRatings) ||
                other.totalRatings == totalRatings) &&
            (identical(other.pendingBalance, pendingBalance) ||
                other.pendingBalance == pendingBalance) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      todayEarnings,
      weekEarnings,
      monthEarnings,
      totalEarnings,
      todayDeliveries,
      weekDeliveries,
      monthDeliveries,
      totalDeliveries,
      averageRating,
      totalRatings,
      pendingBalance,
      availableBalance);

  /// Create a copy of EarningsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningsSummaryImplCopyWith<_$EarningsSummaryImpl> get copyWith =>
      __$$EarningsSummaryImplCopyWithImpl<_$EarningsSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarningsSummaryImplToJson(
      this,
    );
  }
}

abstract class _EarningsSummary implements EarningsSummary {
  const factory _EarningsSummary(
      {required final double todayEarnings,
      required final double weekEarnings,
      required final double monthEarnings,
      required final double totalEarnings,
      required final int todayDeliveries,
      required final int weekDeliveries,
      required final int monthDeliveries,
      required final int totalDeliveries,
      required final double averageRating,
      required final int totalRatings,
      final double pendingBalance,
      final double availableBalance}) = _$EarningsSummaryImpl;

  factory _EarningsSummary.fromJson(Map<String, dynamic> json) =
      _$EarningsSummaryImpl.fromJson;

  @override
  double get todayEarnings;
  @override
  double get weekEarnings;
  @override
  double get monthEarnings;
  @override
  double get totalEarnings;
  @override
  int get todayDeliveries;
  @override
  int get weekDeliveries;
  @override
  int get monthDeliveries;
  @override
  int get totalDeliveries;
  @override
  double get averageRating;
  @override
  int get totalRatings;
  @override
  double get pendingBalance;
  @override
  double get availableBalance;

  /// Create a copy of EarningsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarningsSummaryImplCopyWith<_$EarningsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverStats _$DriverStatsFromJson(Map<String, dynamic> json) {
  return _DriverStats.fromJson(json);
}

/// @nodoc
mixin _$DriverStats {
  int get todayDeliveries => throw _privateConstructorUsedError;
  double get todayEarnings => throw _privateConstructorUsedError;
  int get pendingOrders => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get totalRatings => throw _privateConstructorUsedError;
  double get acceptanceRate => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;

  /// Serializes this DriverStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverStatsCopyWith<DriverStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverStatsCopyWith<$Res> {
  factory $DriverStatsCopyWith(
          DriverStats value, $Res Function(DriverStats) then) =
      _$DriverStatsCopyWithImpl<$Res, DriverStats>;
  @useResult
  $Res call(
      {int todayDeliveries,
      double todayEarnings,
      int pendingOrders,
      double rating,
      int totalRatings,
      double acceptanceRate,
      double completionRate});
}

/// @nodoc
class _$DriverStatsCopyWithImpl<$Res, $Val extends DriverStats>
    implements $DriverStatsCopyWith<$Res> {
  _$DriverStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayDeliveries = null,
    Object? todayEarnings = null,
    Object? pendingOrders = null,
    Object? rating = null,
    Object? totalRatings = null,
    Object? acceptanceRate = null,
    Object? completionRate = null,
  }) {
    return _then(_value.copyWith(
      todayDeliveries: null == todayDeliveries
          ? _value.todayDeliveries
          : todayDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      todayEarnings: null == todayEarnings
          ? _value.todayEarnings
          : todayEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingOrders: null == pendingOrders
          ? _value.pendingOrders
          : pendingOrders // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      acceptanceRate: null == acceptanceRate
          ? _value.acceptanceRate
          : acceptanceRate // ignore: cast_nullable_to_non_nullable
              as double,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverStatsImplCopyWith<$Res>
    implements $DriverStatsCopyWith<$Res> {
  factory _$$DriverStatsImplCopyWith(
          _$DriverStatsImpl value, $Res Function(_$DriverStatsImpl) then) =
      __$$DriverStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int todayDeliveries,
      double todayEarnings,
      int pendingOrders,
      double rating,
      int totalRatings,
      double acceptanceRate,
      double completionRate});
}

/// @nodoc
class __$$DriverStatsImplCopyWithImpl<$Res>
    extends _$DriverStatsCopyWithImpl<$Res, _$DriverStatsImpl>
    implements _$$DriverStatsImplCopyWith<$Res> {
  __$$DriverStatsImplCopyWithImpl(
      _$DriverStatsImpl _value, $Res Function(_$DriverStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayDeliveries = null,
    Object? todayEarnings = null,
    Object? pendingOrders = null,
    Object? rating = null,
    Object? totalRatings = null,
    Object? acceptanceRate = null,
    Object? completionRate = null,
  }) {
    return _then(_$DriverStatsImpl(
      todayDeliveries: null == todayDeliveries
          ? _value.todayDeliveries
          : todayDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      todayEarnings: null == todayEarnings
          ? _value.todayEarnings
          : todayEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingOrders: null == pendingOrders
          ? _value.pendingOrders
          : pendingOrders // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      acceptanceRate: null == acceptanceRate
          ? _value.acceptanceRate
          : acceptanceRate // ignore: cast_nullable_to_non_nullable
              as double,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverStatsImpl implements _DriverStats {
  const _$DriverStatsImpl(
      {this.todayDeliveries = 0,
      this.todayEarnings = 0.0,
      this.pendingOrders = 0,
      this.rating = 0.0,
      this.totalRatings = 0,
      this.acceptanceRate = 0.0,
      this.completionRate = 0.0});

  factory _$DriverStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverStatsImplFromJson(json);

  @override
  @JsonKey()
  final int todayDeliveries;
  @override
  @JsonKey()
  final double todayEarnings;
  @override
  @JsonKey()
  final int pendingOrders;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int totalRatings;
  @override
  @JsonKey()
  final double acceptanceRate;
  @override
  @JsonKey()
  final double completionRate;

  @override
  String toString() {
    return 'DriverStats(todayDeliveries: $todayDeliveries, todayEarnings: $todayEarnings, pendingOrders: $pendingOrders, rating: $rating, totalRatings: $totalRatings, acceptanceRate: $acceptanceRate, completionRate: $completionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverStatsImpl &&
            (identical(other.todayDeliveries, todayDeliveries) ||
                other.todayDeliveries == todayDeliveries) &&
            (identical(other.todayEarnings, todayEarnings) ||
                other.todayEarnings == todayEarnings) &&
            (identical(other.pendingOrders, pendingOrders) ||
                other.pendingOrders == pendingOrders) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalRatings, totalRatings) ||
                other.totalRatings == totalRatings) &&
            (identical(other.acceptanceRate, acceptanceRate) ||
                other.acceptanceRate == acceptanceRate) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, todayDeliveries, todayEarnings,
      pendingOrders, rating, totalRatings, acceptanceRate, completionRate);

  /// Create a copy of DriverStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverStatsImplCopyWith<_$DriverStatsImpl> get copyWith =>
      __$$DriverStatsImplCopyWithImpl<_$DriverStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverStatsImplToJson(
      this,
    );
  }
}

abstract class _DriverStats implements DriverStats {
  const factory _DriverStats(
      {final int todayDeliveries,
      final double todayEarnings,
      final int pendingOrders,
      final double rating,
      final int totalRatings,
      final double acceptanceRate,
      final double completionRate}) = _$DriverStatsImpl;

  factory _DriverStats.fromJson(Map<String, dynamic> json) =
      _$DriverStatsImpl.fromJson;

  @override
  int get todayDeliveries;
  @override
  double get todayEarnings;
  @override
  int get pendingOrders;
  @override
  double get rating;
  @override
  int get totalRatings;
  @override
  double get acceptanceRate;
  @override
  double get completionRate;

  /// Create a copy of DriverStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverStatsImplCopyWith<_$DriverStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
