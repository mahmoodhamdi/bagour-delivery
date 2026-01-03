import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

// Placeholder for actual screen implementations
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const PlaceholderScreen(title: 'Splash'),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const PlaceholderScreen(title: 'Onboarding'),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const PlaceholderScreen(title: 'Login'),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const PlaceholderScreen(title: 'Register'),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => const PlaceholderScreen(title: 'OTP Verification'),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const PlaceholderScreen(title: 'Forgot Password'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const PlaceholderScreen(title: 'Orders'),
    ),
    GoRoute(
      path: AppRoutes.activeOrder,
      builder: (context, state) => const PlaceholderScreen(title: 'Active Order'),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderScreen(title: 'Order $id');
      },
    ),
    GoRoute(
      path: AppRoutes.orderNavigation,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderScreen(title: 'Navigate to Order $id');
      },
    ),
    GoRoute(
      path: AppRoutes.earnings,
      builder: (context, state) => const PlaceholderScreen(title: 'Earnings'),
    ),
    GoRoute(
      path: AppRoutes.earningsDetails,
      builder: (context, state) => const PlaceholderScreen(title: 'Earnings Details'),
    ),
    GoRoute(
      path: AppRoutes.withdrawals,
      builder: (context, state) => const PlaceholderScreen(title: 'Withdrawals'),
    ),
    GoRoute(
      path: AppRoutes.requestWithdrawal,
      builder: (context, state) => const PlaceholderScreen(title: 'Request Withdrawal'),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const PlaceholderScreen(title: 'Edit Profile'),
    ),
    GoRoute(
      path: AppRoutes.documents,
      builder: (context, state) => const PlaceholderScreen(title: 'Documents'),
    ),
    GoRoute(
      path: AppRoutes.vehicle,
      builder: (context, state) => const PlaceholderScreen(title: 'Vehicle'),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const PlaceholderScreen(title: 'Notifications'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (context, state) => const PlaceholderScreen(title: 'Support'),
    ),
  ],
);
