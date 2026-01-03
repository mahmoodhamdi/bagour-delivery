// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverProfileImpl _$$DriverProfileImplFromJson(Map<String, dynamic> json) =>
    _$DriverProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nationalId: json['nationalId'] as String,
      vehicleType: json['vehicleType'] as String,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      licenseNumber: json['licenseNumber'] as String,
      licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
      status: json['status'] as String? ?? 'pending',
      isOnline: json['isOnline'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: (json['totalDeliveries'] as num?)?.toInt() ?? 0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DriverProfileImplToJson(_$DriverProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nationalId': instance.nationalId,
      'vehicleType': instance.vehicleType,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleModel': instance.vehicleModel,
      'vehicleColor': instance.vehicleColor,
      'licenseNumber': instance.licenseNumber,
      'licenseExpiryDate': instance.licenseExpiryDate.toIso8601String(),
      'status': instance.status,
      'isOnline': instance.isOnline,
      'isAvailable': instance.isAvailable,
      'rating': instance.rating,
      'totalDeliveries': instance.totalDeliveries,
      'currentBalance': instance.currentBalance,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      driver: json['driver'] == null
          ? null
          : DriverProfile.fromJson(json['driver'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'driver': instance.driver,
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

_$DriverRegisterRequestImpl _$$DriverRegisterRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverRegisterRequestImpl(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      nationalId: json['nationalId'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehiclePlateNumber: json['vehiclePlateNumber'] as String,
      licenseNumber: json['licenseNumber'] as String,
      licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
    );

Map<String, dynamic> _$$DriverRegisterRequestImplToJson(
        _$DriverRegisterRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'nationalId': instance.nationalId,
      'vehicleType': instance.vehicleType,
      'vehicleModel': instance.vehicleModel,
      'vehicleColor': instance.vehicleColor,
      'vehiclePlateNumber': instance.vehiclePlateNumber,
      'licenseNumber': instance.licenseNumber,
      'licenseExpiryDate': instance.licenseExpiryDate.toIso8601String(),
    };

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$VerifyOtpRequestImpl _$$VerifyOtpRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyOtpRequestImpl(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      otp: json['otp'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$VerifyOtpRequestImplToJson(
        _$VerifyOtpRequestImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'email': instance.email,
      'otp': instance.otp,
      'type': instance.type,
    };

_$ResendOtpRequestImpl _$$ResendOtpRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ResendOtpRequestImpl(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$ResendOtpRequestImplToJson(
        _$ResendOtpRequestImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'email': instance.email,
      'type': instance.type,
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
