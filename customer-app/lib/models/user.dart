import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('restaurant')
  restaurant,
  @JsonValue('driver')
  driver,
  @JsonValue('admin')
  admin,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    String? avatar,
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isEmailVerified,
    @Default(true) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class CustomerProfile with _$CustomerProfile {
  const factory CustomerProfile({
    required String id,
    required String userId,
    String? referralCode,
    String? referredBy,
    @Default(0) int loyaltyPoints,
    @Default(0.0) double walletBalance,
    @Default([]) List<String> favoriteRestaurants,
  }) = _CustomerProfile;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileFromJson(json);
}
