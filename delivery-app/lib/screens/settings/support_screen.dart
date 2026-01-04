import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/url_launcher_helper.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone, color: AppColors.success),
                  ),
                  title: const Text('اتصل بنا'),
                  subtitle: Text(UrlLauncherHelper.supportPhone),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => UrlLauncherHelper.launchSupportPhone(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chat, color: AppColors.info),
                  ),
                  title: const Text('واتساب'),
                  subtitle: const Text('تواصل معنا عبر واتساب'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => UrlLauncherHelper.launchSupportWhatsApp(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email, color: AppColors.primary),
                  ),
                  title: const Text('البريد الإلكتروني'),
                  subtitle: Text(UrlLauncherHelper.supportEmail),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => UrlLauncherHelper.launchSupportEmail(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Section
          Text(
            'الأسئلة الشائعة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _FaqItem(
            question: 'كيف أستلم أرباحي؟',
            answer:
                'يمكنك طلب سحب أرباحك من صفحة الأرباح. يتم تحويل الأرباح خلال 3-5 أيام عمل إلى حسابك البنكي أو محفظتك الإلكترونية.',
          ),
          _FaqItem(
            question: 'ماذا أفعل إذا واجهت مشكلة في الطلب؟',
            answer:
                'إذا واجهت أي مشكلة أثناء التوصيل، يمكنك التواصل مع الدعم الفني مباشرة من خلال زر "اتصل بنا" أو عبر واتساب.',
          ),
          _FaqItem(
            question: 'كيف يتم احتساب الأرباح؟',
            answer:
                'يتم احتساب أرباحك بناءً على المسافة ورسوم التوصيل. يمكنك رؤية تفاصيل كل طلب في صفحة الأرباح.',
          ),
          _FaqItem(
            question: 'ما هي المستندات المطلوبة للتسجيل؟',
            answer:
                'يجب تقديم صورة البطاقة الشخصية، رخصة القيادة، ورخصة المركبة. قد يُطلب منك تقديم الفيش الجنائي أيضاً.',
          ),
          _FaqItem(
            question: 'كيف أغير حالتي إلى متصل/غير متصل؟',
            answer:
                'يمكنك تغيير حالتك من الشاشة الرئيسية عن طريق الضغط على زر التبديل. عندما تكون متصلاً، ستصلك طلبات التوصيل الجديدة.',
          ),
          const SizedBox(height: 24),

          // Report Issue
          Text(
            'الإبلاغ عن مشكلة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'وصف المشكلة',
                      hintText: 'اكتب تفاصيل المشكلة هنا...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إرسال الشكوى بنجاح'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
