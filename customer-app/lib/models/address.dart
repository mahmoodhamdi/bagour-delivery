import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

enum AddressLabel {
  @JsonValue('home')
  home,
  @JsonValue('work')
  work,
  @JsonValue('other')
  other,
}

/// Location point for address
@freezed
class AddressLocation with _$AddressLocation {
  const factory AddressLocation({
    @Default('Point') String type,
    required List<double> coordinates, // [lng, lat]
  }) = _AddressLocation;

  factory AddressLocation.fromJson(Map<String, dynamic> json) =>
      _$AddressLocationFromJson(json);

  const AddressLocation._();

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0;

  static AddressLocation fromLatLng(double lat, double lng) {
    return AddressLocation(coordinates: [lng, lat]);
  }
}

/// Delivery address model
@freezed
class Address with _$Address {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory Address({
    @JsonKey(name: '_id') String? id,
    required AddressLabel label,
    required String name,
    required String address,
    required String area,
    @Default('الباجور') String city,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    required AddressLocation location,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  const Address._();

  /// Get label display name in Arabic
  String get labelDisplayName {
    switch (label) {
      case AddressLabel.home:
        return 'المنزل';
      case AddressLabel.work:
        return 'العمل';
      case AddressLabel.other:
        return 'آخر';
    }
  }

  /// Get label icon
  String get labelIcon {
    switch (label) {
      case AddressLabel.home:
        return '🏠';
      case AddressLabel.work:
        return '🏢';
      case AddressLabel.other:
        return '📍';
    }
  }

  /// Get full formatted address
  String get fullAddress {
    final parts = <String>[address];
    if (building != null && building!.isNotEmpty) {
      parts.add('مبنى $building');
    }
    if (floor != null && floor!.isNotEmpty) {
      parts.add('الطابق $floor');
    }
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add('شقة $apartment');
    }
    parts.add(area);
    parts.add(city);
    return parts.join('، ');
  }

  /// Get short address for display
  String get shortAddress {
    return '$address، $area';
  }

  double get latitude => location.latitude;
  double get longitude => location.longitude;
}

/// Input model for adding/updating address
@freezed
class AddressInput with _$AddressInput {
  const factory AddressInput({
    required AddressLabel label,
    required String name,
    required String address,
    required String area,
    @Default('الباجور') String city,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    required List<double> coordinates,
    @Default(false) bool isDefault,
  }) = _AddressInput;

  factory AddressInput.fromJson(Map<String, dynamic> json) =>
      _$AddressInputFromJson(json);

  const AddressInput._();

  /// Create from Address model
  factory AddressInput.fromAddress(Address address) {
    return AddressInput(
      label: address.label,
      name: address.name,
      address: address.address,
      area: address.area,
      city: address.city,
      building: address.building,
      floor: address.floor,
      apartment: address.apartment,
      landmark: address.landmark,
      coordinates: address.location.coordinates,
      isDefault: address.isDefault,
    );
  }
}
