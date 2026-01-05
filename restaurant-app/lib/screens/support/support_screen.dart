import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تواصل معنا',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone, color: Colors.green),
                    ),
                    title: const Text('اتصل بنا'),
                    subtitle: const Text('01000000000'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl('tel:01000000000'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.email, color: Colors.blue),
                    ),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: const Text('support@bagour.com'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl('mailto:support@bagour.com'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chat, color: Colors.green),
                    ),
                    title: const Text('واتساب'),
                    subtitle: const Text('تواصل عبر واتساب'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl('https://wa.me/201000000000'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FAQ Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأسئلة الشائعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    'كيف يمكنني تحديث قائمة الطعام؟',
                    'يمكنك تحديث قائمة الطعام من خلال صفحة "القائمة" ثم الضغط على "إضافة صنف جديد" أو تعديل الأصناف الحالية.',
                  ),
                  _buildFaqItem(
                    'كيف أستلم المدفوعات؟',
                    'يتم تحويل المدفوعات أسبوعياً إلى حسابك البنكي المسجل. يمكنك متابعة الأرباح من صفحة "الأرباح".',
                  ),
                  _buildFaqItem(
                    'ماذا أفعل إذا تأخر السائق؟',
                    'يمكنك التواصل مع الدعم الفني وسنقوم بحل المشكلة فوراً.',
                  ),
                  _buildFaqItem(
                    'كيف يمكنني إيقاف استقبال الطلبات مؤقتاً؟',
                    'يمكنك تغيير حالة المطعم من "مفتوح" إلى "مغلق" من خلال لوحة التحكم.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Report Issue
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bug_report, color: Colors.red),
              ),
              title: const Text('الإبلاغ عن مشكلة'),
              subtitle: const Text('أخبرنا عن أي مشكلة تواجهك'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open report issue screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
