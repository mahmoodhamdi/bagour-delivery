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

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get menuItemId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  List<OrderItemAddon> get addons => throw _privateConstructorUsedError;
  List<OrderItemVariation> get variations => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call(
      {String menuItemId,
      String name,
      String? nameAr,
      String? image,
      double price,
      int quantity,
      List<OrderItemAddon> addons,
      List<OrderItemVariation> variations,
      String? specialInstructions});
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? image = freezed,
    Object? price = null,
    Object? quantity = null,
    Object? addons = null,
    Object? variations = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_value.copyWith(
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      addons: null == addons
          ? _value.addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<OrderItemAddon>,
      variations: null == variations
          ? _value.variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<OrderItemVariation>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
          _$OrderItemImpl value, $Res Function(_$OrderItemImpl) then) =
      __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String menuItemId,
      String name,
      String? nameAr,
      String? image,
      double price,
      int quantity,
      List<OrderItemAddon> addons,
      List<OrderItemVariation> variations,
      String? specialInstructions});
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
      _$OrderItemImpl _value, $Res Function(_$OrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? nameAr = freezed,
    Object? image = freezed,
    Object? price = null,
    Object? quantity = null,
    Object? addons = null,
    Object? variations = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_$OrderItemImpl(
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      addons: null == addons
          ? _value._addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<OrderItemAddon>,
      variations: null == variations
          ? _value._variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<OrderItemVariation>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl extends _OrderItem {
  const _$OrderItemImpl(
      {required this.menuItemId,
      required this.name,
      this.nameAr,
      this.image,
      required this.price,
      required this.quantity,
      final List<OrderItemAddon> addons = const [],
      final List<OrderItemVariation> variations = const [],
      this.specialInstructions})
      : _addons = addons,
        _variations = variations,
        super._();

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String menuItemId;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? image;
  @override
  final double price;
  @override
  final int quantity;
  final List<OrderItemAddon> _addons;
  @override
  @JsonKey()
  List<OrderItemAddon> get addons {
    if (_addons is EqualUnmodifiableListView) return _addons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addons);
  }

  final List<OrderItemVariation> _variations;
  @override
  @JsonKey()
  List<OrderItemVariation> get variations {
    if (_variations is EqualUnmodifiableListView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variations);
  }

  @override
  final String? specialInstructions;

  @override
  String toString() {
    return 'OrderItem(menuItemId: $menuItemId, name: $name, nameAr: $nameAr, image: $image, price: $price, quantity: $quantity, addons: $addons, variations: $variations, specialInstructions: $specialInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality().equals(other._addons, _addons) &&
            const DeepCollectionEquality()
                .equals(other._variations, _variations) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      menuItemId,
      name,
      nameAr,
      image,
      price,
      quantity,
      const DeepCollectionEquality().hash(_addons),
      const DeepCollectionEquality().hash(_variations),
      specialInstructions);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(
      this,
    );
  }
}

abstract class _OrderItem extends OrderItem {
  const factory _OrderItem(
      {required final String menuItemId,
      required final String name,
      final String? nameAr,
      final String? image,
      required final double price,
      required final int quantity,
      final List<OrderItemAddon> addons,
      final List<OrderItemVariation> variations,
      final String? specialInstructions}) = _$OrderItemImpl;
  const _OrderItem._() : super._();

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get menuItemId;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get image;
  @override
  double get price;
  @override
  int get quantity;
  @override
  List<OrderItemAddon> get addons;
  @override
  List<OrderItemVariation> get variations;
  @override
  String? get specialInstructions;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItemAddon _$OrderItemAddonFromJson(Map<String, dynamic> json) {
  return _OrderItemAddon.fromJson(json);
}

/// @nodoc
mixin _$OrderItemAddon {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this OrderItemAddon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemAddonCopyWith<OrderItemAddon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemAddonCopyWith<$Res> {
  factory $OrderItemAddonCopyWith(
          OrderItemAddon value, $Res Function(OrderItemAddon) then) =
      _$OrderItemAddonCopyWithImpl<$Res, OrderItemAddon>;
  @useResult
  $Res call({String name, String? nameAr, double price, int quantity});
}

/// @nodoc
class _$OrderItemAddonCopyWithImpl<$Res, $Val extends OrderItemAddon>
    implements $OrderItemAddonCopyWith<$Res> {
  _$OrderItemAddonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
    Object? quantity = null,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemAddonImplCopyWith<$Res>
    implements $OrderItemAddonCopyWith<$Res> {
  factory _$$OrderItemAddonImplCopyWith(_$OrderItemAddonImpl value,
          $Res Function(_$OrderItemAddonImpl) then) =
      __$$OrderItemAddonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? nameAr, double price, int quantity});
}

/// @nodoc
class __$$OrderItemAddonImplCopyWithImpl<$Res>
    extends _$OrderItemAddonCopyWithImpl<$Res, _$OrderItemAddonImpl>
    implements _$$OrderItemAddonImplCopyWith<$Res> {
  __$$OrderItemAddonImplCopyWithImpl(
      _$OrderItemAddonImpl _value, $Res Function(_$OrderItemAddonImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItemAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
    Object? quantity = null,
  }) {
    return _then(_$OrderItemAddonImpl(
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemAddonImpl implements _OrderItemAddon {
  const _$OrderItemAddonImpl(
      {required this.name,
      this.nameAr,
      required this.price,
      this.quantity = 1});

  factory _$OrderItemAddonImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemAddonImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final double price;
  @override
  @JsonKey()
  final int quantity;

  @override
  String toString() {
    return 'OrderItemAddon(name: $name, nameAr: $nameAr, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemAddonImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameAr, price, quantity);

  /// Create a copy of OrderItemAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemAddonImplCopyWith<_$OrderItemAddonImpl> get copyWith =>
      __$$OrderItemAddonImplCopyWithImpl<_$OrderItemAddonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemAddonImplToJson(
      this,
    );
  }
}

abstract class _OrderItemAddon implements OrderItemAddon {
  const factory _OrderItemAddon(
      {required final String name,
      final String? nameAr,
      required final double price,
      final int quantity}) = _$OrderItemAddonImpl;

  factory _OrderItemAddon.fromJson(Map<String, dynamic> json) =
      _$OrderItemAddonImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  double get price;
  @override
  int get quantity;

  /// Create a copy of OrderItemAddon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemAddonImplCopyWith<_$OrderItemAddonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItemVariation _$OrderItemVariationFromJson(Map<String, dynamic> json) {
  return _OrderItemVariation.fromJson(json);
}

/// @nodoc
mixin _$OrderItemVariation {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String get option => throw _privateConstructorUsedError;
  String? get optionAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this OrderItemVariation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemVariationCopyWith<OrderItemVariation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemVariationCopyWith<$Res> {
  factory $OrderItemVariationCopyWith(
          OrderItemVariation value, $Res Function(OrderItemVariation) then) =
      _$OrderItemVariationCopyWithImpl<$Res, OrderItemVariation>;
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      String option,
      String? optionAr,
      double price});
}

/// @nodoc
class _$OrderItemVariationCopyWithImpl<$Res, $Val extends OrderItemVariation>
    implements $OrderItemVariationCopyWith<$Res> {
  _$OrderItemVariationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? option = null,
    Object? optionAr = freezed,
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
      option: null == option
          ? _value.option
          : option // ignore: cast_nullable_to_non_nullable
              as String,
      optionAr: freezed == optionAr
          ? _value.optionAr
          : optionAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemVariationImplCopyWith<$Res>
    implements $OrderItemVariationCopyWith<$Res> {
  factory _$$OrderItemVariationImplCopyWith(_$OrderItemVariationImpl value,
          $Res Function(_$OrderItemVariationImpl) then) =
      __$$OrderItemVariationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? nameAr,
      String option,
      String? optionAr,
      double price});
}

/// @nodoc
class __$$OrderItemVariationImplCopyWithImpl<$Res>
    extends _$OrderItemVariationCopyWithImpl<$Res, _$OrderItemVariationImpl>
    implements _$$OrderItemVariationImplCopyWith<$Res> {
  __$$OrderItemVariationImplCopyWithImpl(_$OrderItemVariationImpl _value,
      $Res Function(_$OrderItemVariationImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItemVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? option = null,
    Object? optionAr = freezed,
    Object? price = null,
  }) {
    return _then(_$OrderItemVariationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: freezed == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      option: null == option
          ? _value.option
          : option // ignore: cast_nullable_to_non_nullable
              as String,
      optionAr: freezed == optionAr
          ? _value.optionAr
          : optionAr // ignore: cast_nullable_to_non_nullable
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
class _$OrderItemVariationImpl implements _OrderItemVariation {
  const _$OrderItemVariationImpl(
      {required this.name,
      this.nameAr,
      required this.option,
      this.optionAr,
      this.price = 0.0});

  factory _$OrderItemVariationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemVariationImplFromJson(json);

  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String option;
  @override
  final String? optionAr;
  @override
  @JsonKey()
  final double price;

  @override
  String toString() {
    return 'OrderItemVariation(name: $name, nameAr: $nameAr, option: $option, optionAr: $optionAr, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemVariationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.option, option) || other.option == option) &&
            (identical(other.optionAr, optionAr) ||
                other.optionAr == optionAr) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, nameAr, option, optionAr, price);

  /// Create a copy of OrderItemVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemVariationImplCopyWith<_$OrderItemVariationImpl> get copyWith =>
      __$$OrderItemVariationImplCopyWithImpl<_$OrderItemVariationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemVariationImplToJson(
      this,
    );
  }
}

abstract class _OrderItemVariation implements OrderItemVariation {
  const factory _OrderItemVariation(
      {required final String name,
      final String? nameAr,
      required final String option,
      final String? optionAr,
      final double price}) = _$OrderItemVariationImpl;

  factory _OrderItemVariation.fromJson(Map<String, dynamic> json) =
      _$OrderItemVariationImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String get option;
  @override
  String? get optionAr;
  @override
  double get price;

  /// Create a copy of OrderItemVariation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemVariationImplCopyWith<_$OrderItemVariationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderDeliveryAddress _$OrderDeliveryAddressFromJson(Map<String, dynamic> json) {
  return _OrderDeliveryAddress.fromJson(json);
}

/// @nodoc
mixin _$OrderDeliveryAddress {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;

  /// Serializes this OrderDeliveryAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderDeliveryAddressCopyWith<OrderDeliveryAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDeliveryAddressCopyWith<$Res> {
  factory $OrderDeliveryAddressCopyWith(OrderDeliveryAddress value,
          $Res Function(OrderDeliveryAddress) then) =
      _$OrderDeliveryAddressCopyWithImpl<$Res, OrderDeliveryAddress>;
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
class _$OrderDeliveryAddressCopyWithImpl<$Res,
        $Val extends OrderDeliveryAddress>
    implements $OrderDeliveryAddressCopyWith<$Res> {
  _$OrderDeliveryAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDeliveryAddress
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
abstract class _$$OrderDeliveryAddressImplCopyWith<$Res>
    implements $OrderDeliveryAddressCopyWith<$Res> {
  factory _$$OrderDeliveryAddressImplCopyWith(_$OrderDeliveryAddressImpl value,
          $Res Function(_$OrderDeliveryAddressImpl) then) =
      __$$OrderDeliveryAddressImplCopyWithImpl<$Res>;
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
class __$$OrderDeliveryAddressImplCopyWithImpl<$Res>
    extends _$OrderDeliveryAddressCopyWithImpl<$Res, _$OrderDeliveryAddressImpl>
    implements _$$OrderDeliveryAddressImplCopyWith<$Res> {
  __$$OrderDeliveryAddressImplCopyWithImpl(_$OrderDeliveryAddressImpl _value,
      $Res Function(_$OrderDeliveryAddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderDeliveryAddress
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
    return _then(_$OrderDeliveryAddressImpl(
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
class _$OrderDeliveryAddressImpl extends _OrderDeliveryAddress {
  const _$OrderDeliveryAddressImpl(
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

  factory _$OrderDeliveryAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderDeliveryAddressImplFromJson(json);

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
    return 'OrderDeliveryAddress(name: $name, address: $address, area: $area, city: $city, building: $building, floor: $floor, apartment: $apartment, landmark: $landmark, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDeliveryAddressImpl &&
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

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDeliveryAddressImplCopyWith<_$OrderDeliveryAddressImpl>
      get copyWith =>
          __$$OrderDeliveryAddressImplCopyWithImpl<_$OrderDeliveryAddressImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderDeliveryAddressImplToJson(
      this,
    );
  }
}

abstract class _OrderDeliveryAddress extends OrderDeliveryAddress {
  const factory _OrderDeliveryAddress(
      {required final String name,
      required final String address,
      required final String area,
      required final String city,
      final String? building,
      final String? floor,
      final String? apartment,
      final String? landmark,
      required final List<double> coordinates}) = _$OrderDeliveryAddressImpl;
  const _OrderDeliveryAddress._() : super._();

  factory _OrderDeliveryAddress.fromJson(Map<String, dynamic> json) =
      _$OrderDeliveryAddressImpl.fromJson;

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

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderDeliveryAddressImplCopyWith<_$OrderDeliveryAddressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

OrderDriver _$OrderDriverFromJson(Map<String, dynamic> json) {
  return _OrderDriver.fromJson(json);
}

/// @nodoc
mixin _$OrderDriver {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  List<double>? get currentLocation => throw _privateConstructorUsedError;

  /// Serializes this OrderDriver to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderDriver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderDriverCopyWith<OrderDriver> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDriverCopyWith<$Res> {
  factory $OrderDriverCopyWith(
          OrderDriver value, $Res Function(OrderDriver) then) =
      _$OrderDriverCopyWithImpl<$Res, OrderDriver>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? avatar,
      double? rating,
      List<double>? currentLocation});
}

/// @nodoc
class _$OrderDriverCopyWithImpl<$Res, $Val extends OrderDriver>
    implements $OrderDriverCopyWith<$Res> {
  _$OrderDriverCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDriver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatar = freezed,
    Object? rating = freezed,
    Object? currentLocation = freezed,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderDriverImplCopyWith<$Res>
    implements $OrderDriverCopyWith<$Res> {
  factory _$$OrderDriverImplCopyWith(
          _$OrderDriverImpl value, $Res Function(_$OrderDriverImpl) then) =
      __$$OrderDriverImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? avatar,
      double? rating,
      List<double>? currentLocation});
}

/// @nodoc
class __$$OrderDriverImplCopyWithImpl<$Res>
    extends _$OrderDriverCopyWithImpl<$Res, _$OrderDriverImpl>
    implements _$$OrderDriverImplCopyWith<$Res> {
  __$$OrderDriverImplCopyWithImpl(
      _$OrderDriverImpl _value, $Res Function(_$OrderDriverImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderDriver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatar = freezed,
    Object? rating = freezed,
    Object? currentLocation = freezed,
  }) {
    return _then(_$OrderDriverImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      currentLocation: freezed == currentLocation
          ? _value._currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as List<double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderDriverImpl extends _OrderDriver {
  const _$OrderDriverImpl(
      {required this.id,
      required this.name,
      this.phone,
      this.avatar,
      this.rating,
      final List<double>? currentLocation})
      : _currentLocation = currentLocation,
        super._();

  factory _$OrderDriverImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderDriverImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? avatar;
  @override
  final double? rating;
  final List<double>? _currentLocation;
  @override
  List<double>? get currentLocation {
    final value = _currentLocation;
    if (value == null) return null;
    if (_currentLocation is EqualUnmodifiableListView) return _currentLocation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrderDriver(id: $id, name: $name, phone: $phone, avatar: $avatar, rating: $rating, currentLocation: $currentLocation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDriverImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality()
                .equals(other._currentLocation, _currentLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phone, avatar, rating,
      const DeepCollectionEquality().hash(_currentLocation));

  /// Create a copy of OrderDriver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDriverImplCopyWith<_$OrderDriverImpl> get copyWith =>
      __$$OrderDriverImplCopyWithImpl<_$OrderDriverImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderDriverImplToJson(
      this,
    );
  }
}

abstract class _OrderDriver extends OrderDriver {
  const factory _OrderDriver(
      {required final String id,
      required final String name,
      final String? phone,
      final String? avatar,
      final double? rating,
      final List<double>? currentLocation}) = _$OrderDriverImpl;
  const _OrderDriver._() : super._();

  factory _OrderDriver.fromJson(Map<String, dynamic> json) =
      _$OrderDriverImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get avatar;
  @override
  double? get rating;
  @override
  List<double>? get currentLocation;

  /// Create a copy of OrderDriver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderDriverImplCopyWith<_$OrderDriverImpl> get copyWith =>
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
  String? get phone => throw _privateConstructorUsedError;
  List<double>? get location => throw _privateConstructorUsedError;

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
      String? phone,
      List<double>? location});
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
    Object? phone = freezed,
    Object? location = freezed,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
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
      String? phone,
      List<double>? location});
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
    Object? phone = freezed,
    Object? location = freezed,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as List<double>?,
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
      this.phone,
      final List<double>? location})
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
  final String? phone;
  final List<double>? _location;
  @override
  List<double>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableListView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrderRestaurant(id: $id, name: $name, nameAr: $nameAr, logo: $logo, phone: $phone, location: $location)';
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
            const DeepCollectionEquality().equals(other._location, _location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, nameAr, logo, phone,
      const DeepCollectionEquality().hash(_location));

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
      final String? phone,
      final List<double>? location}) = _$OrderRestaurantImpl;
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
  String? get phone;
  @override
  List<double>? get location;

  /// Create a copy of OrderRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderRestaurantImplCopyWith<_$OrderRestaurantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderStatusHistory _$OrderStatusHistoryFromJson(Map<String, dynamic> json) {
  return _OrderStatusHistory.fromJson(json);
}

/// @nodoc
mixin _$OrderStatusHistory {
  OrderStatus get status => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this OrderStatusHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStatusHistoryCopyWith<OrderStatusHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStatusHistoryCopyWith<$Res> {
  factory $OrderStatusHistoryCopyWith(
          OrderStatusHistory value, $Res Function(OrderStatusHistory) then) =
      _$OrderStatusHistoryCopyWithImpl<$Res, OrderStatusHistory>;
  @useResult
  $Res call({OrderStatus status, DateTime timestamp, String? note});
}

/// @nodoc
class _$OrderStatusHistoryCopyWithImpl<$Res, $Val extends OrderStatusHistory>
    implements $OrderStatusHistoryCopyWith<$Res> {
  _$OrderStatusHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? timestamp = null,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderStatusHistoryImplCopyWith<$Res>
    implements $OrderStatusHistoryCopyWith<$Res> {
  factory _$$OrderStatusHistoryImplCopyWith(_$OrderStatusHistoryImpl value,
          $Res Function(_$OrderStatusHistoryImpl) then) =
      __$$OrderStatusHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OrderStatus status, DateTime timestamp, String? note});
}

/// @nodoc
class __$$OrderStatusHistoryImplCopyWithImpl<$Res>
    extends _$OrderStatusHistoryCopyWithImpl<$Res, _$OrderStatusHistoryImpl>
    implements _$$OrderStatusHistoryImplCopyWith<$Res> {
  __$$OrderStatusHistoryImplCopyWithImpl(_$OrderStatusHistoryImpl _value,
      $Res Function(_$OrderStatusHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? timestamp = null,
    Object? note = freezed,
  }) {
    return _then(_$OrderStatusHistoryImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderStatusHistoryImpl implements _OrderStatusHistory {
  const _$OrderStatusHistoryImpl(
      {required this.status, required this.timestamp, this.note});

  factory _$OrderStatusHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderStatusHistoryImplFromJson(json);

  @override
  final OrderStatus status;
  @override
  final DateTime timestamp;
  @override
  final String? note;

  @override
  String toString() {
    return 'OrderStatusHistory(status: $status, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStatusHistoryImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, timestamp, note);

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStatusHistoryImplCopyWith<_$OrderStatusHistoryImpl> get copyWith =>
      __$$OrderStatusHistoryImplCopyWithImpl<_$OrderStatusHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderStatusHistoryImplToJson(
      this,
    );
  }
}

abstract class _OrderStatusHistory implements OrderStatusHistory {
  const factory _OrderStatusHistory(
      {required final OrderStatus status,
      required final DateTime timestamp,
      final String? note}) = _$OrderStatusHistoryImpl;

  factory _OrderStatusHistory.fromJson(Map<String, dynamic> json) =
      _$OrderStatusHistoryImpl.fromJson;

  @override
  OrderStatus get status;
  @override
  DateTime get timestamp;
  @override
  String? get note;

  /// Create a copy of OrderStatusHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStatusHistoryImplCopyWith<_$OrderStatusHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  OrderRestaurant get restaurant => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  OrderDeliveryAddress get deliveryAddress =>
      throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  OrderPaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  OrderDriver? get driver => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime? get estimatedDeliveryTime => throw _privateConstructorUsedError;
  List<OrderStatusHistory> get statusHistory =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      List<OrderItem> items,
      OrderDeliveryAddress deliveryAddress,
      OrderStatus status,
      OrderPaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      double subtotal,
      double deliveryFee,
      double discount,
      double total,
      OrderDriver? driver,
      String? notes,
      String? cancellationReason,
      DateTime? estimatedDeliveryTime,
      List<OrderStatusHistory> statusHistory,
      DateTime createdAt,
      DateTime? updatedAt});

  $OrderRestaurantCopyWith<$Res> get restaurant;
  $OrderDeliveryAddressCopyWith<$Res> get deliveryAddress;
  $OrderDriverCopyWith<$Res>? get driver;
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? total = null,
    Object? driver = freezed,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? statusHistory = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderDeliveryAddress,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as OrderPaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
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
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as OrderDriver?,
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
      statusHistory: null == statusHistory
          ? _value.statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<OrderStatusHistory>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderRestaurantCopyWith<$Res> get restaurant {
    return $OrderRestaurantCopyWith<$Res>(_value.restaurant, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderDeliveryAddressCopyWith<$Res> get deliveryAddress {
    return $OrderDeliveryAddressCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderDriverCopyWith<$Res>? get driver {
    if (_value.driver == null) {
      return null;
    }

    return $OrderDriverCopyWith<$Res>(_value.driver!, (value) {
      return _then(_value.copyWith(driver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String orderNumber,
      OrderRestaurant restaurant,
      List<OrderItem> items,
      OrderDeliveryAddress deliveryAddress,
      OrderStatus status,
      OrderPaymentMethod paymentMethod,
      PaymentStatus paymentStatus,
      double subtotal,
      double deliveryFee,
      double discount,
      double total,
      OrderDriver? driver,
      String? notes,
      String? cancellationReason,
      DateTime? estimatedDeliveryTime,
      List<OrderStatusHistory> statusHistory,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $OrderRestaurantCopyWith<$Res> get restaurant;
  @override
  $OrderDeliveryAddressCopyWith<$Res> get deliveryAddress;
  @override
  $OrderDriverCopyWith<$Res>? get driver;
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? restaurant = null,
    Object? items = null,
    Object? deliveryAddress = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? total = null,
    Object? driver = freezed,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? statusHistory = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$OrderImpl(
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
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as OrderDeliveryAddress,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as OrderPaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
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
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as OrderDriver?,
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
      statusHistory: null == statusHistory
          ? _value._statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<OrderStatusHistory>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl extends _Order {
  const _$OrderImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.orderNumber,
      required this.restaurant,
      required final List<OrderItem> items,
      required this.deliveryAddress,
      required this.status,
      required this.paymentMethod,
      required this.paymentStatus,
      required this.subtotal,
      required this.deliveryFee,
      this.discount = 0.0,
      required this.total,
      this.driver,
      this.notes,
      this.cancellationReason,
      this.estimatedDeliveryTime,
      final List<OrderStatusHistory> statusHistory = const [],
      required this.createdAt,
      this.updatedAt})
      : _items = items,
        _statusHistory = statusHistory,
        super._();

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String orderNumber;
  @override
  final OrderRestaurant restaurant;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final OrderDeliveryAddress deliveryAddress;
  @override
  final OrderStatus status;
  @override
  final OrderPaymentMethod paymentMethod;
  @override
  final PaymentStatus paymentStatus;
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
  final OrderDriver? driver;
  @override
  final String? notes;
  @override
  final String? cancellationReason;
  @override
  final DateTime? estimatedDeliveryTime;
  final List<OrderStatusHistory> _statusHistory;
  @override
  @JsonKey()
  List<OrderStatusHistory> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, restaurant: $restaurant, items: $items, deliveryAddress: $deliveryAddress, status: $status, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, total: $total, driver: $driver, notes: $notes, cancellationReason: $cancellationReason, estimatedDeliveryTime: $estimatedDeliveryTime, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            const DeepCollectionEquality()
                .equals(other._statusHistory, _statusHistory) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        orderNumber,
        restaurant,
        const DeepCollectionEquality().hash(_items),
        deliveryAddress,
        status,
        paymentMethod,
        paymentStatus,
        subtotal,
        deliveryFee,
        discount,
        total,
        driver,
        notes,
        cancellationReason,
        estimatedDeliveryTime,
        const DeepCollectionEquality().hash(_statusHistory),
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(
      this,
    );
  }
}

abstract class _Order extends Order {
  const factory _Order(
      {@JsonKey(name: '_id') required final String id,
      required final String orderNumber,
      required final OrderRestaurant restaurant,
      required final List<OrderItem> items,
      required final OrderDeliveryAddress deliveryAddress,
      required final OrderStatus status,
      required final OrderPaymentMethod paymentMethod,
      required final PaymentStatus paymentStatus,
      required final double subtotal,
      required final double deliveryFee,
      final double discount,
      required final double total,
      final OrderDriver? driver,
      final String? notes,
      final String? cancellationReason,
      final DateTime? estimatedDeliveryTime,
      final List<OrderStatusHistory> statusHistory,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$OrderImpl;
  const _Order._() : super._();

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get orderNumber;
  @override
  OrderRestaurant get restaurant;
  @override
  List<OrderItem> get items;
  @override
  OrderDeliveryAddress get deliveryAddress;
  @override
  OrderStatus get status;
  @override
  OrderPaymentMethod get paymentMethod;
  @override
  PaymentStatus get paymentStatus;
  @override
  double get subtotal;
  @override
  double get deliveryFee;
  @override
  double get discount;
  @override
  double get total;
  @override
  OrderDriver? get driver;
  @override
  String? get notes;
  @override
  String? get cancellationReason;
  @override
  DateTime? get estimatedDeliveryTime;
  @override
  List<OrderStatusHistory> get statusHistory;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
