import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import 'order_provider.dart' show apiServiceProvider;

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification state
class NotificationState {
  final bool isInitialized;
  final String? fcmToken;
  final int unreadCount;
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.isInitialized = false,
    this.fcmToken,
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    bool? isInitialized,
    String? fcmToken,
    int? unreadCount,
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['titleAr'] ?? json['title'] ?? '',
      body: json['body'] ?? '',
      bodyAr: json['bodyAr'] ?? json['body'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      data: json['data'],
    );
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final ApiService _apiService;

  NotificationNotifier(this._notificationService, this._apiService)
      : super(const NotificationState());

  Future<void> initialize({String? driverId}) async {
    if (state.isInitialized) return;

    try {
      await _notificationService.initialize(
        onTokenRefresh: _onTokenRefresh,
        onMessageReceived: _onMessageReceived,
        onMessageOpenedApp: _onMessageOpenedApp,
      );

      state = state.copyWith(
        isInitialized: true,
        fcmToken: _notificationService.fcmToken,
      );

      // Register token with backend
      await _registerToken();

      // Subscribe to driver topics
      if (driverId != null) {
        await _notificationService.subscribeToDriverTopics(driverId);
      }

      // Fetch initial notifications
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _registerToken() async {
    final token = _notificationService.fcmToken;
    if (token == null) return;

    try {
      await _apiService.post(
        ApiEndpoints.registerFcm,
        data: {'token': token},
      );
    } catch (e) {
      // Silently fail - token registration is not critical
    }
  }

  void _onTokenRefresh(String? token) async {
    if (token != null) {
      state = state.copyWith(fcmToken: token);
      await _registerToken();
    }
  }

  void _onMessageReceived(RemoteMessage message) {
    // Refresh notifications and unread count
    fetchNotifications();
    fetchUnreadCount();
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('orderId')) {
      // Navigate to order details
    }
  }

  Future<void> fetchNotifications({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiService.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': 20},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final items = (data['data'] as List)
            .map((json) => NotificationItem.fromJson(json))
            .toList();

        state = state.copyWith(
          notifications: page == 1 ? items : [...state.notifications, ...items],
          unreadCount: data['unreadCount'] ?? 0,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.notifications}/unread-count',
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          unreadCount: response.data['data']['count'] ?? 0,
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '${ApiEndpoints.notifications}/$notificationId/read',
      );

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationItem(
            id: n.id,
            title: n.title,
            titleAr: n.titleAr,
            body: n.body,
            bodyAr: n.bodyAr,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            data: n.data,
          );
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.put(
        '${ApiEndpoints.notifications}/read-all',
      );

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        return NotificationItem(
          id: n.id,
          title: n.title,
          titleAr: n.titleAr,
          body: n.body,
          bodyAr: n.bodyAr,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> unregisterToken() async {
    final token = _notificationService.fcmToken;
    if (token == null) return;

    try {
      await _apiService.delete(
        ApiEndpoints.registerFcm,
        data: {'token': token},
      );
    } catch (e) {
      // Silently fail
    }
  }
}

// Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return NotificationNotifier(notificationService, apiService);
});

// Unread count provider for easy access
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
