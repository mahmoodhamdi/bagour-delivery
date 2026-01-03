import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
class DriverProfile with _$DriverProfile {
  const factory DriverProfile({
    required String id,
    required String userId,
    required String nationalId,
    required String vehicleType,
    String? vehiclePlate,
    String? vehicleModel,
    String? vehicleColor,
    required String licenseNumber,
    required DateTime licenseExpiryDate,
    @Default('pending') String status,
    @Default(false) bool isOnline,
    @Default(false) bool isAvailable,
    @Default(0.0) double rating,
    @Default(0) int totalDeliveries,
    @Default(0.0) double currentBalance,
  }) = _DriverProfile;

  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required User user,
    required String accessToken,
    required String refreshToken,
    DriverProfile? driver,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class TokenPair with _$TokenPair {
  const factory TokenPair({
    required String accessToken,
    required String refreshToken,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
}

@freezed
class DriverRegisterRequest with _$DriverRegisterRequest {
  const factory DriverRegisterRequest({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String nationalId,
    required String vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    required String vehiclePlateNumber,
    required String licenseNumber,
    required DateTime licenseExpiryDate,
  }) = _DriverRegisterRequest;

  factory DriverRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverRegisterRequestFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class VerifyOtpRequest with _$VerifyOtpRequest {
  const factory VerifyOtpRequest({
    String? phone,
    String? email,
    required String otp,
    required String type,
  }) = _VerifyOtpRequest;

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);
}

@freezed
class ResendOtpRequest with _$ResendOtpRequest {
  const factory ResendOtpRequest({
    String? phone,
    String? email,
    required String type,
  }) = _ResendOtpRequest;

  factory ResendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestFromJson(json);
}

@freezed
class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({
    required String email,
  }) = _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String email,
    required String otp,
    required String newPassword,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

@freezed
class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}

@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}

@freezed
class UpdateFcmTokenRequest with _$UpdateFcmTokenRequest {
  const factory UpdateFcmTokenRequest({
    required String fcmToken,
    String? deviceType,
  }) = _UpdateFcmTokenRequest;

  factory UpdateFcmTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFcmTokenRequestFromJson(json);
}
