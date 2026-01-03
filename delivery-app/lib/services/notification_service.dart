import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
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

  String? get fcmToken => _fcmToken;

  // Notification channel for Android - High importance for driver orders
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bagour_driver_channel',
    'Bagour Driver',
    description: 'New order notifications and delivery updates',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Separate channel for order alerts
  static const AndroidNotificationChannel _orderChannel = AndroidNotificationChannel(
    'bagour_driver_orders',
    'New Orders',
    description: 'Alerts for new available orders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  Future<void> initialize({
    Function(String?)? onTokenRefresh,
    Function(RemoteMessage)? onMessageReceived,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_isInitialized) return;

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('App opened from notification: ${message.data}');
      onMessageOpenedApp?.call(message);
    });

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial message: ${initialMessage.data}');
      onMessageOpenedApp?.call(initialMessage);
    }

    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Critical for driver app
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

      await androidImpl?.createNotificationChannel(_channel);
      await androidImpl?.createNotificationChannel(_orderChannel);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to relevant screen
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Use order channel for order notifications
    final isOrderNotification = message.data['type'] == 'order' ||
        message.data['action']?.contains('order') == true;

    final channelId = isOrderNotification ? _orderChannel.id : _channel.id;
    final channelName = isOrderNotification ? _orderChannel.name : _channel.name;
    final channelDesc = isOrderNotification ? _orderChannel.description : _channel.description;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: isOrderNotification, // Full screen for new orders
      category: isOrderNotification
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.message,
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
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Subscribe to driver-specific topics
  Future<void> subscribeToDriverTopics(String driverId) async {
    await _messaging.subscribeToTopic('drivers');
    await _messaging.subscribeToTopic('driver_$driverId');
    debugPrint('Subscribed to driver topics');
  }

  // Unsubscribe from driver topics
  Future<void> unsubscribeFromDriverTopics(String driverId) async {
    await _messaging.unsubscribeFromTopic('drivers');
    await _messaging.unsubscribeFromTopic('driver_$driverId');
    debugPrint('Unsubscribed from driver topics');
  }

  // Subscribe to zone topic for nearby orders
  Future<void> subscribeToZone(String zoneId) async {
    await _messaging.subscribeToTopic('zone_$zoneId');
    debugPrint('Subscribed to zone: $zoneId');
  }

  // Unsubscribe from zone topic
  Future<void> unsubscribeFromZone(String zoneId) async {
    await _messaging.unsubscribeFromTopic('zone_$zoneId');
    debugPrint('Unsubscribed from zone: $zoneId');
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get notification permission status
  Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
