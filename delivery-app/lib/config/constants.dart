class AppConstants {
  // App Info
  static const String appName = 'Bagour Delivery Driver';
  static const String appNameAr = 'باجور ديليفري - السائق';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String socketUrl = 'http://localhost:5000';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String driverDataKey = 'driver_data';
  static const String isOnlineKey = 'is_online';
  static const String lastLocationKey = 'last_location';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Pagination
  static const int defaultPageSize = 20;
  static const int ordersPageSize = 15;

  // Location
  static const double bagourLat = 30.4500;
  static const double bagourLng = 30.9667;
  static const double defaultZoom = 15.0;
  static const int locationUpdateInterval = 10; // seconds
  static const double locationDistanceFilter = 10; // meters

  // Order Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'picked_up',
    'on_the_way',
    'delivered',
    'cancelled',
  ];

  // Driver-specific statuses
  static const List<String> driverOrderStatuses = [
    'ready',
    'picked_up',
    'on_the_way',
    'delivered',
  ];

  // Timeouts
  static const Duration orderAcceptTimeout = Duration(seconds: 60);
  static const Duration locationStreamInterval = Duration(seconds: 5);

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int phoneLength = 11;
  static const String egyptPhonePrefix = '01';

  // Vehicle Types
  static const List<String> vehicleTypes = [
    'motorcycle',
    'bicycle',
    'car',
  ];

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 5);
}

class ApiEndpoints {
  // Auth - Unified Registration & Login
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleSignIn = '/auth/google';

  // Email Verification
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';

  // Password Management
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Token & Session
  static const String refreshToken = '/auth/refresh-token';
  static const String fcmToken = '/auth/fcm-token';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Driver Profile
  static const String driverProfile = '/drivers/profile';
  static const String updateProfile = '/drivers/profile';
  static const String updateLocation = '/drivers/location';
  static const String toggleOnline = '/drivers/toggle-online';
  static const String uploadDocuments = '/drivers/documents';
  static const String updateVehicle = '/drivers/vehicle';

  // Orders
  static const String availableOrders = '/drivers/orders/available';
  static const String acceptOrder = '/drivers/orders/accept';
  static const String rejectOrder = '/drivers/orders/reject';
  static const String currentOrder = '/drivers/orders/current';
  static const String orderHistory = '/drivers/orders/history';
  static const String updateOrderStatus = '/drivers/orders/status';

  // Earnings
  static const String earnings = '/drivers/earnings';
  static const String earningsSummary = '/drivers/earnings/summary';
  static const String withdrawalRequests = '/drivers/withdrawals';
  static const String requestWithdrawal = '/drivers/withdrawals/request';

  // Notifications
  static const String notifications = '/drivers/notifications';
  static const String markNotificationRead = '/drivers/notifications/read';
  static const String registerFcm = '/drivers/fcm-token';

  // Settings
  static const String settings = '/settings';
}

class AssetPaths {
  // Images
  static const String imagesPath = 'assets/images';
  static const String logo = '$imagesPath/logo.png';
  static const String logoWhite = '$imagesPath/logo_white.png';
  static const String placeholder = '$imagesPath/placeholder.png';
  static const String noOrders = '$imagesPath/no_orders.png';
  static const String noInternet = '$imagesPath/no_internet.png';
  static const String deliveryBike = '$imagesPath/delivery_bike.png';

  // Icons
  static const String iconsPath = 'assets/icons';
  static const String orderIcon = '$iconsPath/order.svg';
  static const String walletIcon = '$iconsPath/wallet.svg';
  static const String locationIcon = '$iconsPath/location.svg';
  static const String phoneIcon = '$iconsPath/phone.svg';
  static const String navigationIcon = '$iconsPath/navigation.svg';

  // Animations
  static const String animationsPath = 'assets/animations';
  static const String loadingAnimation = '$animationsPath/loading.json';
  static const String successAnimation = '$animationsPath/success.json';
  static const String newOrderAnimation = '$animationsPath/new_order.json';
  static const String deliveredAnimation = '$animationsPath/delivered.json';
  static const String emptyAnimation = '$animationsPath/empty.json';
}
