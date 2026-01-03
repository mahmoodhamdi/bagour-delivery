import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._api);

  Future<AuthResponse> registerDriver(DriverRegisterRequest request) async {
    try {
      final response = await _api.post(
        ApiEndpoints.register,
        data: {
          ...request.toJson(),
          'licenseExpiryDate': request.licenseExpiryDate.toIso8601String(),
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse(
          user: User.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          driver: data['driver'] != null ? DriverProfile.fromJson(data['driver']) : null,
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في التسجيل');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _api.post(ApiEndpoints.login, data: request.toJson());

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse(
          user: User.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          driver: data['driver'] != null ? DriverProfile.fromJson(data['driver']) : null,
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في تسجيل الدخول');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _api.post(ApiEndpoints.verifyOtp, data: request.toJson());
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في التحقق');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _api.post(ApiEndpoints.resendOtp, data: request.toJson());
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال الرمز');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _api.post(ApiEndpoints.forgotPassword, data: request.toJson());
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال الرمز');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _api.post(ApiEndpoints.resetPassword, data: request.toJson());
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _api.get(ApiEndpoints.driverProfile);
      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']['user']);
      }
      throw Exception(response.data['message'] ?? 'فشل في جلب البيانات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout({String? fcmToken}) async {
    try {
      await _api.post(ApiEndpoints.logout, data: fcmToken != null ? {'fcmToken': fcmToken} : null);
    } catch (_) {
    } finally {
      await clearTokens();
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.driverDataKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return Exception('لا يوجد اتصال بالإنترنت');
      default:
        return Exception('حدث خطأ ما');
    }
  }
}
