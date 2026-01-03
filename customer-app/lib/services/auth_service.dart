import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._api);

  // Register customer
  Future<AuthResponse> registerCustomer(CustomerRegisterRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.customerRegister,
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse(
          user: User.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          profile: data['profile'] != null
              ? CustomerProfile.fromJson(data['profile'])
              : null,
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);

        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في التسجيل');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.customerLogin,
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = AuthResponse(
          user: User.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          profile: data['profile'] != null
              ? CustomerProfile.fromJson(data['profile'])
              : null,
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);

        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في تسجيل الدخول');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Verify OTP
  Future<void> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في التحقق');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Resend OTP
  Future<void> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.resendOtp,
        data: request.toJson(),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال الرمز');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Forgot password
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.forgotPassword,
        data: request.toJson(),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال الرمز');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.resetPassword,
        data: request.toJson(),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Change password
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _api.post(
        AppEndpoints.changePassword,
        data: request.toJson(),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get current user
  Future<User> getMe() async {
    try {
      final response = await _api.get(AppEndpoints.me);

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']['user']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب البيانات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(UpdateFcmTokenRequest request) async {
    try {
      await _api.post(
        AppEndpoints.fcmToken,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Logout
  Future<void> logout({String? fcmToken}) async {
    try {
      await _api.post(
        AppEndpoints.logout,
        data: fcmToken != null ? {'fcmToken': fcmToken} : null,
      );
    } catch (_) {
      // Ignore logout errors
    } finally {
      await clearTokens();
    }
  }

  // Token management
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<void> _saveUser(User user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: user.toJson().toString(),
    );
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Error handling
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
