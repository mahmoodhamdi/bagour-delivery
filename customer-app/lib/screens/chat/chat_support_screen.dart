import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/providers.dart';

class ChatSupportScreen extends ConsumerStatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  ConsumerState<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends ConsumerState<ChatSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SupportMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final user = ref.read(currentUserProvider);
    final userName = user?.name.split(' ').first ?? 'عميلنا';

    _messages.addAll([
      SupportMessage(
        content: 'مرحبا $userName! كيف يمكننا مساعدتك اليوم؟',
        isFromSupport: true,
        timestamp: DateTime.now(),
      ),
    ]);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(SupportMessage(
        content: text,
        isFromSupport: false,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    // Simulate support response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_generateSupportResponse(text));
          _isSending = false;
        });
        _scrollToBottom();
      }
    });
  }

  SupportMessage _generateSupportResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String response;

    if (lowerMessage.contains('طلب') || lowerMessage.contains('order')) {
      response = 'لمتابعة طلبك، يمكنك الذهاب الى "طلباتي" من الصفحة الرئيسية. '
          'اذا كان لديك مشكلة في طلب معين، يرجى ارسال رقم الطلب.';
    } else if (lowerMessage.contains('دفع') ||
        lowerMessage.contains('payment') ||
        lowerMessage.contains('فلوس')) {
      response = 'نقبل الدفع عند الاستلام، البطاقات الائتمانية، والمحافظ الالكترونية. '
          'اذا واجهت مشكلة في الدفع، يرجى التواصل معنا على ${AppConstants.supportPhone}';
    } else if (lowerMessage.contains('توصيل') ||
        lowerMessage.contains('delivery') ||
        lowerMessage.contains('سائق')) {
      response = 'وقت التوصيل المتوقع يعتمد على المسافة والمطعم. '
          'عادة ما يستغرق 30-45 دقيقة. يمكنك تتبع طلبك مباشرة من التطبيق.';
    } else if (lowerMessage.contains('الغاء') || lowerMessage.contains('cancel')) {
      response = 'يمكنك الغاء الطلب قبل ان يبدا المطعم في تحضيره. '
          'اذهب الى صفحة تتبع الطلب واضغط على "الغاء الطلب".';
    } else if (lowerMessage.contains('شكر') || lowerMessage.contains('thank')) {
      response = 'شكرا لك! نحن سعداء بخدمتك. هل يوجد شيء اخر يمكننا مساعدتك به؟';
    } else if (lowerMessage.contains('مشكلة') || lowerMessage.contains('problem')) {
      response = 'نعتذر عن اي ازعاج. يرجى وصف المشكلة بالتفصيل او الاتصال بنا مباشرة على '
          '${AppConstants.supportPhone} للمساعدة الفورية.';
    } else if (lowerMessage.contains('خصم') ||
        lowerMessage.contains('كوبون') ||
        lowerMessage.contains('coupon')) {
      response = 'يمكنك ادخال كود الخصم في صفحة اتمام الطلب. '
          'تابع اشعارات التطبيق للحصول على احدث العروض والخصومات.';
    } else if (lowerMessage.contains('عنوان') || lowerMessage.contains('address')) {
      response = 'يمكنك اضافة او تعديل عناوينك من "العناوين" في القائمة الرئيسية. '
          'تاكد من تحديد الموقع بدقة على الخريطة.';
    } else if (lowerMessage.contains('محفظة') || lowerMessage.contains('wallet')) {
      response = 'يمكنك شحن محفظتك من صفحة "المحفظة" في حسابك. '
          'نقبل الشحن عبر البطاقات والمحافظ الالكترونية.';
    } else {
      response = 'شكرا على رسالتك. سيقوم فريق الدعم بالرد عليك في اقرب وقت. '
          'للمساعدة الفورية، يمكنك الاتصال بنا على ${AppConstants.supportPhone}';
    }

    return SupportMessage(
      content: response,
      isFromSupport: true,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:${AppConstants.supportPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _emailSupport() async {
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=استفسار من تطبيق توصيل الباجور',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsappSupport() async {
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.supportPhone.replaceAll('+', '')}?text=مرحبا، لدي استفسار',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طرق التواصل السريعة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.phone,
                  label: 'اتصال',
                  color: AppColors.success,
                  onTap: _callSupport,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.chat,
                  label: 'واتساب',
                  color: const Color(0xFF25D366),
                  onTap: _whatsappSupport,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.email,
                  label: 'ايميل',
                  color: AppColors.info,
                  onTap: _emailSupport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {'q': 'كيف اتتبع طلبي؟', 'a': 'من صفحة طلباتي'},
      {'q': 'كيف الغي طلبي؟', 'a': 'قبل بدء التحضير'},
      {'q': 'طرق الدفع المتاحة؟', 'a': 'نقدي، بطاقة، محفظة'},
      {'q': 'وقت التوصيل؟', 'a': '30-45 دقيقة تقريبا'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الاسئلة الشائعة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: faqs.map((faq) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _messages.add(SupportMessage(
                      content: faq['q']!,
                      isFromSupport: false,
                      timestamp: DateTime.now(),
                    ));
                  });
                  _scrollToBottom();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _messages.add(SupportMessage(
                          content: faq['a']!,
                          isFromSupport: true,
                          timestamp: DateTime.now(),
                        ));
                      });
                      _scrollToBottom();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    faq['q']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message) {
    final isFromSupport = message.isFromSupport;
    final bubbleColor = isFromSupport ? Colors.grey[200] : AppColors.primary;
    final textColor = isFromSupport ? AppColors.textPrimary : Colors.white;

    return Align(
      alignment: isFromSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isFromSupport ? 8 : 48,
          right: isFromSupport ? 48 : 8,
        ),
        child: Column(
          crossAxisAlignment:
              isFromSupport ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromSupport ? 4 : 16),
                  bottomRight: Radius.circular(isFromSupport ? 16 : 4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدعم الفني',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'متاحون للمساعدة',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'اتصال بالدعم',
            onPressed: _callSupport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick actions
          _buildQuickActions(),

          const Divider(height: 1),

          // FAQ Section
          _buildFAQSection(),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'جاري الكتابة...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input Area
          Container(
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
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SupportMessage {
  final String content;
  final bool isFromSupport;
  final DateTime timestamp;

  SupportMessage({
    required this.content,
    required this.isFromSupport,
    required this.timestamp,
  });
}
