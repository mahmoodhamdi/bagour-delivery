import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/routes.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
  // Background messages are handled automatically by the system
}

/// Notification types from backend
class NotificationType {
  static const String orderConfirmed = 'order_confirmed';
  static const String orderPreparing = 'order_preparing';
  static const String orderReady = 'order_ready';
  static const String driverAssigned = 'driver_assigned';
  static const String orderPickedUp = 'order_picked_up';
  static const String orderOnTheWay = 'order_on_the_way';
  static const String orderDelivered = 'order_delivered';
  static const String orderCancelled = 'order_cancelled';
  static const String promotion = 'promotion';
  static const String system = 'system';
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;
  BuildContext? _context;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Notification channel for Android - Order updates
  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'bagour_order_channel',
    'Order Updates',
    description: 'Notifications for order status updates',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Notification channel for promotions
  static const AndroidNotificationChannel _promoChannel =
      AndroidNotificationChannel(
    'bagour_promo_channel',
    'Promotions',
    description: 'Special offers and promotions',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  // Notification channel for system messages
  static const AndroidNotificationChannel _systemChannel =
      AndroidNotificationChannel(
    'bagour_system_channel',
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

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
      onTokenRefresh?.call(token);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
      onMessageReceived?.call(message);
    });

    // Handle when app is opened from notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('App opened from notification: ${message.data}');
      _handleNotificationNavigation(message.data);
      onMessageOpenedApp?.call(message);
    });

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial message: ${initialMessage.data}');
      // Delay navigation slightly to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationNavigation(initialMessage.data);
        onMessageOpenedApp?.call(initialMessage);
      });
    }

    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImpl?.createNotificationChannel(_orderChannel);
      await androidImpl?.createNotificationChannel(_promoChannel);
      await androidImpl?.createNotificationChannel(_systemChannel);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
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

    // Order-related notifications
    if (orderId != null && _isOrderNotification(type)) {
      _context!.push('/order/$orderId');
      return;
    }

    // Handle specific notification types
    switch (type) {
      case NotificationType.promotion:
        final restaurantId = data['restaurantId'];
        if (restaurantId != null) {
          _context!.push('/restaurant/$restaurantId');
        } else {
          _context!.push(AppRoutes.home);
        }
        break;
      case NotificationType.system:
        _context!.push(AppRoutes.notifications);
        break;
      default:
        // For any other notification, go to notifications screen
        _context!.push(AppRoutes.notifications);
    }
  }

  bool _isOrderNotification(String type) {
    return type == NotificationType.orderConfirmed ||
        type == NotificationType.orderPreparing ||
        type == NotificationType.orderReady ||
        type == NotificationType.driverAssigned ||
        type == NotificationType.orderPickedUp ||
        type == NotificationType.orderOnTheWay ||
        type == NotificationType.orderDelivered ||
        type == NotificationType.orderCancelled ||
        type.startsWith('order_');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? data['action'] ?? '';

    // Determine which channel to use based on notification type
    AndroidNotificationChannel channel;
    if (_isOrderNotification(type)) {
      channel = _orderChannel;
    } else if (type == NotificationType.promotion) {
      channel = _promoChannel;
    } else {
      channel = _systemChannel;
    }

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: _isOrderNotification(type) ? Priority.high : Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF5722), // Brand color
      largeIcon: notification.android?.imageUrl != null
          ? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
          : null,
      styleInformation: notification.body != null && notification.body!.length > 50
          ? BigTextStyleInformation(notification.body!)
          : null,
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
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Subscribe to user-specific topic
  Future<void> subscribeToUserTopic(String userId) async {
    await _messaging.subscribeToTopic('user_$userId');
    debugPrint('Subscribed to user topic: user_$userId');
  }

  /// Unsubscribe from user-specific topic
  Future<void> unsubscribeFromUserTopic(String userId) async {
    await _messaging.unsubscribeFromTopic('user_$userId');
    debugPrint('Unsubscribed from user topic: user_$userId');
  }

  /// Subscribe to general promotions topic
  Future<void> subscribeToPromotions() async {
    await _messaging.subscribeToTopic('promotions');
    debugPrint('Subscribed to promotions topic');
  }

  /// Unsubscribe from promotions topic
  Future<void> unsubscribeFromPromotions() async {
    await _messaging.unsubscribeFromTopic('promotions');
    debugPrint('Unsubscribed from promotions topic');
  }

  /// Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Clear a specific notification
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Get notification permission status
  Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get the current FCM token (refresh if needed)
  Future<String?> getToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  /// Delete the FCM token (useful for logout)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
  }

  /// Show a local notification programmatically
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
  }) async {
    final channel = channelId == 'promo'
        ? _promoChannel
        : channelId == 'system'
            ? _systemChannel
            : _orderChannel;

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
}
