import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screens.dart';
import '../screens/auth/documents_upload_screen.dart';
import '../screens/auth/vehicle_info_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/orders/available_orders_screen.dart';
import '../screens/orders/active_delivery_screen.dart';
import '../screens/orders/order_request_screen.dart';
import '../screens/orders/navigation_screen.dart';
import '../screens/orders/delivery_complete_screen.dart';
import '../screens/orders/delivery_history_screen.dart';
import '../screens/orders/delivery_details_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/request_withdrawal_screen.dart';
import '../screens/earnings/today_earnings_screen.dart';
import '../screens/earnings/earnings_history_screen.dart';
import '../screens/earnings/payout_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/documents_screen.dart';
import '../screens/profile/vehicle_screen.dart';
import '../screens/profile/reviews_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/support_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/order.dart';

class AppRoutes {
  // Initial & Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Registration Flow
  static const String documentsUpload = '/documents-upload';
  static const String vehicleInfo = '/vehicle-info';
  static const String pendingApproval = '/pending-approval';

  // Main App
  static const String home = '/home';

  // Orders & Deliveries
  static const String orders = '/orders';
  static const String activeOrder = '/orders/active';
  static const String orderDetails = '/orders/:id';
  static const String orderNavigation = '/orders/:id/navigate';
  static const String orderRequest = '/order-request/:id';
  static const String navigation = '/navigation/:id';
  static const String deliveryComplete = '/delivery-complete/:id';

  // Delivery History
  static const String deliveryHistory = '/delivery-history';
  static const String deliveryDetails = '/delivery/:id';

  // Earnings
  static const String earnings = '/earnings';
  static const String earningsDetails = '/earnings/details';
  static const String todayEarnings = '/today-earnings';
  static const String earningsHistory = '/earnings-history';
  static const String withdrawals = '/withdrawals';
  static const String requestWithdrawal = '/withdrawals/request';
  static const String payout = '/payout';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String documents = '/profile/documents';
  static const String vehicle = '/profile/vehicle';
  static const String reviews = '/reviews';

  // Settings & Support
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String support = '/support';
  static const String help = '/help';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // ==================== INITIAL & AUTH ====================
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

    // ==================== REGISTRATION FLOW ====================
    GoRoute(
      path: AppRoutes.vehicleInfo,
      builder: (context, state) => const VehicleInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.documentsUpload,
      builder: (context, state) => const DocumentsUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.pendingApproval,
      builder: (context, state) => const PendingApprovalScreen(),
    ),

    // ==================== HOME ====================
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // ==================== ORDERS & DELIVERIES ====================
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
    GoRoute(
      path: AppRoutes.orderRequest,
      builder: (context, state) {
        final extra = state.extra as AvailableOrder?;
        if (extra == null) {
          return const ErrorScreen(error: null);
        }
        return OrderRequestScreen(order: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.navigation,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return NavigationScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.deliveryComplete,
      builder: (context, state) {
        final extra = state.extra as DriverOrder?;
        if (extra == null) {
          return const ErrorScreen(error: null);
        }
        return DeliveryCompleteScreen(order: extra);
      },
    ),

    // ==================== DELIVERY HISTORY ====================
    GoRoute(
      path: AppRoutes.deliveryHistory,
      builder: (context, state) => const DeliveryHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.deliveryDetails,
      builder: (context, state) {
        final extra = state.extra as DriverOrder?;
        if (extra == null) {
          return const ErrorScreen(error: null);
        }
        return DeliveryDetailsScreen(order: extra);
      },
    ),
    GoRoute(
      path: '/orders/history/:id',
      builder: (context, state) {
        final extra = state.extra as DriverOrder?;
        if (extra == null) {
          return const ErrorScreen(error: null);
        }
        return DeliveryDetailsScreen(order: extra);
      },
    ),

    // ==================== EARNINGS ====================
    GoRoute(
      path: AppRoutes.earnings,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.earningsDetails,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.todayEarnings,
      builder: (context, state) => const TodayEarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.earningsHistory,
      builder: (context, state) => const EarningsHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.withdrawals,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestWithdrawal,
      builder: (context, state) => const RequestWithdrawalScreen(),
    ),
    GoRoute(
      path: AppRoutes.payout,
      builder: (context, state) => const PayoutScreen(),
    ),

    // ==================== PROFILE ====================
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
    GoRoute(
      path: AppRoutes.reviews,
      builder: (context, state) => const ReviewsScreen(),
    ),

    // ==================== SETTINGS & SUPPORT ====================
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
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);

/// Error screen for unhandled routes
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'الصفحة غير موجودة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'حدث خطأ غير متوقع',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Extension methods for navigation
extension NavigationExtensions on BuildContext {
  /// Navigate to order details
  void goToOrderDetails(String orderId) {
    go('/orders/$orderId');
  }

  /// Navigate to active delivery with order
  void goToActiveDelivery(String orderId) {
    go('/orders/$orderId');
  }

  /// Navigate to navigation screen
  void goToNavigation(String orderId) {
    go('/navigation/$orderId');
  }

  /// Navigate to delivery complete
  void goToDeliveryComplete(String orderId, {double earnings = 0.0}) {
    go(
      '/delivery-complete/$orderId',
      extra: {'earnings': earnings},
    );
  }

  /// Navigate to order request popup
  void showOrderRequest({
    required String orderId,
    required String restaurantName,
    required double distance,
    required double estimatedEarnings,
  }) {
    push(
      '/order-request/$orderId',
      extra: {
        'restaurantName': restaurantName,
        'distance': distance,
        'estimatedEarnings': estimatedEarnings,
      },
    );
  }

  /// Navigate to OTP screen
  void goToOtp({required String identifier, required String type}) {
    go(
      AppRoutes.otp,
      extra: {
        'phone': type == 'phone_verification' ? identifier : null,
        'email': type == 'email_verification' ? identifier : null,
        'type': type,
      },
    );
  }

  /// Navigate to reset password
  void goToResetPassword({required String email}) {
    go(
      AppRoutes.resetPassword,
      extra: {'email': email},
    );
  }
}
