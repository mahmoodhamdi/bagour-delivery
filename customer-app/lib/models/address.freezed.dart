// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AddressLocation _$AddressLocationFromJson(Map<String, dynamic> json) {
  return _AddressLocation.fromJson(json);
}

/// @nodoc
mixin _$AddressLocation {
  String get type => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;

  /// Serializes this AddressLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressLocationCopyWith<AddressLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressLocationCopyWith<$Res> {
  factory $AddressLocationCopyWith(
          AddressLocation value, $Res Function(AddressLocation) then) =
      _$AddressLocationCopyWithImpl<$Res, AddressLocation>;
  @useResult
  $Res call({String type, List<double> coordinates});
}

/// @nodoc
class _$AddressLocationCopyWithImpl<$Res, $Val extends AddressLocation>
    implements $AddressLocationCopyWith<$Res> {
  _$AddressLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressLocation
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
abstract class _$$AddressLocationImplCopyWith<$Res>
    implements $AddressLocationCopyWith<$Res> {
  factory _$$AddressLocationImplCopyWith(_$AddressLocationImpl value,
          $Res Function(_$AddressLocationImpl) then) =
      __$$AddressLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, List<double> coordinates});
}

/// @nodoc
class __$$AddressLocationImplCopyWithImpl<$Res>
    extends _$AddressLocationCopyWithImpl<$Res, _$AddressLocationImpl>
    implements _$$AddressLocationImplCopyWith<$Res> {
  __$$AddressLocationImplCopyWithImpl(
      _$AddressLocationImpl _value, $Res Function(_$AddressLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AddressLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? coordinates = null,
  }) {
    return _then(_$AddressLocationImpl(
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
class _$AddressLocationImpl extends _AddressLocation {
  const _$AddressLocationImpl(
      {this.type = 'Point', required final List<double> coordinates})
      : _coordinates = coordinates,
        super._();

  factory _$AddressLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressLocationImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  final List<double> _coordinates;
  @override
  List<double> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  String toString() {
    return 'AddressLocation(type: $type, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressLocationImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_coordinates));

  /// Create a copy of AddressLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressLocationImplCopyWith<_$AddressLocationImpl> get copyWith =>
      __$$AddressLocationImplCopyWithImpl<_$AddressLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressLocationImplToJson(
      this,
    );
  }
}

abstract class _AddressLocation extends AddressLocation {
  const factory _AddressLocation(
      {final String type,
      required final List<double> coordinates}) = _$AddressLocationImpl;
  const _AddressLocation._() : super._();

  factory _AddressLocation.fromJson(Map<String, dynamic> json) =
      _$AddressLocationImpl.fromJson;

  @override
  String get type;
  @override
  List<double> get coordinates;

  /// Create a copy of AddressLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressLocationImplCopyWith<_$AddressLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  AddressLabel get label => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  AddressLocation get location => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      AddressLabel label,
      String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      AddressLocation location,
      bool isDefault});

  $AddressLocationCopyWith<$Res> get location;
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? label = null,
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? location = null,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as AddressLabel,
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as AddressLocation,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressLocationCopyWith<$Res> get location {
    return $AddressLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
          _$AddressImpl value, $Res Function(_$AddressImpl) then) =
      __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      AddressLabel label,
      String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      AddressLocation location,
      bool isDefault});

  @override
  $AddressLocationCopyWith<$Res> get location;
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
      _$AddressImpl _value, $Res Function(_$AddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? label = null,
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? location = null,
    Object? isDefault = null,
  }) {
    return _then(_$AddressImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as AddressLabel,
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as AddressLocation,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none)
class _$AddressImpl extends _Address {
  const _$AddressImpl(
      {@JsonKey(name: '_id') this.id,
      required this.label,
      required this.name,
      required this.address,
      required this.area,
      this.city = 'الباجور',
      this.building,
      this.floor,
      this.apartment,
      this.landmark,
      required this.location,
      this.isDefault = false})
      : super._();

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final AddressLabel label;
  @override
  final String name;
  @override
  final String address;
  @override
  final String area;
  @override
  @JsonKey()
  final String city;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final String? apartment;
  @override
  final String? landmark;
  @override
  final AddressLocation location;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'Address(id: $id, label: $label, name: $name, address: $address, area: $area, city: $city, building: $building, floor: $floor, apartment: $apartment, landmark: $landmark, location: $location, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
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
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, name, address, area,
      city, building, floor, apartment, landmark, location, isDefault);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(
      this,
    );
  }
}

abstract class _Address extends Address {
  const factory _Address(
      {@JsonKey(name: '_id') final String? id,
      required final AddressLabel label,
      required final String name,
      required final String address,
      required final String area,
      final String city,
      final String? building,
      final String? floor,
      final String? apartment,
      final String? landmark,
      required final AddressLocation location,
      final bool isDefault}) = _$AddressImpl;
  const _Address._() : super._();

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  AddressLabel get label;
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
  AddressLocation get location;
  @override
  bool get isDefault;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddressInput _$AddressInputFromJson(Map<String, dynamic> json) {
  return _AddressInput.fromJson(json);
}

/// @nodoc
mixin _$AddressInput {
  AddressLabel get label => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this AddressInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressInputCopyWith<AddressInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressInputCopyWith<$Res> {
  factory $AddressInputCopyWith(
          AddressInput value, $Res Function(AddressInput) then) =
      _$AddressInputCopyWithImpl<$Res, AddressInput>;
  @useResult
  $Res call(
      {AddressLabel label,
      String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      List<double> coordinates,
      bool isDefault});
}

/// @nodoc
class _$AddressInputCopyWithImpl<$Res, $Val extends AddressInput>
    implements $AddressInputCopyWith<$Res> {
  _$AddressInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? coordinates = null,
    Object? isDefault = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as AddressLabel,
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
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddressInputImplCopyWith<$Res>
    implements $AddressInputCopyWith<$Res> {
  factory _$$AddressInputImplCopyWith(
          _$AddressInputImpl value, $Res Function(_$AddressInputImpl) then) =
      __$$AddressInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AddressLabel label,
      String name,
      String address,
      String area,
      String city,
      String? building,
      String? floor,
      String? apartment,
      String? landmark,
      List<double> coordinates,
      bool isDefault});
}

/// @nodoc
class __$$AddressInputImplCopyWithImpl<$Res>
    extends _$AddressInputCopyWithImpl<$Res, _$AddressInputImpl>
    implements _$$AddressInputImplCopyWith<$Res> {
  __$$AddressInputImplCopyWithImpl(
      _$AddressInputImpl _value, $Res Function(_$AddressInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of AddressInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? name = null,
    Object? address = null,
    Object? area = null,
    Object? city = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? landmark = freezed,
    Object? coordinates = null,
    Object? isDefault = null,
  }) {
    return _then(_$AddressInputImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as AddressLabel,
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
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressInputImpl extends _AddressInput {
  const _$AddressInputImpl(
      {required this.label,
      required this.name,
      required this.address,
      required this.area,
      this.city = 'الباجور',
      this.building,
      this.floor,
      this.apartment,
      this.landmark,
      required final List<double> coordinates,
      this.isDefault = false})
      : _coordinates = coordinates,
        super._();

  factory _$AddressInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressInputImplFromJson(json);

  @override
  final AddressLabel label;
  @override
  final String name;
  @override
  final String address;
  @override
  final String area;
  @override
  @JsonKey()
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
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'AddressInput(label: $label, name: $name, address: $address, area: $area, city: $city, building: $building, floor: $floor, apartment: $apartment, landmark: $landmark, coordinates: $coordinates, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressInputImpl &&
            (identical(other.label, label) || other.label == label) &&
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
                .equals(other._coordinates, _coordinates) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      label,
      name,
      address,
      area,
      city,
      building,
      floor,
      apartment,
      landmark,
      const DeepCollectionEquality().hash(_coordinates),
      isDefault);

  /// Create a copy of AddressInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressInputImplCopyWith<_$AddressInputImpl> get copyWith =>
      __$$AddressInputImplCopyWithImpl<_$AddressInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressInputImplToJson(
      this,
    );
  }
}

abstract class _AddressInput extends AddressInput {
  const factory _AddressInput(
      {required final AddressLabel label,
      required final String name,
      required final String address,
      required final String area,
      final String city,
      final String? building,
      final String? floor,
      final String? apartment,
      final String? landmark,
      required final List<double> coordinates,
      final bool isDefault}) = _$AddressInputImpl;
  const _AddressInput._() : super._();

  factory _AddressInput.fromJson(Map<String, dynamic> json) =
      _$AddressInputImpl.fromJson;

  @override
  AddressLabel get label;
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
  @override
  bool get isDefault;

  /// Create a copy of AddressInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressInputImplCopyWith<_$AddressInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
