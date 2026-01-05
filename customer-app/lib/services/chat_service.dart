import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatService(apiService);
});

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// Get user's chat list
  Future<ChatsListResponse> getChats({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/chats',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        return ChatsListResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب المحادثات');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب المحادثات',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get or create chat for an order
  Future<Chat> getOrCreateChat({
    required String orderId,
    required String chatType, // 'customer_restaurant' or 'customer_driver'
  }) async {
    try {
      final response = await _apiService.get(
        '/chats/order/$orderId',
        queryParameters: {
          'chatType': chatType,
        },
      );

      if (response.data['success']) {
        return Chat.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب المحادثة');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب المحادثة',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get chat messages
  Future<MessagesResponse> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/chats/$chatId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        return MessagesResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب الرسائل');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب الرسائل',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Send a message
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    String? imageUrl,
    double? lat,
    double? lng,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'content': content,
        'type': type,
      };

      if (imageUrl != null) {
        data['imageUrl'] = imageUrl;
      }

      if (lat != null && lng != null) {
        data['location'] = {
          'lat': lat,
          'lng': lng,
        };
      }

      final response = await _apiService.post(
        '/chats/$chatId/messages',
        data: data,
      );

      if (response.data['success']) {
        return ChatMessage.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل إرسال الرسالة');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء إرسال الرسالة',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Mark chat as read
  Future<void> markAsRead(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/read');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/chats/unread-count');

      if (response.data['success']) {
        return response.data['data']['unreadCount'] as int;
      } else {
        return 0;
      }
    } catch (_) {
      return 0;
    }
  }

  /// Upload image for chat
  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'folder': 'chats',
      });

      final response = await _apiService.post(
        '/upload/image',
        data: formData,
      );

      if (response.data['success']) {
        return response.data['data']['url'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'فشل رفع الصورة');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء رفع الصورة',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }
}

/// Chat Model
class Chat {
  final String id;
  final String orderId;
  final String chatType;
  final ChatParticipants participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final bool isActive;
  final int unreadCount;
  final OrderInfo? order;

  Chat({
    required this.id,
    required this.orderId,
    required this.chatType,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    required this.isActive,
    this.unreadCount = 0,
    this.order,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] as String,
      orderId: json['orderId'] is Map
          ? json['orderId']['_id'] as String
          : json['orderId'] as String,
      chatType: json['chatType'] as String,
      participants: ChatParticipants.fromJson(
        json['participants'] as Map<String, dynamic>,
      ),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastMessageBy: json['lastMessageBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      unreadCount: json['unreadCount'] as int? ?? 0,
      order: json['orderId'] is Map
          ? OrderInfo.fromJson(json['orderId'] as Map<String, dynamic>)
          : null,
    );
  }

  String get chatTypeLabel {
    switch (chatType) {
      case 'customer_restaurant':
        return 'محادثة مع المطعم';
      case 'customer_driver':
        return 'محادثة مع السائق';
      default:
        return 'محادثة';
    }
  }
}

/// Chat Participants
class ChatParticipants {
  final String? customerId;
  final String? restaurantId;
  final String? driverId;

  ChatParticipants({
    this.customerId,
    this.restaurantId,
    this.driverId,
  });

  factory ChatParticipants.fromJson(Map<String, dynamic> json) {
    return ChatParticipants(
      customerId: json['customerId'] as String?,
      restaurantId: json['restaurantId'] as String?,
      driverId: json['driverId'] as String?,
    );
  }
}

/// Order Info (for chat list)
class OrderInfo {
  final String id;
  final String orderNumber;
  final String status;

  OrderInfo({
    required this.id,
    required this.orderNumber,
    required this.status,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

/// Chat Message Model
class ChatMessage {
  final String? id;
  final String sender;
  final String senderRole;
  final String content;
  final String type;
  final String? imageUrl;
  final MessageLocation? location;
  final bool isRead;
  final DateTime createdAt;
  final bool isSending;

  ChatMessage({
    this.id,
    required this.sender,
    required this.senderRole,
    required this.content,
    this.type = 'text',
    this.imageUrl,
    this.location,
    this.isRead = false,
    required this.createdAt,
    this.isSending = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as String?,
      sender: json['sender'] as String,
      senderRole: json['senderRole'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] != null
          ? MessageLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? senderRole,
    String? content,
    String? type,
    String? imageUrl,
    MessageLocation? location,
    bool? isRead,
    DateTime? createdAt,
    bool? isSending,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Message Location
class MessageLocation {
  final double lat;
  final double lng;

  MessageLocation({
    required this.lat,
    required this.lng,
  });

  factory MessageLocation.fromJson(Map<String, dynamic> json) {
    return MessageLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

/// Chats List Response
class ChatsListResponse {
  final List<Chat> chats;
  final int total;
  final int page;
  final int pages;

  ChatsListResponse({
    required this.chats,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ChatsListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> chatsData = json['chats'] as List<dynamic>;

    return ChatsListResponse(
      chats: chatsData
          .map((c) => Chat.fromJson(c as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
    );
  }
}

/// Messages Response
class MessagesResponse {
  final List<ChatMessage> messages;
  final int total;
  final int page;
  final int pages;

  MessagesResponse({
    required this.messages,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messagesData = json['messages'] as List<dynamic>;

    return MessagesResponse(
      messages: messagesData
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
    );
  }
}
