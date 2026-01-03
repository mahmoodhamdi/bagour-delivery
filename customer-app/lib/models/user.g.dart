// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      avatar: json['avatar'] as String?,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'avatar': instance.avatar,
      'isPhoneVerified': instance.isPhoneVerified,
      'isEmailVerified': instance.isEmailVerified,
      'isActive': instance.isActive,
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.restaurant: 'restaurant',
  UserRole.driver: 'driver',
  UserRole.admin: 'admin',
};

_$CustomerProfileImpl _$$CustomerProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomerProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      favoriteRestaurants: (json['favoriteRestaurants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CustomerProfileImplToJson(
        _$CustomerProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'referralCode': instance.referralCode,
      'referredBy': instance.referredBy,
      'loyaltyPoints': instance.loyaltyPoints,
      'walletBalance': instance.walletBalance,
      'favoriteRestaurants': instance.favoriteRestaurants,
    };
