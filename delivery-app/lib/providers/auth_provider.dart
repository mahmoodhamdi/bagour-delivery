import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
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
  const factory AuthState.requiresVerification({
    required String email,
    String? message,
  }) = _RequiresVerification;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SocketService _socketService;

  AuthNotifier(this._authService, this._socketService) : super(const AuthState.initial()) {
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

        // Connect to socket on authentication
        if (user.role == UserRole.driver) {
          try {
            await _socketService.connect(user.id);
          } catch (e) {
            // Socket connection failure shouldn't prevent authentication
            print('Socket connection failed: $e');
          }
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  // Register Driver
  Future<void> register(DriverRegisterRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.register(request);
      state = AuthState.requiresVerification(
        email: response.email,
        message: response.message,
      );
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Verify Email
  Future<void> verifyEmail(VerifyEmailRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.verifyEmail(request);
      state = AuthState.authenticated(
        user: response.user,
        driver: response.driver,
      );

      // Connect to socket on successful verification
      try {
        await _socketService.connect(response.user.id);
      } catch (e) {
        // Socket connection failure shouldn't prevent authentication
        print('Socket connection failed: $e');
      }
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Login
  Future<void> login(LoginRequest request) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.login(request);

      if (response is PendingVerificationResponse) {
        state = AuthState.requiresVerification(
          email: response.email,
          message: response.message,
        );
      } else if (response is AuthResponse) {
        state = AuthState.authenticated(
          user: response.user,
          driver: response.driver,
        );

        // Connect to socket on successful login
        try {
          await _socketService.connect(response.user.id);
        } catch (e) {
          // Socket connection failure shouldn't prevent authentication
          print('Socket connection failed: $e');
        }
      }
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final response = await _authService.signInWithGoogle();
      state = AuthState.authenticated(
        user: response.user,
        driver: response.driver,
      );

      // Connect to socket on successful Google sign-in
      try {
        await _socketService.connect(response.user.id);
      } catch (e) {
        // Socket connection failure shouldn't prevent authentication
        print('Socket connection failed: $e');
      }
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Resend OTP
  Future<bool> resendOtp(String email) async {
    try {
      await _authService.resendOtp(ResendOtpRequest(email: email));
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _authService.forgotPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      await _authService.resetPassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      await _authService.changePassword(request);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Refresh User
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getMe();
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  // Update FCM Token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _authService.updateFcmToken(
        UpdateFcmTokenRequest(fcmToken: fcmToken),
      );
    } catch (_) {
      // Ignore FCM token update errors
    }
  }

  // Logout
  Future<void> logout({String? fcmToken}) async {
    state = const AuthState.loading();

    // Disconnect socket before logout
    _socketService.disconnect();

    await _authService.logout(fcmToken: fcmToken);
    state = const AuthState.unauthenticated();
  }

  // Clear Error
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
  final socketService = ref.watch(socketServiceProvider);
  return AuthNotifier(authService, socketService);
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
