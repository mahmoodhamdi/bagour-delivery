class AppConstants {
  static const String appName = 'Bagour Delivery - Restaurant';
  static const String appNameAr = 'توصيل الباجور - المطعم';

  // API
  static const String baseUrl = 'https://bagour-delivery.loca.lt/api/v1';
  static const String socketUrl = 'https://bagour-delivery.loca.lt';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String restaurantKey = 'restaurant';
  static const String onboardingKey = 'onboarding_completed';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Firebase
  static const String fcmTopicRestaurant = 'restaurant';

  // Order Statuses
  static const Map<String, String> orderStatusLabels = {
    'pending': 'في الانتظار',
    'confirmed': 'مؤكد',
    'preparing': 'قيد التحضير',
    'ready': 'جاهز',
    'picked_up': 'تم الاستلام',
    'on_the_way': 'في الطريق',
    'delivered': 'تم التوصيل',
    'cancelled': 'ملغي',
  };

  // Order Status Colors
  static const Map<String, int> orderStatusColors = {
    'pending': 0xFFFFA726,      // Orange
    'confirmed': 0xFF42A5F5,    // Blue
    'preparing': 0xFF7E57C2,    // Purple
    'ready': 0xFF26A69A,        // Teal
    'picked_up': 0xFF5C6BC0,    // Indigo
    'on_the_way': 0xFF29B6F6,   // Light Blue
    'delivered': 0xFF66BB6A,    // Green
    'cancelled': 0xFFEF5350,    // Red
  };

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;

  // Support
  static const String supportPhone = '+201234567890';
  static const String supportEmail = 'support@bagourdelivery.com';
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

  // Restaurant
  static const String restaurant = '/restaurant';
  static const String restaurantProfile = '/restaurant/profile';
  static const String restaurantSettings = '/restaurant/settings';
  static const String restaurantStatus = '/restaurant/status';

  // Menu
  static const String menuItems = '/restaurant/menu';
  static const String menuCategories = '/restaurant/categories';

  // Orders
  static const String orders = '/restaurant/orders';
  static const String orderStatus = '/restaurant/orders/{id}/status';

  // Earnings & Analytics
  static const String earnings = '/restaurant/earnings';
  static const String analytics = '/restaurants/analytics';
  static const String balance = '/restaurants/balance';
  static const String payouts = '/restaurants/payouts';

  // Reviews
  static const String reviews = '/restaurant/reviews';

  // Notifications
  static const String notifications = '/notifications';
}
