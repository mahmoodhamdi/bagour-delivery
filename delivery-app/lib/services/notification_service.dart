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

/// Notification types for driver app
class NotificationType {
  // New delivery notifications
  static const String newDeliveryAvailable = 'new_delivery_available';
  static const String orderAssigned = 'order_assigned';

  // Order status updates
  static const String orderReady = 'order_ready';
  static const String orderCancelled = 'order_cancelled';

  // Driver-specific
  static const String earningsUpdate = 'earnings_update';
  static const String withdrawalApproved = 'withdrawal_approved';
  static const String withdrawalRejected = 'withdrawal_rejected';
  static const String accountApproved = 'account_approved';
  static const String accountRejected = 'account_rejected';
  static const String documentVerified = 'document_verified';
  static const String documentRejected = 'document_rejected';

  // System
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

  // Notification channel for new orders - HIGH IMPORTANCE
  static const AndroidNotificationChannel _newOrderChannel =
      AndroidNotificationChannel(
    'bagour_driver_new_orders',
    'New Orders',
    description: 'Alerts for new available delivery orders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Notification channel for order updates
  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'bagour_driver_orders',
    'Order Updates',
    description: 'Updates for your current deliveries',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Notification channel for earnings
  static const AndroidNotificationChannel _earningsChannel =
      AndroidNotificationChannel(
    'bagour_driver_earnings',
    'Earnings',
    description: 'Earnings and withdrawal updates',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  // Notification channel for system/account
  static const AndroidNotificationChannel _systemChannel =
      AndroidNotificationChannel(
    'bagour_driver_system',
    'System Notifications',
    description: 'Account and system updates',
    importance: Importance.defaultImportance,
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
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Critical for new delivery alerts
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
      requestCriticalPermission: true,
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

      await androidImpl?.createNotificationChannel(_newOrderChannel);
      await androidImpl?.createNotificationChannel(_orderChannel);
      await androidImpl?.createNotificationChannel(_earningsChannel);
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

    switch (type) {
      case NotificationType.newDeliveryAvailable:
        // Navigate to available orders screen
        _context!.go(AppRoutes.orders);
        break;

      case NotificationType.orderAssigned:
      case NotificationType.orderReady:
        // Navigate to active delivery screen
        if (orderId != null) {
          _context!.go('/orders/$orderId');
        } else {
          _context!.go(AppRoutes.activeOrder);
        }
        break;

      case NotificationType.orderCancelled:
        // Navigate to order history or available orders
        _context!.go(AppRoutes.orders);
        break;

      case NotificationType.earningsUpdate:
      case NotificationType.withdrawalApproved:
      case NotificationType.withdrawalRejected:
        // Navigate to earnings screen
        _context!.go(AppRoutes.earnings);
        break;

      case NotificationType.accountApproved:
      case NotificationType.accountRejected:
      case NotificationType.documentVerified:
      case NotificationType.documentRejected:
        // Navigate to profile/documents screen
        _context!.go(AppRoutes.documents);
        break;

      default:
        // For any other notification, go to notifications screen
        _context!.go(AppRoutes.notifications);
    }
  }

  bool _isNewOrderNotification(String type) {
    return type == NotificationType.newDeliveryAvailable ||
        type == NotificationType.orderAssigned;
  }

  bool _isOrderNotification(String type) {
    return type == NotificationType.orderReady ||
        type == NotificationType.orderCancelled ||
        _isNewOrderNotification(type);
  }

  bool _isEarningsNotification(String type) {
    return type == NotificationType.earningsUpdate ||
        type == NotificationType.withdrawalApproved ||
        type == NotificationType.withdrawalRejected;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? data['action'] ?? '';

    // Determine which channel to use based on notification type
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
      color: const Color(0xFF4CAF50), // Green for driver app
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
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Subscribe to driver-specific topics
  Future<void> subscribeToDriverTopics(String driverId) async {
    await _messaging.subscribeToTopic('drivers');
    await _messaging.subscribeToTopic('driver_$driverId');
    debugPrint('Subscribed to driver topics: drivers, driver_$driverId');
  }

  /// Unsubscribe from driver topics
  Future<void> unsubscribeFromDriverTopics(String driverId) async {
    await _messaging.unsubscribeFromTopic('drivers');
    await _messaging.unsubscribeFromTopic('driver_$driverId');
    debugPrint('Unsubscribed from driver topics');
  }

  /// Subscribe to zone topic for nearby orders
  Future<void> subscribeToZone(String zoneId) async {
    await _messaging.subscribeToTopic('zone_$zoneId');
    debugPrint('Subscribed to zone: $zoneId');
  }

  /// Unsubscribe from zone topic
  Future<void> unsubscribeFromZone(String zoneId) async {
    await _messaging.unsubscribeFromTopic('zone_$zoneId');
    debugPrint('Unsubscribed from zone: $zoneId');
  }

  /// Subscribe to available orders topic (when driver goes online)
  Future<void> subscribeToAvailableOrders() async {
    await _messaging.subscribeToTopic('available_orders');
    debugPrint('Subscribed to available orders');
  }

  /// Unsubscribe from available orders topic (when driver goes offline)
  Future<void> unsubscribeFromAvailableOrders() async {
    await _messaging.unsubscribeFromTopic('available_orders');
    debugPrint('Unsubscribed from available orders');
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
      criticalAlert: true,
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

  /// Show a new order notification programmatically
  Future<void> showNewOrderNotification({
    required String title,
    required String body,
    required String orderId,
    String? restaurantName,
    String? distance,
    String? earnings,
  }) async {
    final data = {
      'type': NotificationType.newDeliveryAvailable,
      'orderId': orderId,
      if (restaurantName != null) 'restaurantName': restaurantName,
      if (distance != null) 'distance': distance,
      if (earnings != null) 'earnings': earnings,
    };

    final androidDetails = AndroidNotificationDetails(
      _newOrderChannel.id,
      _newOrderChannel.name,
      channelDescription: _newOrderChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF4CAF50),
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
  }) async {
    AndroidNotificationChannel channel;
    if (channelId == 'new_order') {
      channel = _newOrderChannel;
    } else if (channelId == 'order') {
      channel = _orderChannel;
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
}
