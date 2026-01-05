import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/routes.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
  // Background messages are handled automatically by the system
}

/// Notification types for restaurant app
class NotificationType {
  // Order notifications
  static const String newOrder = 'new_order';
  static const String orderCancelled = 'order_cancelled';
  static const String orderPickedUp = 'order_picked_up';

  // Restaurant-specific
  static const String restaurantApproved = 'restaurant_approved';
  static const String restaurantRejected = 'restaurant_rejected';
  static const String menuItemOutOfStock = 'menu_item_out_of_stock';

  // Reviews
  static const String newReview = 'new_review';
  static const String reviewResponse = 'review_response';

  // Earnings
  static const String earningsUpdate = 'earnings_update';
  static const String payoutProcessed = 'payout_processed';

  // System
  static const String system = 'system';
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  String? _fcmToken;
  BuildContext? _context;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Notification channel for new orders - HIGH IMPORTANCE
  static const AndroidNotificationChannel _newOrderChannel =
      AndroidNotificationChannel(
    'bagour_restaurant_new_orders',
    'New Orders',
    description: 'Alerts for new incoming orders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Notification channel for order updates
  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'bagour_restaurant_orders',
    'Order Updates',
    description: 'Updates for existing orders',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // Notification channel for reviews
  static const AndroidNotificationChannel _reviewChannel =
      AndroidNotificationChannel(
    'bagour_restaurant_reviews',
    'Reviews',
    description: 'Customer reviews and ratings',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  // Notification channel for earnings
  static const AndroidNotificationChannel _earningsChannel =
      AndroidNotificationChannel(
    'bagour_restaurant_earnings',
    'Earnings',
    description: 'Earnings and payout updates',
    importance: Importance.defaultImportance,
  );

  // Notification channel for system messages
  static const AndroidNotificationChannel _systemChannel =
      AndroidNotificationChannel(
    'bagour_restaurant_system',
    'System Notifications',
    description: 'System messages and updates',
    importance: Importance.low,
  );

  /// Set the navigation context for handling notification taps
  void setNavigationContext(BuildContext context) {
    _context = context;
  }

  /// Initialize the notification service
  Future<void> initialize({
    Function(String?)? onTokenRefresh,
    Function(RemoteMessage)? onMessageReceived,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_isInitialized) return;

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission with critical alerts for new orders
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Critical for new orders
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      _fcmToken = await _fcm.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM Token refreshed: $token');
        onTokenRefresh?.call(token);
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Foreground message: ${message.notification?.title}');
        _handleForegroundMessage(message);
        onMessageReceived?.call(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('App opened from notification: ${message.data}');
        _handleNotificationNavigation(message.data);
        onMessageOpenedApp?.call(message);
      });

      // Check if app was opened from a notification
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Initial message: ${initialMessage.data}');
        // Delay navigation to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationNavigation(initialMessage.data);
          onMessageOpenedApp?.call(initialMessage);
        });
      }
    }

    _isInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_newOrderChannel);
        await androidPlugin.createNotificationChannel(_orderChannel);
        await androidPlugin.createNotificationChannel(_reviewChannel);
        await androidPlugin.createNotificationChannel(_earningsChannel);
        await androidPlugin.createNotificationChannel(_systemChannel);
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final type = data['type'] ?? data['action'] ?? '';

      // Play sound for new orders
      if (type == NotificationType.newOrder) {
        _playOrderSound();
      }

      // Show local notification
      _showLocalNotification(message);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (_context == null) {
      debugPrint('Navigation context not set');
      return;
    }

    final type = data['type'] ?? data['action'] ?? '';
    final orderId = data['orderId'];

    debugPrint('Navigating for notification type: $type, orderId: $orderId');

    switch (type) {
      case NotificationType.newOrder:
        // Navigate to orders screen or order details
        if (orderId != null) {
          _context!.go('/orders/$orderId');
        } else {
          _context!.go(AppRoutes.orders);
        }
        break;

      case NotificationType.orderCancelled:
      case NotificationType.orderPickedUp:
        // Navigate to order details
        if (orderId != null) {
          _context!.go('/orders/$orderId');
        } else {
          _context!.go(AppRoutes.orders);
        }
        break;

      case NotificationType.newReview:
      case NotificationType.reviewResponse:
        // Navigate to reviews screen
        _context!.go(AppRoutes.reviews);
        break;

      case NotificationType.earningsUpdate:
      case NotificationType.payoutProcessed:
        // Navigate to earnings screen
        _context!.go(AppRoutes.earnings);
        break;

      case NotificationType.restaurantApproved:
      case NotificationType.restaurantRejected:
        // Navigate to profile/dashboard
        _context!.go(AppRoutes.dashboard);
        break;

      case NotificationType.menuItemOutOfStock:
        // Navigate to menu screen
        _context!.go(AppRoutes.menu);
        break;

      default:
        // For any other notification, go to notifications screen
        _context!.go(AppRoutes.notifications);
    }
  }

  bool _isNewOrderNotification(String type) {
    return type == NotificationType.newOrder;
  }

  bool _isOrderNotification(String type) {
    return type == NotificationType.newOrder ||
        type == NotificationType.orderCancelled ||
        type == NotificationType.orderPickedUp;
  }

  bool _isReviewNotification(String type) {
    return type == NotificationType.newReview ||
        type == NotificationType.reviewResponse;
  }

  bool _isEarningsNotification(String type) {
    return type == NotificationType.earningsUpdate ||
        type == NotificationType.payoutProcessed;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? data['action'] ?? '';

    // Determine which channel to use
    AndroidNotificationChannel channel;
    Priority priority;
    bool fullScreenIntent = false;
    AndroidNotificationCategory? category;

    if (_isNewOrderNotification(type)) {
      channel = _newOrderChannel;
      priority = Priority.max;
      fullScreenIntent = true; // Wake up device for new orders
      category = AndroidNotificationCategory.alarm;
    } else if (_isOrderNotification(type)) {
      channel = _orderChannel;
      priority = Priority.high;
      category = AndroidNotificationCategory.message;
    } else if (_isReviewNotification(type)) {
      channel = _reviewChannel;
      priority = Priority.defaultPriority;
    } else if (_isEarningsNotification(type)) {
      channel = _earningsChannel;
      priority = Priority.defaultPriority;
    } else {
      channel = _systemChannel;
      priority = Priority.defaultPriority;
    }

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: priority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFE91E63), // Pink for restaurant app
      fullScreenIntent: fullScreenIntent,
      category: category,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: notification.body != null && notification.body!.length > 50
          ? BigTextStyleInformation(notification.body!)
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: _isNewOrderNotification(type)
          ? InterruptionLevel.critical
          : InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Play sound for new orders
  Future<void> _playOrderSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/new_order.mp3'));
    } catch (e) {
      debugPrint('Error playing order sound: $e');
    }
  }

  /// Stop the order sound
  Future<void> stopOrderSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping order sound: $e');
    }
  }

  /// Subscribe to restaurant-specific topic
  Future<void> subscribeToRestaurantTopic(String restaurantId) async {
    await _fcm.subscribeToTopic('restaurant_$restaurantId');
    await _fcm.subscribeToTopic('restaurants');
    debugPrint('Subscribed to restaurant topics: restaurant_$restaurantId, restaurants');
  }

  /// Unsubscribe from restaurant-specific topic
  Future<void> unsubscribeFromRestaurantTopic(String restaurantId) async {
    await _fcm.unsubscribeFromTopic('restaurant_$restaurantId');
    await _fcm.unsubscribeFromTopic('restaurants');
    debugPrint('Unsubscribed from restaurant topics');
  }

  /// Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Clear all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Clear a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Get notification permission status
  Future<bool> hasPermission() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get the current FCM token (refresh if needed)
  Future<String?> getToken() async {
    _fcmToken = await _fcm.getToken();
    return _fcmToken;
  }

  /// Delete the FCM token (useful for logout)
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    _fcmToken = null;
  }

  /// Show a new order notification programmatically
  Future<void> showNewOrderNotification({
    required String title,
    required String body,
    required String orderId,
    String? orderNumber,
    String? customerName,
    String? total,
  }) async {
    // Play order sound
    _playOrderSound();

    final data = {
      'type': NotificationType.newOrder,
      'orderId': orderId,
      if (orderNumber != null) 'orderNumber': orderNumber,
      if (customerName != null) 'customerName': customerName,
      if (total != null) 'total': total,
    };

    final androidDetails = AndroidNotificationDetails(
      _newOrderChannel.id,
      _newOrderChannel.name,
      channelDescription: _newOrderChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFE91E63),
      category: AndroidNotificationCategory.alarm,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Show a local notification programmatically
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    bool playSound = false,
  }) async {
    AndroidNotificationChannel channel;
    if (channelId == 'new_order') {
      channel = _newOrderChannel;
      if (playSound) _playOrderSound();
    } else if (channelId == 'order') {
      channel = _orderChannel;
    } else if (channelId == 'review') {
      channel = _reviewChannel;
    } else if (channelId == 'earnings') {
      channel = _earningsChannel;
    } else {
      channel = _systemChannel;
    }

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
