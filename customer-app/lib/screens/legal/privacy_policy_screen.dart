import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سياسة الخصوصية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'آخر تحديث: ${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'المقدمة',
              'نحن في توصيل الباجور نلتزم بحماية خصوصيتك. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك الشخصية عند استخدام خدماتنا.',
            ),
            _buildSection(
              context,
              'المعلومات التي نجمعها',
              'نقوم بجمع المعلومات التالية:\n\n'
                  '• معلومات الحساب: الاسم، البريد الإلكتروني، رقم الهاتف\n'
                  '• معلومات التوصيل: العناوين، موقع GPS\n'
                  '• معلومات الطلبات: تاريخ الطلبات والمشتريات\n'
                  '• معلومات الدفع: تفاصيل الدفع المشفرة\n'
                  '• معلومات الجهاز: نوع الجهاز، نظام التشغيل، معرف الجهاز',
            ),
            _buildSection(
              context,
              'كيفية استخدام المعلومات',
              'نستخدم معلوماتك لـ:\n\n'
                  '• معالجة وتوصيل طلباتك\n'
                  '• تحسين خدماتنا وتجربة المستخدم\n'
                  '• إرسال إشعارات الطلبات والعروض\n'
                  '• معالجة المدفوعات والمعاملات المالية\n'
                  '• التواصل معك بشأن طلباتك وخدماتنا\n'
                  '• الامتثال للمتطلبات القانونية',
            ),
            _buildSection(
              context,
              'مشاركة المعلومات',
              'نحن لا نبيع معلوماتك الشخصية. قد نشارك معلوماتك مع:\n\n'
                  '• المطاعم: لمعالجة طلباتك\n'
                  '• السائقين: لتوصيل طلباتك\n'
                  '• معالجي الدفع: لإتمام المعاملات المالية\n'
                  '• مزودي الخدمات: الذين يساعدوننا في تشغيل منصتنا\n'
                  '• الجهات القانونية: عند الضرورة القانونية',
            ),
            _buildSection(
              context,
              'أمان البيانات',
              'نستخدم إجراءات أمنية متقدمة لحماية معلوماتك:\n\n'
                  '• تشفير البيانات أثناء النقل والتخزين\n'
                  '• الوصول المحدود للمعلومات الشخصية\n'
                  '• مراقبة الأمان المستمرة\n'
                  '• اختبارات أمنية منتظمة\n'
                  '• الامتثال لمعايير أمان البيانات',
            ),
            _buildSection(
              context,
              'حقوقك',
              'لديك الحق في:\n\n'
                  '• الوصول إلى معلوماتك الشخصية\n'
                  '• تصحيح أو تحديث معلوماتك\n'
                  '• حذف حسابك ومعلوماتك\n'
                  '• الاعتراض على معالجة معلوماتك\n'
                  '• طلب نسخة من بياناتك\n'
                  '• سحب موافقتك في أي وقت',
            ),
            _buildSection(
              context,
              'ملفات تعريف الارتباط',
              'نستخدم ملفات تعريف الارتباط (Cookies) لتحسين تجربتك. يمكنك التحكم في ملفات تعريف الارتباط من خلال إعدادات المتصفح أو الجهاز.',
            ),
            _buildSection(
              context,
              'خصوصية الأطفال',
              'خدماتنا غير موجهة للأطفال دون سن 16 عامًا. نحن لا نجمع معلومات شخصية عن قصد من الأطفال.',
            ),
            _buildSection(
              context,
              'تحديثات السياسة',
              'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنخطرك بأي تغييرات مهمة عبر البريد الإلكتروني أو إشعار في التطبيق.',
            ),
            _buildSection(
              context,
              'الاتصال بنا',
              'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا:\n\n'
                  'البريد الإلكتروني: privacy@bagour-delivery.com\n'
                  'الهاتف: +20 123 456 7890\n'
                  'العنوان: الباجور، المنوفية، مصر',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
