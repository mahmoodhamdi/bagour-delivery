import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screens.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/restaurant/restaurant_details_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/address/addresses_screen.dart';
import '../screens/address/add_edit_address_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/order/order_history_screen.dart';
import '../screens/payment/payment_webview_screen.dart';
import '../screens/payment/payment_result_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/rating/rate_order_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
import '../screens/legal/terms_screen.dart';
import '../screens/address/map_picker_screen.dart';
import '../screens/menu/menu_item_details_screen.dart';
import '../screens/help/help_screen.dart';
import '../models/restaurant.dart';

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
  static const String menuItem = '/menu-item';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order/:id';
  static const String orderHistory = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String rateOrder = '/orders/:id/rate';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/:id';
  static const String mapPicker = '/addresses/map-picker';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String wallet = '/wallet';
  static const String help = '/help';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailed = '/payment/failed';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.restaurant,
      builder: (context, state) {
        final slug = state.pathParameters['id']!;
        return RestaurantDetailsScreen(slug: slug);
      },
    ),
    GoRoute(
      path: AppRoutes.menuItem,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final menuItem = extra['menuItem'] as MenuItem;
        final restaurant = extra['restaurant'] as Restaurant;
        return MenuItemDetailsScreen(
          menuItem: menuItem,
          restaurant: restaurant,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderTracking,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderTrackingScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.orderHistory,
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.rateOrder,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return RateOrderScreen(
          orderId: orderId,
          restaurantName: extra?['restaurantName'] ?? '',
          driverName: extra?['driverName'],
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: AppRoutes.addAddress,
      builder: (context, state) => const AddEditAddressScreen(),
    ),
    GoRoute(
      path: AppRoutes.editAddress,
      builder: (context, state) {
        final addressId = state.pathParameters['id']!;
        return AddEditAddressScreen(addressId: addressId);
      },
    ),
    GoRoute(
      path: AppRoutes.mapPicker,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MapPickerScreen(
          initialLat: extra?['latitude'] as double?,
          initialLng: extra?['longitude'] as double?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentWebViewScreen(
          paymentUrl: extra?['paymentUrl'] ?? '',
          orderId: extra?['orderId'] ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentSuccess,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['order'] ?? '';
        return PaymentResultScreen(success: true, orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.paymentFailed,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['order'] ?? '';
        return PaymentResultScreen(success: false, orderId: orderId);
      },
    ),
  ],
);
