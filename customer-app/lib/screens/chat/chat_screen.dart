import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';
import '../../providers/providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? orderId;
  final String? chatType;
  final String? orderNumber;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.orderId,
    this.chatType,
    this.orderNumber,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isUploadingImage = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  StreamSubscription? _messageSubscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupMessageListener();
    _scrollController.addListener(_onScroll);
    _getCurrentUserId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _getCurrentUserId() {
    final user = ref.read(currentUserProvider);
    _currentUserId = user?.id;
  }

  void _setupMessageListener() {
    final socketService = ref.read(socketServiceProvider);
    _messageSubscription = socketService.onChatMessage.listen((data) {
      final chatId = data['chatId'] as String?;
      if (chatId == widget.chatId) {
        final messageData = data['message'];
        if (messageData != null && messageData is Map<String, dynamic>) {
          final message = ChatMessage.fromJson(messageData);
          // Only add if it's not from us (to avoid duplicates)
          if (message.sender != _currentUserId) {
            setState(() {
              _messages.insert(0, message);
            });
            _scrollToBottom();
          }
        }
      }
    });

    // Join chat room for real-time updates
    socketService.joinChatRoom(widget.chatId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = refresh || _messages.isEmpty;
      _error = null;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getMessages(
        chatId: widget.chatId,
        page: _currentPage,
      );

      // Mark as read
      await chatService.markAsRead(widget.chatId);

      if (mounted) {
        setState(() {
          if (refresh) {
            _messages = response.messages.reversed.toList();
          } else {
            _messages = response.messages.reversed.toList();
          }
          _hasMore = _currentPage < response.pages;
          _isLoading = false;
        });

        // Scroll to bottom after initial load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
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

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getMessages(
        chatId: widget.chatId,
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          _messages.addAll(response.messages.reversed);
          _hasMore = _currentPage < response.pages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPage--;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    _focusNode.requestFocus();

    // Add optimistic message
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender: _currentUserId ?? '',
      senderRole: 'customer',
      content: text,
      type: 'text',
      createdAt: DateTime.now(),
      isSending: true,
    );

    setState(() {
      _messages.insert(0, tempMessage);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final chatService = ref.read(chatServiceProvider);
      final message = await chatService.sendMessage(
        chatId: widget.chatId,
        content: text,
        type: 'text',
      );

      if (mounted) {
        setState(() {
          // Replace temp message with real message
          final index = _messages.indexWhere((m) => m.id == tempMessage.id);
          if (index != -1) {
            _messages[index] = message;
          }
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Remove temp message on error
          _messages.removeWhere((m) => m.id == tempMessage.id);
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل ارسال الرسالة: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final chatService = ref.read(chatServiceProvider);

      // Upload image
      final imageUrl = await chatService.uploadImage(image.path);

      // Send message with image
      final message = await chatService.sendMessage(
        chatId: widget.chatId,
        content: 'صورة',
        type: 'image',
        imageUrl: imageUrl,
      );

      if (mounted) {
        setState(() {
          _messages.insert(0, message);
          _isUploadingImage = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل ارسال الصورة: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى السماح بالوصول الى الموقع'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تفعيل صلاحية الموقع من الاعدادات'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final chatService = ref.read(chatServiceProvider);
      final message = await chatService.sendMessage(
        chatId: widget.chatId,
        content: 'موقع',
        type: 'location',
        lat: position.latitude,
        lng: position.longitude,
      );

      if (mounted) {
        setState(() {
          _messages.insert(0, message);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل ارسال الموقع: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.image, color: AppColors.primary),
                ),
                title: const Text('صورة من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  child: const Icon(Icons.camera_alt, color: AppColors.info),
                ),
                title: const Text('التقاط صورة'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() => _isUploadingImage = true);
                    try {
                      final chatService = ref.read(chatServiceProvider);
                      final imageUrl = await chatService.uploadImage(image.path);
                      final message = await chatService.sendMessage(
                        chatId: widget.chatId,
                        content: 'صورة',
                        type: 'image',
                        imageUrl: imageUrl,
                      );
                      if (mounted) {
                        setState(() {
                          _messages.insert(0, message);
                          _isUploadingImage = false;
                        });
                        _scrollToBottom();
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isUploadingImage = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل ارسال الصورة: $e')),
                        );
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  child: const Icon(Icons.location_on, color: AppColors.success),
                ),
                title: const Text('مشاركة الموقع'),
                onTap: () {
                  Navigator.pop(context);
                  _sendLocation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.sender == _currentUserId || message.senderRole == 'customer';
    final bubbleColor = isMe ? AppColors.primary : Colors.grey[200];
    final textColor = isMe ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 48 : 8,
          right: isMe ? 8 : 48,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              padding: message.type == 'image'
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildMessageContent(message, textColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isSending
                          ? Icons.schedule
                          : message.isRead
                              ? Icons.done_all
                              : Icons.done,
                      size: 14,
                      color: message.isRead ? AppColors.info : Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, Color textColor) {
    switch (message.type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: message.imageUrl != null
              ? GestureDetector(
                  onTap: () => _showFullImage(message.imageUrl!),
                  child: Image.network(
                    message.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48),
                      );
                    },
                  ),
                )
              : Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 48),
                ),
        );

      case 'location':
        return GestureDetector(
          onTap: () {
            if (message.location != null) {
              _openLocation(message.location!.lat, message.location!.lng);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'اضغط لعرض الموقع',
                  style: TextStyle(
                    color: textColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
          ),
        );
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _showFullImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLocation(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRestaurantChat = widget.chatType == 'customer_restaurant';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.orderNumber != null
                  ? 'طلب #${widget.orderNumber}'
                  : isRestaurantChat
                      ? 'المطعم'
                      : 'السائق',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              isRestaurantChat ? 'محادثة مع المطعم' : 'محادثة مع السائق',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.orderId != null)
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'عرض الطلب',
              onPressed: () => context.push('/order/${widget.orderId}'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),

          // Uploading indicator
          if (_isUploadingImage)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.info.withValues(alpha: 0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('جاري رفع الصورة...'),
                ],
              ),
            ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
                onPressed: () => _loadMessages(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('اعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ابدا المحادثة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingMore && index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final message = _messages[index];
        final showDate = index == _messages.length - 1 ||
            !_isSameDay(_messages[index].createdAt, _messages[index + 1].createdAt);

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDate(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'اليوم';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'امس';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: AppColors.textSecondary,
            onPressed: _showAttachmentOptions,
          ),

          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
