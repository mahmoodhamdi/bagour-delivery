import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screens.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String search = '/search';
  static const String restaurant = '/restaurant/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order/:id';
  static const String orderHistory = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/:id';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
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
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordScreen(email: extra?['email'] ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const PlaceholderScreen(title: 'Search'),
    ),
    GoRoute(
      path: AppRoutes.restaurant,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderScreen(title: 'Restaurant $id');
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const PlaceholderScreen(title: 'Cart'),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const PlaceholderScreen(title: 'Checkout'),
    ),
    GoRoute(
      path: AppRoutes.orderTracking,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderScreen(title: 'Order Tracking $id');
      },
    ),
    GoRoute(
      path: AppRoutes.orderHistory,
      builder: (context, state) => const PlaceholderScreen(title: 'Order History'),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (context, state) => const PlaceholderScreen(title: 'Addresses'),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      builder: (context, state) => const PlaceholderScreen(title: 'Favorites'),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const PlaceholderScreen(title: 'Notifications'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
    ),
  ],
);
