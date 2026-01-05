import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/constants.dart';
import 'api_service.dart';

/// Restaurant authentication response containing user data and tokens
class RestaurantAuthResponse {
  final Map<String, dynamic> user;
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic>? restaurant;
  final bool? isNewUser;

  RestaurantAuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.restaurant,
    this.isNewUser,
  });

  factory RestaurantAuthResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantAuthResponse(
      user: json['user'] as Map<String, dynamic>,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      restaurant: json['restaurant'] as Map<String, dynamic>?,
      isNewUser: json['isNewUser'] as bool?,
    );
  }
}

/// Response indicating pending email verification
class PendingVerificationResponse {
  final bool requiresVerification;
  final String email;
  final String? message;

  PendingVerificationResponse({
    required this.requiresVerification,
    required this.email,
    this.message,
  });

  factory PendingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PendingVerificationResponse(
      requiresVerification: json['requiresVerification'] as bool,
      email: json['email'] as String,
      message: json['message'] as String?,
    );
  }
}

/// Token pair for refresh operations
class TokenPair {
  final String accessToken;
  final String refreshToken;

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

/// Authentication service for restaurant owner accounts
class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthService(this._api);

  // ============================================================
  // Registration
  // ============================================================

  /// Register a new restaurant owner account
  ///
  /// [name] - Owner's full name
  /// [email] - Email address
  /// [password] - Password (min 8 characters)
  /// [phone] - Phone number (optional)
  /// [restaurantData] - Restaurant information for registration
  ///
  /// Returns [PendingVerificationResponse] with email to verify
  Future<PendingVerificationResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    Map<String, dynamic>? restaurantData,
  }) async {
    try {
      final response = await _api.post(
        AppEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'restaurant',
          if (phone != null) 'phone': phone,
          if (restaurantData != null) 'restaurantData': restaurantData,
        },
      );

      if (response.data['success'] == true) {
        return PendingVerificationResponse(
          requiresVerification: true,
          email: email,
          message: response.data['message'],
        );
      }

      throw Exception(response.data['message'] ?? 'فشل في التسجيل');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // Login
  // ============================================================

  /// Login with email and password
  ///
  /// Returns either [RestaurantAuthResponse] on success or
  /// [PendingVerificationResponse] if email verification is required
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        AppEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'role': 'restaurant',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Check if email verification is required
        if (data['requiresVerification'] == true) {
          return PendingVerificationResponse(
            requiresVerification: true,
            email: data['email'],
            message: response.data['message'],
          );
        }

        // Successful login
        final authResponse = RestaurantAuthResponse(
          user: data['user'],
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          restaurant: data['restaurant'],
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        if (authResponse.restaurant != null) {
          await _saveRestaurant(authResponse.restaurant!);
        }

        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في تسجيل الدخول');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // Email Verification
  // ============================================================

  /// Verify email with OTP code
  ///
  /// [email] - Email address to verify
  /// [otp] - 6-digit OTP code received via email
  ///
  /// Returns [RestaurantAuthResponse] with tokens on successful verification
  Future<RestaurantAuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _api.post(
        AppEndpoints.verifyEmail,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = RestaurantAuthResponse(
          user: data['user'],
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          restaurant: data['restaurant'],
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        if (authResponse.restaurant != null) {
          await _saveRestaurant(authResponse.restaurant!);
        }

        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في التحقق');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Resend OTP verification code
  ///
  /// [email] - Email address to resend OTP to
  Future<void> resendOtp({required String email}) async {
    try {
      final response = await _api.post(
        AppEndpoints.resendOtp,
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال الرمز');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // Password Management
  // ============================================================

  /// Request password reset OTP
  ///
  /// [email] - Email address associated with the account
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _api.post(
        AppEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إرسال رمز إعادة التعيين');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reset password with OTP
  ///
  /// [email] - Email address
  /// [otp] - OTP code received via email
  /// [newPassword] - New password (min 8 characters)
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post(
        AppEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Change password for authenticated user
  ///
  /// [currentPassword] - Current password
  /// [newPassword] - New password (min 8 characters)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post(
        AppEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // Google Sign-In
  // ============================================================

  /// Sign in with Google
  ///
  /// Initiates Google Sign-In flow and authenticates with backend
  /// Returns [RestaurantAuthResponse] with user data and tokens
  Future<RestaurantAuthResponse> googleSignIn() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('فشل في الحصول على رمز التحقق');
      }

      // Send ID token to backend
      final response = await _api.post(
        AppEndpoints.googleSignIn,
        data: {
          'idToken': googleAuth.idToken!,
          'role': 'restaurant',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final authResponse = RestaurantAuthResponse(
          user: data['user'],
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          restaurant: data['restaurant'],
          isNewUser: data['isNewUser'],
        );

        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        if (authResponse.restaurant != null) {
          await _saveRestaurant(authResponse.restaurant!);
        }

        return authResponse;
      }

      throw Exception(response.data['message'] ?? 'فشل في تسجيل الدخول بحساب Google');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // Profile & Session
  // ============================================================

  /// Get current user profile
  ///
  /// Returns user data with restaurant information
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get(AppEndpoints.me);

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Update cached user data
        if (data['user'] != null) {
          await _saveUser(data['user']);
        }
        if (data['restaurant'] != null) {
          await _saveRestaurant(data['restaurant']);
        }

        return data;
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب البيانات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout current user
  ///
  /// [fcmToken] - Optional FCM token to unregister for push notifications
  Future<void> logout({String? fcmToken}) async {
    try {
      await _api.post(
        AppEndpoints.logout,
        data: fcmToken != null ? {'fcmToken': fcmToken} : null,
      );
    } catch (_) {
      // Ignore logout API errors - clear local data anyway
    } finally {
      await _googleSignIn.signOut();
      await clearTokens();
    }
  }

  // ============================================================
  // Token Management
  // ============================================================

  /// Refresh access token
  ///
  /// Returns new [TokenPair] on success
  Future<TokenPair> refreshToken() async {
    try {
      final currentRefreshToken = await getRefreshToken();
      if (currentRefreshToken == null) {
        throw Exception('لا يوجد رمز تحديث');
      }

      final response = await _api.post(
        AppEndpoints.refreshToken,
        data: {'refreshToken': currentRefreshToken},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final tokenPair = TokenPair(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        await _saveTokens(tokenPair.accessToken, tokenPair.refreshToken);
        return tokenPair;
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث الرمز');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update FCM token for push notifications
  ///
  /// [fcmToken] - Firebase Cloud Messaging token
  /// [deviceType] - Device type (android/ios)
  Future<void> updateFcmToken({
    required String fcmToken,
    String? deviceType,
  }) async {
    try {
      await _api.post(
        AppEndpoints.fcmToken,
        data: {
          'fcmToken': fcmToken,
          if (deviceType != null) 'deviceType': deviceType,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // Storage Operations
  // ============================================================

  /// Save tokens to secure storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  /// Save user data to secure storage
  Future<void> _saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: user.toString(),
    );
  }

  /// Save restaurant data to secure storage
  Future<void> _saveRestaurant(Map<String, dynamic> restaurant) async {
    await _storage.write(
      key: AppConstants.restaurantKey,
      value: restaurant.toString(),
    );
  }

  /// Get access token from storage
  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  /// Get refresh token from storage
  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// Clear all authentication tokens and cached data
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userKey);
    await _storage.delete(key: AppConstants.restaurantKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // Error Handling
  // ============================================================

  /// Handle Dio errors and return user-friendly exception
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
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('طلب غير صالح');
          case 401:
            return Exception('بيانات الدخول غير صحيحة');
          case 403:
            return Exception('غير مسموح بالوصول');
          case 404:
            return Exception('لم يتم العثور على الحساب');
          case 409:
            return Exception('البريد الإلكتروني مستخدم بالفعل');
          case 429:
            return Exception('طلبات كثيرة. يرجى الانتظار');
          default:
            return Exception('حدث خطأ ما');
        }
      default:
        return Exception('حدث خطأ ما');
    }
  }
}
