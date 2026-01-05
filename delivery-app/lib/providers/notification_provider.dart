import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

// Notification service provider (singleton)
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
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool isOnline;

  const NotificationState({
    this.isInitialized = false,
    this.fcmToken,
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.isOnline = false,
  });

  NotificationState copyWith({
    bool? isInitialized,
    String? fcmToken,
    int? unreadCount,
    List<NotificationItem>? notifications,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isOnline,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isOnline: isOnline ?? this.isOnline,
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
  final String? image;

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
    this.image,
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
      data: json['data'] as Map<String, dynamic>?,
      image: json['image'],
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
      image: image,
    );
  }

  /// Get localized title based on language
  String getTitle(String languageCode) {
    return languageCode == 'ar' ? titleAr : title;
  }

  /// Get localized body based on language
  String getBody(String languageCode) {
    return languageCode == 'ar' ? bodyAr : body;
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final ApiService _apiService;

  NotificationNotifier(this._notificationService, this._apiService)
      : super(const NotificationState());

  /// Initialize notifications - call this after driver login
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

      // Subscribe to driver topics if driverId provided
      if (driverId != null) {
        await _notificationService.subscribeToDriverTopics(driverId);
      }

      // Fetch initial notifications
      await fetchNotifications();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set navigation context for notification handling
  void setNavigationContext(BuildContext context) {
    _notificationService.setNavigationContext(context);
  }

  Future<void> _registerToken() async {
    final token = _notificationService.fcmToken;
    if (token == null) return;

    try {
      await _apiService.post(
        ApiEndpoints.registerFcm,
        data: {'token': token},
      );
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
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
    debugPrint('Notification received in provider: ${message.notification?.title}');
    // Refresh notifications and unread count
    fetchNotifications(refresh: true);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.data}');
    // Navigation is handled by NotificationService
  }

  /// Toggle online status - subscribes/unsubscribes from available orders
  Future<void> toggleOnlineStatus(bool isOnline) async {
    try {
      if (isOnline) {
        await _notificationService.subscribeToAvailableOrders();
      } else {
        await _notificationService.unsubscribeFromAvailableOrders();
      }
      state = state.copyWith(isOnline: isOnline);
    } catch (e) {
      debugPrint('Error toggling online status: $e');
    }
  }

  /// Subscribe to a specific zone for nearby orders
  Future<void> subscribeToZone(String zoneId) async {
    await _notificationService.subscribeToZone(zoneId);
  }

  /// Unsubscribe from a zone
  Future<void> unsubscribeFromZone(String zoneId) async {
    await _notificationService.unsubscribeFromZone(zoneId);
  }

  /// Fetch notifications from backend
  Future<void> fetchNotifications({int page = 1, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = state.copyWith(currentPage: 1, hasMore: true);
    }

    final targetPage = refresh ? 1 : page;
    if (targetPage == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiService.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': targetPage,
          'limit': AppConstants.defaultPageSize,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final items = (responseData['data'] as List)
            .map((json) => NotificationItem.fromJson(json))
            .toList();

        final total = responseData['total'] ?? 0;
        final hasMore = items.length >= AppConstants.defaultPageSize &&
            (targetPage * AppConstants.defaultPageSize) < total;

        state = state.copyWith(
          notifications: targetPage == 1
              ? items
              : [...state.notifications, ...items],
          unreadCount: responseData['unreadCount'] ?? 0,
          isLoading: false,
          hasMore: hasMore,
          currentPage: targetPage,
        );
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchNotifications(page: state.currentPage + 1);
  }

  /// Fetch unread count only
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
      debugPrint('Error fetching unread count: $e');
      // Silently fail
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '${ApiEndpoints.notifications}/$notificationId/read',
      );

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put(
        '${ApiEndpoints.notifications}/read-all',
      );

      // Update local state
      final updatedNotifications =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  /// Clear all local notifications
  Future<void> clearLocalNotifications() async {
    await _notificationService.clearAllNotifications();
  }

  /// Unregister FCM token (call on logout)
  Future<void> unregisterToken() async {
    final token = _notificationService.fcmToken;
    if (token == null) return;

    try {
      await _apiService.delete(
        ApiEndpoints.registerFcm,
        data: {'token': token},
      );
      await _notificationService.deleteToken();
      debugPrint('FCM token unregistered');
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }

  /// Cleanup on logout
  Future<void> cleanup({String? driverId}) async {
    if (driverId != null) {
      await _notificationService.unsubscribeFromDriverTopics(driverId);
    }
    await _notificationService.unsubscribeFromAvailableOrders();
    await unregisterToken();
    await clearLocalNotifications();

    state = const NotificationState();
  }
}

// API service provider (import from your actual location)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Main provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return NotificationNotifier(notificationService, apiService);
});

// Unread count provider for easy access in UI
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

// Loading state provider
final notificationsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).isLoading;
});

// Notifications list provider
final notificationsListProvider = Provider<List<NotificationItem>>((ref) {
  return ref.watch(notificationProvider).notifications;
});

// Has more provider for pagination
final notificationsHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).hasMore;
});

// Online status provider
final driverOnlineStatusProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).isOnline;
});
