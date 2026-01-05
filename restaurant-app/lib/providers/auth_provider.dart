import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/api_service.dart';

part 'auth_provider.freezed.dart';

/// Auth state for restaurant owner
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required String restaurantId,
    required String userId,
    String? restaurantName,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.requiresVerification({
    required String email,
    String? message,
  }) = _RequiresVerification;
  const factory AuthState.error(String message) = _Error;
}

/// Auth notifier for restaurant owner authentication
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// Check authentication status on startup
  Future<void> _checkAuthStatus() async {
    await checkAuthStatus();
  }

  /// Public method to check auth status
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final hasTokens = await _apiService.hasValidTokens();
      if (hasTokens) {
        // Verify tokens by fetching user profile
        final response = await _apiService.get('/auth/me');
        if (response.statusCode == 200 && response.data['success'] == true) {
          final userData = response.data['data'];
          final user = userData['user'];
          final restaurant = userData['restaurant'];

          // Ensure user is a restaurant owner
          if (user['role'] != 'restaurant_owner') {
            await _apiService.clearTokens();
            state = const AuthState.unauthenticated();
            return;
          }

          state = AuthState.authenticated(
            userId: user['_id'] ?? user['id'] ?? '',
            restaurantId: restaurant?['_id'] ?? restaurant?['id'] ?? '',
            restaurantName: restaurant?['name'],
          );
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
        'role': 'restaurant_owner',
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Check if email verification is required
        if (data['requiresVerification'] == true) {
          state = AuthState.requiresVerification(
            email: email,
            message: response.data['message'],
          );
          return;
        }

        // Save tokens
        await _apiService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        final user = data['user'];
        final restaurant = data['restaurant'];

        state = AuthState.authenticated(
          userId: user['_id'] ?? user['id'] ?? '',
          restaurantId: restaurant?['_id'] ?? restaurant?['id'] ?? '',
          restaurantName: restaurant?['name'],
        );
      } else {
        state = AuthState.error(
          response.data['message'] ?? 'فشل تسجيل الدخول',
        );
      }
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Register a new restaurant owner
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String restaurantName,
    String? address,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'restaurant_owner',
        'restaurantName': restaurantName,
        'address': address,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        state = AuthState.requiresVerification(
          email: email,
          message: response.data['message'] ?? 'تم إرسال رمز التحقق',
        );
      } else {
        state = AuthState.error(
          response.data['message'] ?? 'فشل إنشاء الحساب',
        );
      }
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Verify email with OTP
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await _apiService.post('/auth/verify-email', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Save tokens
        await _apiService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        final user = data['user'];
        final restaurant = data['restaurant'];

        state = AuthState.authenticated(
          userId: user['_id'] ?? user['id'] ?? '',
          restaurantId: restaurant?['_id'] ?? restaurant?['id'] ?? '',
          restaurantName: restaurant?['name'],
        );
      } else {
        state = AuthState.error(
          response.data['message'] ?? 'رمز التحقق غير صحيح',
        );
      }
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Resend OTP
  Future<bool> resendOtp(String email) async {
    try {
      final response = await _apiService.post('/auth/resend-otp', data: {
        'email': email,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
      return false;
    }
  }

  /// Request password reset
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
      return false;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
      return false;
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.patch('/auth/fcm-token', data: {
        'fcmToken': fcmToken,
      });
    } catch (_) {
      // Ignore FCM token update errors
    }
  }

  /// Logout
  Future<void> logout({String? fcmToken}) async {
    state = const AuthState.loading();
    try {
      if (fcmToken != null) {
        await _apiService.post('/auth/logout', data: {
          'fcmToken': fcmToken,
        });
      }
    } catch (_) {
      // Ignore logout errors
    } finally {
      await _apiService.clearTokens();
      state = const AuthState.unauthenticated();
    }
  }

  /// Clear error state
  void clearError() {
    state.maybeMap(
      error: (_) => state = const AuthState.unauthenticated(),
      orElse: () {},
    );
  }

  /// Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('Exception:')) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'حدث خطأ غير متوقع';
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});

/// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeMap(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

/// Helper provider to get current restaurant ID
final currentRestaurantIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.mapOrNull(
    authenticated: (state) => state.restaurantId,
  );
});

/// Helper provider to get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.mapOrNull(
    authenticated: (state) => state.userId,
  );
});

/// Helper provider to get current restaurant name
final currentRestaurantNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.mapOrNull(
    authenticated: (state) => state.restaurantName,
  );
});
