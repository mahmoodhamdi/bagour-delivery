import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import 'order_provider.dart' show apiServiceProvider;

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required User user,
    DriverProfile? driver,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial());

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

  Future<void> login(LoginRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.login(request);
      state = AuthState.authenticated(
        user: response.user,
        driver: response.driver,
      );
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> register(DriverRegisterRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.registerDriver(request);
      state = AuthState.authenticated(
        user: response.user,
        driver: response.driver,
      );
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> verifyOtp(VerifyOtpRequest request) async {
    state = const AuthState.loading();
    try {
      await _authService.verifyOtp(request);
      await checkAuthStatus();
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> resendOtp(ResendOtpRequest request) async {
    try {
      await _authService.resendOtp(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _authService.forgotPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      await _authService.resetPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _authService.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  void clearError() {
    state.mapOrNull(
      error: (_) => state = const AuthState.unauthenticated(),
    );
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
