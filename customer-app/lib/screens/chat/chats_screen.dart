import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';
import '../../providers/providers.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  bool _isLoading = false;
  List<Chat> _chats = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _setupChatListener();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  void _setupChatListener() {
    final socketService = ref.read(socketServiceProvider);
    _chatSubscription = socketService.onChatMessage.listen((data) {
      // Refresh the chat list when a new message arrives
      _loadChats(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadChats({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getChats(page: _currentPage);

      if (mounted) {
        setState(() {
          if (refresh) {
            _chats = response.chats;
          } else {
            _chats.addAll(response.chats);
          }
          _hasMore = _currentPage < response.pages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    _currentPage++;
    await _loadChats();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'م' : 'ص';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'امس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} ايام';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildChatTile(Chat chat) {
    final isRestaurantChat = chat.chatType == 'customer_restaurant';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRestaurantChat
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.info.withValues(alpha: 0.1),
          child: Icon(
            isRestaurantChat ? Icons.restaurant : Icons.delivery_dining,
            color: isRestaurantChat ? AppColors.primary : AppColors.info,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.order != null
                    ? 'طلب #${chat.order!.orderNumber}'
                    : chat.chatTypeLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              chat.chatTypeLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (chat.lastMessage != null) ...[
              const SizedBox(height: 2),
              Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unreadCount > 0
                      ? AppColors.textPrimary
                      : Colors.grey[600],
                  fontWeight:
                      chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chat.lastMessageAt),
              style: TextStyle(
                fontSize: 12,
                color: chat.unreadCount > 0
                    ? AppColors.primary
                    : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            if (!chat.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مغلقة',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          context.push(
            '/chat/${chat.id}',
            extra: {
              'chatId': chat.id,
              'orderId': chat.orderId,
              'chatType': chat.chatType,
              'orderNumber': chat.order?.orderNumber,
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('المحادثات'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'يرجى تسجيل الدخول لعرض محادثاتك',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'الدعم الفني',
            onPressed: () => context.push('/chat/support'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadChats(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadChats(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('اعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد محادثات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ستظهر محادثاتك مع المطاعم والسائقين هنا',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/chat/support'),
                icon: const Icon(Icons.support_agent),
                label: const Text('تواصل مع الدعم'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _chats.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _chats.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildChatTile(_chats[index]);
      },
    );
  }
}
