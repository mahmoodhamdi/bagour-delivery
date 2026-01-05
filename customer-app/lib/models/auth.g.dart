// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      profile: json['profile'] == null
          ? null
          : CustomerProfile.fromJson(json['profile'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] as bool?,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'profile': instance.profile,
      'isNewUser': instance.isNewUser,
    };

_$PendingVerificationResponseImpl _$$PendingVerificationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PendingVerificationResponseImpl(
      requiresVerification: json['requiresVerification'] as bool,
      email: json['email'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$PendingVerificationResponseImplToJson(
        _$PendingVerificationResponseImpl instance) =>
    <String, dynamic>{
      'requiresVerification': instance.requiresVerification,
      'email': instance.email,
      'message': instance.message,
    };

_$TokenPairImpl _$$TokenPairImplFromJson(Map<String, dynamic> json) =>
    _$TokenPairImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$TokenPairImplToJson(_$TokenPairImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

_$CustomerRegisterRequestImpl _$$CustomerRegisterRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomerRegisterRequestImpl(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String? ?? 'customer',
      phone: json['phone'] as String?,
      referralCode: json['referralCode'] as String?,
    );

Map<String, dynamic> _$$CustomerRegisterRequestImplToJson(
        _$CustomerRegisterRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
      'phone': instance.phone,
      'referralCode': instance.referralCode,
    };

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
    };

_$GoogleSignInRequestImpl _$$GoogleSignInRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$GoogleSignInRequestImpl(
      idToken: json['idToken'] as String,
      role: json['role'] as String? ?? 'customer',
    );

Map<String, dynamic> _$$GoogleSignInRequestImplToJson(
        _$GoogleSignInRequestImpl instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'role': instance.role,
    };

_$VerifyEmailRequestImpl _$$VerifyEmailRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyEmailRequestImpl(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$$VerifyEmailRequestImplToJson(
        _$VerifyEmailRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otp,
    };

_$ResendOtpRequestImpl _$$ResendOtpRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ResendOtpRequestImpl(
      email: json['email'] as String,
    );

Map<String, dynamic> _$$ResendOtpRequestImplToJson(
        _$ResendOtpRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$ForgotPasswordRequestImpl _$$ForgotPasswordRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ForgotPasswordRequestImpl(
      email: json['email'] as String,
    );

Map<String, dynamic> _$$ForgotPasswordRequestImplToJson(
        _$ForgotPasswordRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$ResetPasswordRequestImpl _$$ResetPasswordRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ResetPasswordRequestImpl(
      email: json['email'] as String,
      otp: json['otp'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$$ResetPasswordRequestImplToJson(
        _$ResetPasswordRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otp,
      'newPassword': instance.newPassword,
    };

_$ChangePasswordRequestImpl _$$ChangePasswordRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ChangePasswordRequestImpl(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$$ChangePasswordRequestImplToJson(
        _$ChangePasswordRequestImpl instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
    };

_$RefreshTokenRequestImpl _$$RefreshTokenRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RefreshTokenRequestImpl(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$RefreshTokenRequestImplToJson(
        _$RefreshTokenRequestImpl instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

_$UpdateFcmTokenRequestImpl _$$UpdateFcmTokenRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateFcmTokenRequestImpl(
      fcmToken: json['fcmToken'] as String,
      deviceType: json['deviceType'] as String?,
    );

Map<String, dynamic> _$$UpdateFcmTokenRequestImplToJson(
        _$UpdateFcmTokenRequestImpl instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'deviceType': instance.deviceType,
    };
