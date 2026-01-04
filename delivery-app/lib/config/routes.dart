import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screens.dart';
import '../screens/home/home_screen.dart';
import '../screens/orders/available_orders_screen.dart';
import '../screens/orders/active_delivery_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/request_withdrawal_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/documents_screen.dart';
import '../screens/profile/vehicle_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/support_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main app routes
  static const String home = '/home';
  static const String orders = '/orders';
  static const String activeOrder = '/orders/active';
  static const String orderDetails = '/orders/:id';
  static const String orderNavigation = '/orders/:id/navigate';

  // Earnings
  static const String earnings = '/earnings';
  static const String earningsDetails = '/earnings/details';
  static const String withdrawals = '/withdrawals';
  static const String requestWithdrawal = '/withdrawals/request';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String documents = '/profile/documents';
  static const String vehicle = '/profile/vehicle';

  // Settings & Others
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String support = '/support';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash & Auth
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpScreen(
          identifier: extra?['phone'] ?? extra?['email'] ?? '',
          type: extra?['type'] ?? 'phone_verification',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordScreen(email: extra?['email'] ?? '');
      },
    ),

    // Home
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // Orders
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const AvailableOrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeOrder,
      builder: (context, state) => const ActiveDeliveryScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ActiveDeliveryScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.orderNavigation,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ActiveDeliveryScreen(orderId: id);
      },
    ),

    // Earnings
    GoRoute(
      path: AppRoutes.earnings,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.earningsDetails,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.withdrawals,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestWithdrawal,
      builder: (context, state) => const RequestWithdrawalScreen(),
    ),

    // Profile
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.documents,
      builder: (context, state) => const DocumentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.vehicle,
      builder: (context, state) => const VehicleScreen(),
    ),

    // Settings & Others
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (context, state) => const SupportScreen(),
    ),
  ],
);
