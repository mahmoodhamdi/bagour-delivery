// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressLocationImpl _$$AddressLocationImplFromJson(
        Map<String, dynamic> json) =>
    _$AddressLocationImpl(
      type: json['type'] as String? ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$AddressLocationImplToJson(
        _$AddressLocationImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: json['_id'] as String?,
      label: $enumDecode(_$AddressLabelEnumMap, json['label']),
      name: json['name'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      city: json['city'] as String? ?? 'الباجور',
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      landmark: json['landmark'] as String?,
      location:
          AddressLocation.fromJson(json['location'] as Map<String, dynamic>),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'label': _$AddressLabelEnumMap[instance.label]!,
      'name': instance.name,
      'address': instance.address,
      'area': instance.area,
      'city': instance.city,
      'building': instance.building,
      'floor': instance.floor,
      'apartment': instance.apartment,
      'landmark': instance.landmark,
      'location': instance.location,
      'isDefault': instance.isDefault,
    };

const _$AddressLabelEnumMap = {
  AddressLabel.home: 'home',
  AddressLabel.work: 'work',
  AddressLabel.other: 'other',
};

_$AddressInputImpl _$$AddressInputImplFromJson(Map<String, dynamic> json) =>
    _$AddressInputImpl(
      label: $enumDecode(_$AddressLabelEnumMap, json['label']),
      name: json['name'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      city: json['city'] as String? ?? 'الباجور',
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      landmark: json['landmark'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressInputImplToJson(_$AddressInputImpl instance) =>
    <String, dynamic>{
      'label': _$AddressLabelEnumMap[instance.label]!,
      'name': instance.name,
      'address': instance.address,
      'area': instance.area,
      'city': instance.city,
      'building': instance.building,
      'floor': instance.floor,
      'apartment': instance.apartment,
      'landmark': instance.landmark,
      'coordinates': instance.coordinates,
      'isDefault': instance.isDefault,
    };
