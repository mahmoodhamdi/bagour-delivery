import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

/// Chat State
class ChatState {
  final List<Chat> chats;
  final bool isLoading;
  final String? error;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;

  const ChatState({
    this.chats = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ChatState copyWith({
    List<Chat>? chats,
    bool? isLoading,
    String? error,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final SocketService _socketService;
  StreamSubscription? _messageSubscription;

  ChatNotifier(this._chatService, this._socketService) : super(const ChatState()) {
    _setupSocketListener();
  }

  void _setupSocketListener() {
    _messageSubscription = _socketService.onChatMessage.listen((data) {
      // Refresh chat list when new message arrives
      loadChats(refresh: true);
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  /// Load chat list
  Future<void> loadChats({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: page,
    );

    try {
      final response = await _chatService.getChats(page: page);

      state = state.copyWith(
        chats: refresh ? response.chats : [...state.chats, ...response.chats],
        isLoading: false,
        currentPage: page,
        hasMore: page < response.pages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Load more chats
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadChats();
  }

  /// Get unread count
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _chatService.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (_) {
      // Ignore errors
    }
  }

  /// Mark chat as read
  Future<void> markAsRead(String chatId) async {
    try {
      await _chatService.markAsRead(chatId);

      // Update local state
      final updatedChats = state.chats.map((chat) {
        if (chat.id == chatId) {
          return Chat(
            id: chat.id,
            orderId: chat.orderId,
            chatType: chat.chatType,
            participants: chat.participants,
            lastMessage: chat.lastMessage,
            lastMessageAt: chat.lastMessageAt,
            lastMessageBy: chat.lastMessageBy,
            isActive: chat.isActive,
            unreadCount: 0,
            order: chat.order,
          );
        }
        return chat;
      }).toList();

      state = state.copyWith(
        chats: updatedChats,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (_) {
      // Ignore errors
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Chat Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final socketService = ref.watch(socketServiceProvider);
  return ChatNotifier(chatService, socketService);
});

/// Unread count provider
final unreadChatCountProvider = Provider<int>((ref) {
  return ref.watch(chatProvider).unreadCount;
});

/// Active chat messages state
class ChatMessagesState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? chatId;

  const ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.chatId,
  });

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? chatId,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      chatId: chatId ?? this.chatId,
    );
  }
}

/// Chat Messages Notifier
class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatService _chatService;
  final SocketService _socketService;
  StreamSubscription? _messageSubscription;
  String? _currentUserId;

  ChatMessagesNotifier(this._chatService, this._socketService)
      : super(const ChatMessagesState());

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void _setupSocketListener(String chatId) {
    _messageSubscription?.cancel();
    _messageSubscription = _socketService.onChatMessage.listen((data) {
      final incomingChatId = data['chatId'] as String?;
      if (incomingChatId == chatId) {
        final messageData = data['message'];
        if (messageData != null && messageData is Map<String, dynamic>) {
          final message = ChatMessage.fromJson(messageData);
          // Only add if not from current user (avoid duplicates)
          if (message.sender != _currentUserId) {
            _addMessage(message);
          }
        }
      }
    });
  }

  void _addMessage(ChatMessage message) {
    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
  }

  /// Initialize chat
  Future<void> initChat(String chatId) async {
    if (state.chatId == chatId && state.messages.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      chatId: chatId,
      messages: [],
      currentPage: 1,
      hasMore: true,
    );

    _setupSocketListener(chatId);
    _socketService.joinChatRoom(chatId);

    await loadMessages(chatId);
  }

  /// Load messages
  Future<void> loadMessages(String chatId, {bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final response = await _chatService.getMessages(
        chatId: chatId,
        page: page,
      );

      // Mark as read
      await _chatService.markAsRead(chatId);

      final messages = response.messages.reversed.toList();

      state = state.copyWith(
        messages: refresh ? messages : [...state.messages, ...messages],
        isLoading: false,
        currentPage: page,
        hasMore: page < response.pages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Load more messages
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.chatId == null) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadMessages(state.chatId!);
  }

  /// Send message
  Future<bool> sendMessage({
    required String content,
    String type = 'text',
    String? imageUrl,
    double? lat,
    double? lng,
  }) async {
    if (state.chatId == null || state.isSending) return false;

    // Add optimistic message
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = ChatMessage(
      id: tempId,
      sender: _currentUserId ?? '',
      senderRole: 'customer',
      content: content,
      type: type,
      imageUrl: imageUrl,
      location: lat != null && lng != null
          ? MessageLocation(lat: lat, lng: lng)
          : null,
      createdAt: DateTime.now(),
      isSending: true,
    );

    state = state.copyWith(
      messages: [tempMessage, ...state.messages],
      isSending: true,
    );

    try {
      final message = await _chatService.sendMessage(
        chatId: state.chatId!,
        content: content,
        type: type,
        imageUrl: imageUrl,
        lat: lat,
        lng: lng,
      );

      // Replace temp message with real message
      final updatedMessages = state.messages.map((m) {
        if (m.id == tempId) {
          return message;
        }
        return m;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );

      return true;
    } catch (e) {
      // Remove temp message on error
      final updatedMessages = state.messages.where((m) => m.id != tempId).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );

      return false;
    }
  }

  /// Clear chat
  void clearChat() {
    _messageSubscription?.cancel();
    if (state.chatId != null) {
      _socketService.leaveChatRoom(state.chatId!);
    }
    state = const ChatMessagesState();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

/// Chat Messages Provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, ChatMessagesState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final socketService = ref.watch(socketServiceProvider);
  return ChatMessagesNotifier(chatService, socketService);
});

/// Get or create chat provider
final getOrCreateChatProvider = FutureProvider.family<Chat, ChatParams>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getOrCreateChat(
    orderId: params.orderId,
    chatType: params.chatType,
  );
});

/// Chat params
class ChatParams {
  final String orderId;
  final String chatType;

  const ChatParams({
    required this.orderId,
    required this.chatType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatParams &&
        other.orderId == orderId &&
        other.chatType == chatType;
  }

  @override
  int get hashCode => orderId.hashCode ^ chatType.hashCode;
}
