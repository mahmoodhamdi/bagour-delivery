// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SelectedAddon _$SelectedAddonFromJson(Map<String, dynamic> json) {
  return _SelectedAddon.fromJson(json);
}

/// @nodoc
mixin _$SelectedAddon {
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this SelectedAddon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectedAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedAddonCopyWith<SelectedAddon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedAddonCopyWith<$Res> {
  factory $SelectedAddonCopyWith(
          SelectedAddon value, $Res Function(SelectedAddon) then) =
      _$SelectedAddonCopyWithImpl<$Res, SelectedAddon>;
  @useResult
  $Res call({String name, String? nameAr, double price, int quantity});
}

/// @nodoc
class _$SelectedAddonCopyWithImpl<$Res, $Val extends SelectedAddon>
    implements $SelectedAddonCopyWith<$Res> {
  _$SelectedAddonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedAddon
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
abstract class _$$SelectedAddonImplCopyWith<$Res>
    implements $SelectedAddonCopyWith<$Res> {
  factory _$$SelectedAddonImplCopyWith(
          _$SelectedAddonImpl value, $Res Function(_$SelectedAddonImpl) then) =
      __$$SelectedAddonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? nameAr, double price, int quantity});
}

/// @nodoc
class __$$SelectedAddonImplCopyWithImpl<$Res>
    extends _$SelectedAddonCopyWithImpl<$Res, _$SelectedAddonImpl>
    implements _$$SelectedAddonImplCopyWith<$Res> {
  __$$SelectedAddonImplCopyWithImpl(
      _$SelectedAddonImpl _value, $Res Function(_$SelectedAddonImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelectedAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameAr = freezed,
    Object? price = null,
    Object? quantity = null,
  }) {
    return _then(_$SelectedAddonImpl(
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
class _$SelectedAddonImpl extends _SelectedAddon {
  const _$SelectedAddonImpl(
      {required this.name, this.nameAr, required this.price, this.quantity = 1})
      : super._();

  factory _$SelectedAddonImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedAddonImplFromJson(json);

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
    return 'SelectedAddon(name: $name, nameAr: $nameAr, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedAddonImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameAr, price, quantity);

  /// Create a copy of SelectedAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedAddonImplCopyWith<_$SelectedAddonImpl> get copyWith =>
      __$$SelectedAddonImplCopyWithImpl<_$SelectedAddonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedAddonImplToJson(
      this,
    );
  }
}

abstract class _SelectedAddon extends SelectedAddon {
  const factory _SelectedAddon(
      {required final String name,
      final String? nameAr,
      required final double price,
      final int quantity}) = _$SelectedAddonImpl;
  const _SelectedAddon._() : super._();

  factory _SelectedAddon.fromJson(Map<String, dynamic> json) =
      _$SelectedAddonImpl.fromJson;

  @override
  String get name;
  @override
  String? get nameAr;
  @override
  double get price;
  @override
  int get quantity;

  /// Create a copy of SelectedAddon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedAddonImplCopyWith<_$SelectedAddonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SelectedVariation _$SelectedVariationFromJson(Map<String, dynamic> json) {
  return _SelectedVariation.fromJson(json);
}

/// @nodoc
mixin _$SelectedVariation {
  String get variationName => throw _privateConstructorUsedError;
  String? get variationNameAr => throw _privateConstructorUsedError;
  String get optionName => throw _privateConstructorUsedError;
  String? get optionNameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this SelectedVariation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectedVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedVariationCopyWith<SelectedVariation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedVariationCopyWith<$Res> {
  factory $SelectedVariationCopyWith(
          SelectedVariation value, $Res Function(SelectedVariation) then) =
      _$SelectedVariationCopyWithImpl<$Res, SelectedVariation>;
  @useResult
  $Res call(
      {String variationName,
      String? variationNameAr,
      String optionName,
      String? optionNameAr,
      double price});
}

/// @nodoc
class _$SelectedVariationCopyWithImpl<$Res, $Val extends SelectedVariation>
    implements $SelectedVariationCopyWith<$Res> {
  _$SelectedVariationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variationName = null,
    Object? variationNameAr = freezed,
    Object? optionName = null,
    Object? optionNameAr = freezed,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      variationName: null == variationName
          ? _value.variationName
          : variationName // ignore: cast_nullable_to_non_nullable
              as String,
      variationNameAr: freezed == variationNameAr
          ? _value.variationNameAr
          : variationNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      optionName: null == optionName
          ? _value.optionName
          : optionName // ignore: cast_nullable_to_non_nullable
              as String,
      optionNameAr: freezed == optionNameAr
          ? _value.optionNameAr
          : optionNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectedVariationImplCopyWith<$Res>
    implements $SelectedVariationCopyWith<$Res> {
  factory _$$SelectedVariationImplCopyWith(_$SelectedVariationImpl value,
          $Res Function(_$SelectedVariationImpl) then) =
      __$$SelectedVariationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String variationName,
      String? variationNameAr,
      String optionName,
      String? optionNameAr,
      double price});
}

/// @nodoc
class __$$SelectedVariationImplCopyWithImpl<$Res>
    extends _$SelectedVariationCopyWithImpl<$Res, _$SelectedVariationImpl>
    implements _$$SelectedVariationImplCopyWith<$Res> {
  __$$SelectedVariationImplCopyWithImpl(_$SelectedVariationImpl _value,
      $Res Function(_$SelectedVariationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelectedVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variationName = null,
    Object? variationNameAr = freezed,
    Object? optionName = null,
    Object? optionNameAr = freezed,
    Object? price = null,
  }) {
    return _then(_$SelectedVariationImpl(
      variationName: null == variationName
          ? _value.variationName
          : variationName // ignore: cast_nullable_to_non_nullable
              as String,
      variationNameAr: freezed == variationNameAr
          ? _value.variationNameAr
          : variationNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      optionName: null == optionName
          ? _value.optionName
          : optionName // ignore: cast_nullable_to_non_nullable
              as String,
      optionNameAr: freezed == optionNameAr
          ? _value.optionNameAr
          : optionNameAr // ignore: cast_nullable_to_non_nullable
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
class _$SelectedVariationImpl implements _SelectedVariation {
  const _$SelectedVariationImpl(
      {required this.variationName,
      this.variationNameAr,
      required this.optionName,
      this.optionNameAr,
      this.price = 0.0});

  factory _$SelectedVariationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedVariationImplFromJson(json);

  @override
  final String variationName;
  @override
  final String? variationNameAr;
  @override
  final String optionName;
  @override
  final String? optionNameAr;
  @override
  @JsonKey()
  final double price;

  @override
  String toString() {
    return 'SelectedVariation(variationName: $variationName, variationNameAr: $variationNameAr, optionName: $optionName, optionNameAr: $optionNameAr, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedVariationImpl &&
            (identical(other.variationName, variationName) ||
                other.variationName == variationName) &&
            (identical(other.variationNameAr, variationNameAr) ||
                other.variationNameAr == variationNameAr) &&
            (identical(other.optionName, optionName) ||
                other.optionName == optionName) &&
            (identical(other.optionNameAr, optionNameAr) ||
                other.optionNameAr == optionNameAr) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, variationName, variationNameAr,
      optionName, optionNameAr, price);

  /// Create a copy of SelectedVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedVariationImplCopyWith<_$SelectedVariationImpl> get copyWith =>
      __$$SelectedVariationImplCopyWithImpl<_$SelectedVariationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedVariationImplToJson(
      this,
    );
  }
}

abstract class _SelectedVariation implements SelectedVariation {
  const factory _SelectedVariation(
      {required final String variationName,
      final String? variationNameAr,
      required final String optionName,
      final String? optionNameAr,
      final double price}) = _$SelectedVariationImpl;

  factory _SelectedVariation.fromJson(Map<String, dynamic> json) =
      _$SelectedVariationImpl.fromJson;

  @override
  String get variationName;
  @override
  String? get variationNameAr;
  @override
  String get optionName;
  @override
  String? get optionNameAr;
  @override
  double get price;

  /// Create a copy of SelectedVariation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedVariationImplCopyWith<_$SelectedVariationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartItem _$CartItemFromJson(Map<String, dynamic> json) {
  return _CartItem.fromJson(json);
}

/// @nodoc
mixin _$CartItem {
  String get id =>
      throw _privateConstructorUsedError; // Unique ID for this cart item
  String get menuItemId => throw _privateConstructorUsedError;
  String get restaurantId => throw _privateConstructorUsedError;
  String get restaurantName => throw _privateConstructorUsedError;
  String? get restaurantNameAr => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  List<SelectedAddon> get addons => throw _privateConstructorUsedError;
  List<SelectedVariation> get variations => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call(
      {String id,
      String menuItemId,
      String restaurantId,
      String restaurantName,
      String? restaurantNameAr,
      String name,
      String? nameAr,
      String? image,
      double basePrice,
      int quantity,
      List<SelectedAddon> addons,
      List<SelectedVariation> variations,
      String? specialInstructions});
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? restaurantId = null,
    Object? restaurantName = null,
    Object? restaurantNameAr = freezed,
    Object? name = null,
    Object? nameAr = freezed,
    Object? image = freezed,
    Object? basePrice = null,
    Object? quantity = null,
    Object? addons = null,
    Object? variations = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantNameAr: freezed == restaurantNameAr
          ? _value.restaurantNameAr
          : restaurantNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
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
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      addons: null == addons
          ? _value.addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<SelectedAddon>,
      variations: null == variations
          ? _value.variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<SelectedVariation>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
          _$CartItemImpl value, $Res Function(_$CartItemImpl) then) =
      __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String menuItemId,
      String restaurantId,
      String restaurantName,
      String? restaurantNameAr,
      String name,
      String? nameAr,
      String? image,
      double basePrice,
      int quantity,
      List<SelectedAddon> addons,
      List<SelectedVariation> variations,
      String? specialInstructions});
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
      _$CartItemImpl _value, $Res Function(_$CartItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? restaurantId = null,
    Object? restaurantName = null,
    Object? restaurantNameAr = freezed,
    Object? name = null,
    Object? nameAr = freezed,
    Object? image = freezed,
    Object? basePrice = null,
    Object? quantity = null,
    Object? addons = null,
    Object? variations = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_$CartItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantNameAr: freezed == restaurantNameAr
          ? _value.restaurantNameAr
          : restaurantNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
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
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      addons: null == addons
          ? _value._addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<SelectedAddon>,
      variations: null == variations
          ? _value._variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<SelectedVariation>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl(
      {required this.id,
      required this.menuItemId,
      required this.restaurantId,
      required this.restaurantName,
      this.restaurantNameAr,
      required this.name,
      this.nameAr,
      this.image,
      required this.basePrice,
      this.quantity = 1,
      final List<SelectedAddon> addons = const [],
      final List<SelectedVariation> variations = const [],
      this.specialInstructions})
      : _addons = addons,
        _variations = variations,
        super._();

  factory _$CartItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemImplFromJson(json);

  @override
  final String id;
// Unique ID for this cart item
  @override
  final String menuItemId;
  @override
  final String restaurantId;
  @override
  final String restaurantName;
  @override
  final String? restaurantNameAr;
  @override
  final String name;
  @override
  final String? nameAr;
  @override
  final String? image;
  @override
  final double basePrice;
  @override
  @JsonKey()
  final int quantity;
  final List<SelectedAddon> _addons;
  @override
  @JsonKey()
  List<SelectedAddon> get addons {
    if (_addons is EqualUnmodifiableListView) return _addons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addons);
  }

  final List<SelectedVariation> _variations;
  @override
  @JsonKey()
  List<SelectedVariation> get variations {
    if (_variations is EqualUnmodifiableListView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variations);
  }

  @override
  final String? specialInstructions;

  @override
  String toString() {
    return 'CartItem(id: $id, menuItemId: $menuItemId, restaurantId: $restaurantId, restaurantName: $restaurantName, restaurantNameAr: $restaurantNameAr, name: $name, nameAr: $nameAr, image: $image, basePrice: $basePrice, quantity: $quantity, addons: $addons, variations: $variations, specialInstructions: $specialInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.restaurantNameAr, restaurantNameAr) ||
                other.restaurantNameAr == restaurantNameAr) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
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
      id,
      menuItemId,
      restaurantId,
      restaurantName,
      restaurantNameAr,
      name,
      nameAr,
      image,
      basePrice,
      quantity,
      const DeepCollectionEquality().hash(_addons),
      const DeepCollectionEquality().hash(_variations),
      specialInstructions);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemImplToJson(
      this,
    );
  }
}

abstract class _CartItem extends CartItem {
  const factory _CartItem(
      {required final String id,
      required final String menuItemId,
      required final String restaurantId,
      required final String restaurantName,
      final String? restaurantNameAr,
      required final String name,
      final String? nameAr,
      final String? image,
      required final double basePrice,
      final int quantity,
      final List<SelectedAddon> addons,
      final List<SelectedVariation> variations,
      final String? specialInstructions}) = _$CartItemImpl;
  const _CartItem._() : super._();

  factory _CartItem.fromJson(Map<String, dynamic> json) =
      _$CartItemImpl.fromJson;

  @override
  String get id; // Unique ID for this cart item
  @override
  String get menuItemId;
  @override
  String get restaurantId;
  @override
  String get restaurantName;
  @override
  String? get restaurantNameAr;
  @override
  String get name;
  @override
  String? get nameAr;
  @override
  String? get image;
  @override
  double get basePrice;
  @override
  int get quantity;
  @override
  List<SelectedAddon> get addons;
  @override
  List<SelectedVariation> get variations;
  @override
  String? get specialInstructions;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Cart _$CartFromJson(Map<String, dynamic> json) {
  return _Cart.fromJson(json);
}

/// @nodoc
mixin _$Cart {
  List<CartItem> get items => throw _privateConstructorUsedError;
  String? get restaurantId => throw _privateConstructorUsedError;
  String? get restaurantName => throw _privateConstructorUsedError;
  String? get restaurantNameAr => throw _privateConstructorUsedError;
  double? get minimumOrder => throw _privateConstructorUsedError;
  double? get deliveryFee => throw _privateConstructorUsedError;
  double? get freeDeliveryAbove => throw _privateConstructorUsedError;

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartCopyWith<Cart> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartCopyWith<$Res> {
  factory $CartCopyWith(Cart value, $Res Function(Cart) then) =
      _$CartCopyWithImpl<$Res, Cart>;
  @useResult
  $Res call(
      {List<CartItem> items,
      String? restaurantId,
      String? restaurantName,
      String? restaurantNameAr,
      double? minimumOrder,
      double? deliveryFee,
      double? freeDeliveryAbove});
}

/// @nodoc
class _$CartCopyWithImpl<$Res, $Val extends Cart>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? restaurantId = freezed,
    Object? restaurantName = freezed,
    Object? restaurantNameAr = freezed,
    Object? minimumOrder = freezed,
    Object? deliveryFee = freezed,
    Object? freeDeliveryAbove = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      restaurantId: freezed == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantName: freezed == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantNameAr: freezed == restaurantNameAr
          ? _value.restaurantNameAr
          : restaurantNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumOrder: freezed == minimumOrder
          ? _value.minimumOrder
          : minimumOrder // ignore: cast_nullable_to_non_nullable
              as double?,
      deliveryFee: freezed == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double?,
      freeDeliveryAbove: freezed == freeDeliveryAbove
          ? _value.freeDeliveryAbove
          : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartImplCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$$CartImplCopyWith(
          _$CartImpl value, $Res Function(_$CartImpl) then) =
      __$$CartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CartItem> items,
      String? restaurantId,
      String? restaurantName,
      String? restaurantNameAr,
      double? minimumOrder,
      double? deliveryFee,
      double? freeDeliveryAbove});
}

/// @nodoc
class __$$CartImplCopyWithImpl<$Res>
    extends _$CartCopyWithImpl<$Res, _$CartImpl>
    implements _$$CartImplCopyWith<$Res> {
  __$$CartImplCopyWithImpl(_$CartImpl _value, $Res Function(_$CartImpl) _then)
      : super(_value, _then);

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? restaurantId = freezed,
    Object? restaurantName = freezed,
    Object? restaurantNameAr = freezed,
    Object? minimumOrder = freezed,
    Object? deliveryFee = freezed,
    Object? freeDeliveryAbove = freezed,
  }) {
    return _then(_$CartImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      restaurantId: freezed == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantName: freezed == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantNameAr: freezed == restaurantNameAr
          ? _value.restaurantNameAr
          : restaurantNameAr // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumOrder: freezed == minimumOrder
          ? _value.minimumOrder
          : minimumOrder // ignore: cast_nullable_to_non_nullable
              as double?,
      deliveryFee: freezed == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double?,
      freeDeliveryAbove: freezed == freeDeliveryAbove
          ? _value.freeDeliveryAbove
          : freeDeliveryAbove // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartImpl extends _Cart {
  const _$CartImpl(
      {final List<CartItem> items = const [],
      this.restaurantId,
      this.restaurantName,
      this.restaurantNameAr,
      this.minimumOrder,
      this.deliveryFee,
      this.freeDeliveryAbove})
      : _items = items,
        super._();

  factory _$CartImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartImplFromJson(json);

  final List<CartItem> _items;
  @override
  @JsonKey()
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? restaurantId;
  @override
  final String? restaurantName;
  @override
  final String? restaurantNameAr;
  @override
  final double? minimumOrder;
  @override
  final double? deliveryFee;
  @override
  final double? freeDeliveryAbove;

  @override
  String toString() {
    return 'Cart(items: $items, restaurantId: $restaurantId, restaurantName: $restaurantName, restaurantNameAr: $restaurantNameAr, minimumOrder: $minimumOrder, deliveryFee: $deliveryFee, freeDeliveryAbove: $freeDeliveryAbove)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.restaurantNameAr, restaurantNameAr) ||
                other.restaurantNameAr == restaurantNameAr) &&
            (identical(other.minimumOrder, minimumOrder) ||
                other.minimumOrder == minimumOrder) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.freeDeliveryAbove, freeDeliveryAbove) ||
                other.freeDeliveryAbove == freeDeliveryAbove));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      restaurantId,
      restaurantName,
      restaurantNameAr,
      minimumOrder,
      deliveryFee,
      freeDeliveryAbove);

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      __$$CartImplCopyWithImpl<_$CartImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartImplToJson(
      this,
    );
  }
}

abstract class _Cart extends Cart {
  const factory _Cart(
      {final List<CartItem> items,
      final String? restaurantId,
      final String? restaurantName,
      final String? restaurantNameAr,
      final double? minimumOrder,
      final double? deliveryFee,
      final double? freeDeliveryAbove}) = _$CartImpl;
  const _Cart._() : super._();

  factory _Cart.fromJson(Map<String, dynamic> json) = _$CartImpl.fromJson;

  @override
  List<CartItem> get items;
  @override
  String? get restaurantId;
  @override
  String? get restaurantName;
  @override
  String? get restaurantNameAr;
  @override
  double? get minimumOrder;
  @override
  double? get deliveryFee;
  @override
  double? get freeDeliveryAbove;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
