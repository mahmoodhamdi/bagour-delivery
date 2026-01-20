class AppConstants {
  // API
  static const String apiBaseUrl = 'https://attempt-verbal-manor-wallet.trycloudflare.com/api/v1';
  static const String socketUrl = 'https://attempt-verbal-manor-wallet.trycloudflare.com';

  // App Info
  static const String appName = 'Bagour Delivery';
  static const String appNameAr = 'توصيل الباجور';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String languageKey = 'language';
  static const String cartKey = 'cart_data';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Maps
  static const double defaultLatitude = 30.4167;
  static const double defaultLongitude = 30.7133;
  static const double defaultZoom = 14.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int otpLength = 6;

  // Limits
  static const int maxCartItems = 50;
  static const int maxAddresses = 10;
  static const int maxImages = 5;

  // Durations
  static const int splashDuration = 2;
  static const int snackBarDuration = 3;

  // Support
  static const String supportPhone = '+201000000000';
  static const String supportEmail = 'support@bagour.com';
}

class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyCart = 'assets/images/empty_cart.png';
  static const String emptyOrders = 'assets/images/empty_orders.png';
  static const String noResults = 'assets/images/no_results.png';
  static const String error = 'assets/images/error.png';

  // Onboarding
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';

  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String deliveryAnimation = 'assets/animations/delivery.json';
}

class AppEndpoints {
  // Auth - Unified Registration & Login
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleSignIn = '/auth/google';

  // Auth - Email Verification
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';

  // Auth - Password Management
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Auth - Token Management
  static const String refreshToken = '/auth/refresh-token';
  static const String fcmToken = '/auth/fcm-token';

  // Auth - Profile & Session
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Restaurants
  static const String restaurants = '/restaurants';
  static const String searchRestaurants = '/restaurants/search';
  static const String nearbyRestaurants = '/restaurants/nearby';
  static const String categories = '/restaurants/categories';

  // Orders
  static const String orders = '/orders';
  static const String reorder = '/orders/{id}/reorder';
  static const String cancelOrder = '/orders/{id}/cancel';
  static const String rateOrder = '/orders/{id}/rate';

  // Customer
  static const String addresses = '/customer/addresses';
  static const String favorites = '/customer/favorites';

  // Coupons
  static const String couponValidate = '/coupons/validate';
  static const String couponsAvailable = '/coupons/available';

  // Payments
  static const String paymentInitiate = '/payment/initiate';
  static const String paymentWallet = '/payment/wallet';
  static const String paymentStatus = '/payment/status';

  // Settings
  static const String settings = '/settings/public';

  // Notifications
  static const String notifications = '/notifications';
}
