import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Cards
          _buildContactCard(
            context,
            icon: Icons.phone,
            title: 'اتصل بنا',
            subtitle: AppConstants.supportPhone,
            onTap: () => _makePhoneCall(AppConstants.supportPhone),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            context,
            icon: Icons.email,
            title: 'راسلنا',
            subtitle: 'support@bagour-delivery.com',
            onTap: () => _sendEmail('support@bagour-delivery.com'),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            context,
            icon: Icons.access_time,
            title: 'ساعات العمل',
            subtitle: 'يومياً من 9 صباحاً - 12 منتصف الليل',
            onTap: null,
          ),
          const SizedBox(height: 24),

          // FAQs Section
          Text(
            'الأسئلة الشائعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          _buildFAQItem(
            context,
            question: 'كيف يمكنني تتبع طلبي؟',
            answer:
                'يمكنك تتبع طلبك من خلال الانتقال إلى "طلباتي" من القائمة الرئيسية. سيتم تحديث حالة الطلب تلقائياً وستتلقى إشعارات عند كل تغيير.',
          ),

          _buildFAQItem(
            context,
            question: 'ما هي طرق الدفع المتاحة؟',
            answer:
                'نقبل الدفع عند الاستلام، الدفع بالبطاقة الائتمانية، والمحافظ الإلكترونية. يمكنك أيضاً استخدام رصيد المحفظة الخاص بك.',
          ),

          _buildFAQItem(
            context,
            question: 'كم تستغرق مدة التوصيل؟',
            answer:
                'تختلف مدة التوصيل حسب موقعك والمطعم، ولكن عادة ما تستغرق من 30-45 دقيقة. سيتم عرض الوقت التقديري عند تقديم الطلب.',
          ),

          _buildFAQItem(
            context,
            question: 'هل يمكنني إلغاء طلبي؟',
            answer:
                'نعم، يمكنك إلغاء الطلب قبل أن يبدأ المطعم في تحضيره. انتقل إلى صفحة تتبع الطلب واضغط على "إلغاء الطلب" من القائمة.',
          ),

          _buildFAQItem(
            context,
            question: 'ماذا أفعل إذا كان هناك خطأ في طلبي؟',
            answer:
                'إذا كان هناك أي مشكلة في طلبك، يرجى التواصل معنا فوراً عبر الهاتف أو البريد الإلكتروني. سنعمل على حل المشكلة في أسرع وقت ممكن.',
          ),

          _buildFAQItem(
            context,
            question: 'كيف أضيف عنوان توصيل جديد؟',
            answer:
                'اذهب إلى "العناوين" من القائمة الرئيسية، ثم اضغط على "إضافة عنوان". يمكنك اختيار الموقع على الخريطة لتحديد العنوان بدقة.',
          ),

          _buildFAQItem(
            context,
            question: 'كيف يمكنني شحن محفظتي؟',
            answer:
                'اذهب إلى "المحفظة" من القائمة الرئيسية، ثم اضغط على "شحن المحفظة". اختر المبلغ وطريقة الدفع المفضلة لديك.',
          ),

          _buildFAQItem(
            context,
            question: 'هل توجد رسوم توصيل؟',
            answer:
                'رسوم التوصيل تختلف حسب المطعم والمسافة. بعض المطاعم تقدم توصيلاً مجانياً للطلبات التي تتجاوز حداً معيناً.',
          ),

          _buildFAQItem(
            context,
            question: 'كيف أحصل على العروض والخصومات؟',
            answer:
                'تابع إشعارات التطبيق للحصول على أحدث العروض. يمكنك أيضاً استخدام أكواد الخصم عند إتمام الطلب.',
          ),

          const SizedBox(height: 24),

          // Support Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(AppConstants.supportPhone),
              icon: const Icon(Icons.headset_mic),
              label: const Text('تحدث مع خدمة العملاء'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=استفسار من تطبيق توصيل الباجور');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
