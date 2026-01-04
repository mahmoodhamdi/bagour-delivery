import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

part 'auth_provider.freezed.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthService(api);
});

// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required User user,
    CustomerProfile? profile,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getMe();
        state = AuthState.authenticated(user: user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> register(CustomerRegisterRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.registerCustomer(request);
      state = AuthState.authenticated(
        user: response.user,
        profile: response.profile,
      );
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> login(LoginRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.login(request);
      state = AuthState.authenticated(
        user: response.user,
        profile: response.profile,
      );
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> verifyOtp(VerifyOtpRequest request) async {
    state = const AuthState.loading();
    try {
      await _authService.verifyOtp(request);
      // Refresh user data after verification
      final user = await _authService.getMe();
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> resendOtp(ResendOtpRequest request) async {
    try {
      await _authService.resendOtp(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _authService.forgotPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      await _authService.resetPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      await _authService.changePassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getMe();
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _authService.updateFcmToken(
        UpdateFcmTokenRequest(fcmToken: fcmToken),
      );
    } catch (_) {
      // Ignore FCM token update errors
    }
  }

  Future<void> logout({String? fcmToken}) async {
    state = const AuthState.loading();
    await _authService.logout(fcmToken: fcmToken);
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    state.mapOrNull(
      error: (_) => state = const AuthState.unauthenticated(),
    );
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeMap(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.mapOrNull(
    authenticated: (state) => state.user,
  );
});
