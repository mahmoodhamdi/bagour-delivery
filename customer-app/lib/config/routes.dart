import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screens.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/categories_screen.dart';
import '../screens/home/category_restaurants_screen.dart';
import '../screens/home/cuisine_screen.dart';
import '../screens/home/offers_screen.dart';
import '../screens/restaurant/restaurant_details_screen.dart';
import '../screens/restaurant/restaurant_reviews_screen.dart';
import '../screens/restaurant/restaurant_info_screen.dart';
import '../screens/restaurant/restaurant_gallery_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/address/addresses_screen.dart';
import '../screens/address/add_edit_address_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/order/order_history_screen.dart';
import '../screens/order/orders_screen.dart';
import '../screens/order/order_details_screen.dart';
import '../screens/order/order_success_screen.dart';
import '../screens/order/order_issue_screen.dart';
import '../screens/order/reorder_screen.dart';
import '../screens/checkout/promo_code_screen.dart';
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
import '../screens/chat/chats_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chat_support_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../models/restaurant.dart';
import '../models/order.dart';

class AppRoutes {
  // Initial & Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';

  // Main
  static const String home = '/home';
  static const String search = '/search';
  static const String restaurant = '/restaurant/:id';
  static const String restaurantReviews = '/restaurant/:id/reviews';
  static const String restaurantInfo = '/restaurant/:id/info';
  static const String restaurantGallery = '/restaurant/:id/gallery';
  static const String menuItem = '/menu-item';

  // Categories & Cuisines
  static const String categories = '/categories';
  static const String category = '/category/:id';
  static const String cuisine = '/cuisine/:type';
  static const String offers = '/offers';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String promoCode = '/promo-code';

  // Orders
  static const String orders = '/orders';
  static const String orderTracking = '/order/:id';
  static const String orderDetails = '/orders/:id';
  static const String orderSuccess = '/order-success';
  static const String orderIssue = '/order-issue';
  static const String reorder = '/reorder';
  static const String rateOrder = '/orders/:id/rate';

  // Profile & Settings
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
  static const String paymentMethods = '/payment-methods';

  // Chat & Support
  static const String chats = '/chats';
  static const String chat = '/chat/:id';
  static const String support = '/support';

  // Legal & Help
  static const String help = '/help';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';

  // Payment
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailed = '/payment/failed';
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

    // ==================== MAIN ====================
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),

    // ==================== RESTAURANT ====================
    GoRoute(
      path: AppRoutes.restaurant,
      builder: (context, state) {
        final slug = state.pathParameters['id']!;
        return RestaurantDetailsScreen(slug: slug);
      },
    ),
    GoRoute(
      path: AppRoutes.restaurantReviews,
      builder: (context, state) {
        final restaurantId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return RestaurantReviewsScreen(
          restaurantId: restaurantId,
          restaurantName: extra?['name'] ?? '',
          initialRating: extra?['rating'] as double?,
          initialReviewCount: extra?['reviewCount'] as int?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.restaurantInfo,
      builder: (context, state) {
        final restaurantId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return RestaurantInfoScreen(
          restaurantId: restaurantId,
          restaurant: extra?['restaurant'] as Restaurant?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.restaurantGallery,
      builder: (context, state) {
        final restaurantId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return RestaurantGalleryScreen(
          restaurantId: restaurantId,
          restaurantName: extra?['name'] ?? '',
          initialImages: extra?['images'] as List<String>?,
          initialIndex: extra?['index'] as int? ?? 0,
        );
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

    // ==================== CATEGORIES & CUISINES ====================
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: AppRoutes.category,
      builder: (context, state) {
        final categoryId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return CategoryRestaurantsScreen(
          categoryId: categoryId,
          categoryName: extra?['name'] ?? categoryId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.cuisine,
      builder: (context, state) {
        final cuisineType = state.pathParameters['type']!;
        final extra = state.extra as Map<String, dynamic>?;
        return CuisineScreen(
          cuisineId: cuisineType,
          cuisineName: extra?['name'] ?? cuisineType,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.offers,
      builder: (context, state) => const OffersScreen(),
    ),

    // ==================== CART & CHECKOUT ====================
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.promoCode,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PromoCodeScreen(
          restaurantId: extra?['restaurantId'],
        );
      },
    ),

    // ==================== ORDERS ====================
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderTracking,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderTrackingScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.orderSuccess,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final orderId = extra?['orderId'] as String? ?? '';
        final orderNumber = extra?['orderNumber'] as String?;
        final estimatedTime = extra?['estimatedDeliveryTime'] as DateTime?;
        return OrderSuccessScreen(
          orderId: orderId,
          orderNumber: orderNumber,
          estimatedDeliveryTime: estimatedTime,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderIssue,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final order = extra?['order'] as Order?;
        if (order == null) {
          return const ErrorScreen(error: null);
        }
        return OrderIssueScreen(order: order);
      },
    ),
    GoRoute(
      path: AppRoutes.reorder,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final order = extra?['order'] as Order?;
        if (order == null) {
          return const ErrorScreen(error: null);
        }
        return ReorderScreen(order: order);
      },
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

    // ==================== PROFILE & SETTINGS ====================
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
      path: AppRoutes.paymentMethods,
      builder: (context, state) => const PaymentMethodsScreen(),
    ),

    // ==================== CHAT & SUPPORT ====================
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatsScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ChatScreen(
          chatId: chatId,
          orderId: extra?['orderId'],
          chatType: extra?['chatType'],
          orderNumber: extra?['orderNumber'],
        );
      },
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (context, state) => const ChatSupportScreen(),
    ),
    GoRoute(
      path: '/chat/support',
      builder: (context, state) => const ChatSupportScreen(),
    ),

    // ==================== LEGAL & HELP ====================
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => const TermsScreen(),
    ),

    // ==================== PAYMENT ====================
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentWebViewScreen(
          paymentUrl: extra?['paymentUrl'] ?? '',
          orderId: extra?['orderId'] ?? '',
          isWalletTopup: extra?['isWalletTopup'] ?? false,
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

/// Placeholder screen for routes that are not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'هذه الصفحة قيد التطوير',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for navigation
extension NavigationExtensions on BuildContext {
  /// Navigate to restaurant details
  void goToRestaurant(String slug) {
    go('/restaurant/$slug');
  }

  /// Navigate to order tracking
  void goToOrderTracking(String orderId) {
    go('/order/$orderId');
  }

  /// Navigate to order details
  void goToOrderDetails(String orderId) {
    go('/orders/$orderId');
  }

  /// Navigate to rate order
  void goToRateOrder(String orderId, {String? restaurantName, String? driverName}) {
    go(
      '/orders/$orderId/rate',
      extra: {
        'restaurantName': restaurantName ?? '',
        'driverName': driverName,
      },
    );
  }

  /// Navigate to category restaurants
  void goToCategory(String categoryId, {String? name}) {
    push(
      '/category/$categoryId',
      extra: {'name': name ?? categoryId},
    );
  }

  /// Navigate to cuisine restaurants
  void goToCuisine(String cuisineId, {String? name}) {
    push(
      '/cuisine/$cuisineId',
      extra: {'name': name ?? cuisineId},
    );
  }

  /// Navigate to chat
  void goToChat(String chatId, {String? name}) {
    push(
      '/chat/$chatId',
      extra: {'name': name},
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
