import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../utils/url_launcher_helper.dart';
import '../../services/api_service.dart';
import '../../providers/order_provider.dart' show apiServiceProvider;

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<FaqCategory> _faqCategories = [
    FaqCategory(
      title: 'البدء كسائق',
      icon: Icons.play_circle_outline,
      faqs: [
        Faq(
          question: 'كيف أسجل كسائق توصيل؟',
          answer: '''للتسجيل كسائق توصيل:
1. قم بتحميل التطبيق وإنشاء حساب جديد
2. أدخل بياناتك الشخصية (الاسم، الهاتف، البريد الإلكتروني)
3. أضف معلومات مركبتك (نوع المركبة، رقم اللوحة)
4. ارفع المستندات المطلوبة (البطاقة الشخصية، رخصة القيادة، رخصة المركبة)
5. انتظر موافقة فريق المراجعة (24-48 ساعة)''',
        ),
        Faq(
          question: 'ما المستندات المطلوبة للتسجيل؟',
          answer: '''المستندات المطلوبة:
- صورة البطاقة الشخصية (الوجهين)
- رخصة القيادة السارية
- رخصة تسيير المركبة
- الفيش الجنائي (اختياري لكن يسرع عملية الموافقة)

ملاحظة: يجب أن تكون جميع المستندات واضحة وسارية المفعول.''',
        ),
        Faq(
          question: 'كم تستغرق عملية الموافقة؟',
          answer: 'عادةً ما تستغرق عملية مراجعة طلبك من 24 إلى 48 ساعة عمل. سنرسل لك إشعاراً فور اتخاذ قرار بشأن طلبك.',
        ),
      ],
    ),
    FaqCategory(
      title: 'استلام الطلبات',
      icon: Icons.receipt_long,
      faqs: [
        Faq(
          question: 'كيف أستقبل طلبات التوصيل؟',
          answer: '''لاستقبال الطلبات:
1. افتح التطبيق وقم بتفعيل وضع "متصل" من الشاشة الرئيسية
2. عندما يتوفر طلب قريب منك، ستصلك إشعار صوتي وعلى الشاشة
3. لديك 60 ثانية لقبول أو رفض الطلب
4. بعد القبول، اتبع التعليمات للذهاب للمطعم ثم العميل''',
        ),
        Faq(
          question: 'ماذا يحدث إذا رفضت طلباً؟',
          answer: 'يمكنك رفض الطلبات لأسباب مشروعة (مثل: بعيد جداً، مشغول، مشكلة في المركبة). لكن رفض الطلبات بشكل متكرر قد يؤثر على تقييمك ومعدل قبول الطلبات.',
        ),
        Faq(
          question: 'كيف أتعامل مع طلب به مشكلة؟',
          answer: '''إذا واجهت مشكلة في الطلب:
1. تواصل مع الدعم الفني فوراً عبر زر "مساعدة" في تفاصيل الطلب
2. لا تقم بإلغاء الطلب بنفسك دون التواصل مع الدعم
3. احتفظ بأي دليل (صور، رسائل) قد تحتاجه
4. سيتم حل المشكلة وتعويضك إذا لزم الأمر''',
        ),
      ],
    ),
    FaqCategory(
      title: 'الأرباح والمدفوعات',
      icon: Icons.payments,
      faqs: [
        Faq(
          question: 'كيف يتم احتساب أرباحي؟',
          answer: '''يتم احتساب أرباحك بناءً على:
- رسوم التوصيل الأساسية
- المسافة المقطوعة
- أوقات الذروة (مكافآت إضافية)
- البقشيش من العملاء (إن وجد)

يمكنك رؤية تفاصيل أرباح كل طلب في صفحة "الأرباح".''',
        ),
        Faq(
          question: 'متى يمكنني سحب أرباحي؟',
          answer: 'يمكنك طلب سحب أرباحك في أي وقت بشرط أن يكون الرصيد المتاح 50 ج.م على الأقل. يتم تحويل المبلغ خلال 3-5 أيام عمل إلى حسابك البنكي أو محفظتك الإلكترونية.',
        ),
        Faq(
          question: 'ما طرق السحب المتاحة؟',
          answer: '''طرق السحب المتاحة:
- التحويل البنكي (جميع البنوك المصرية)
- فودافون كاش
- اتصالات كاش
- أورانج كاش
- انستاباي

رسوم التحويل: مجانية''',
        ),
      ],
    ),
    FaqCategory(
      title: 'التقييمات والأداء',
      icon: Icons.star,
      faqs: [
        Faq(
          question: 'كيف يتم تقييمي؟',
          answer: 'يقوم العملاء بتقييمك بعد كل توصيلة من 1 إلى 5 نجوم. تقييمك الإجمالي هو متوسط آخر 100 تقييم. يجب الحفاظ على تقييم 4.0 على الأقل للاستمرار في استقبال الطلبات.',
        ),
        Faq(
          question: 'كيف أحسن تقييمي؟',
          answer: '''نصائح لتحسين تقييمك:
- التزم بأوقات التوصيل المحددة
- تعامل بلطف واحترام مع العملاء
- حافظ على نظافة ومظهر مركبتك
- تواصل مع العميل إذا تأخرت
- تأكد من سلامة الطلب قبل التسليم''',
        ),
        Faq(
          question: 'ماذا يحدث إذا انخفض تقييمي؟',
          answer: 'إذا انخفض تقييمك عن 4.0 بشكل مستمر، قد يتم تقليل عدد الطلبات المرسلة إليك أو إيقاف حسابك مؤقتاً. سنرسل لك تحذيرات قبل اتخاذ أي إجراء.',
        ),
      ],
    ),
    FaqCategory(
      title: 'المشاكل التقنية',
      icon: Icons.build,
      faqs: [
        Faq(
          question: 'التطبيق لا يستقبل طلبات',
          answer: '''تأكد من:
1. أنك في وضع "متصل" (الزر أخضر)
2. تفعيل خدمة الموقع (GPS)
3. وجود اتصال إنترنت جيد
4. تحديث التطبيق لآخر إصدار
5. إعادة تشغيل التطبيق

إذا استمرت المشكلة، تواصل مع الدعم الفني.''',
        ),
        Faq(
          question: 'الموقع غير دقيق',
          answer: '''لتحسين دقة الموقع:
1. تأكد من تفعيل GPS بدقة عالية
2. اخرج للأماكن المفتوحة بعيداً عن المباني الكبيرة
3. أعد تشغيل خدمة الموقع
4. تحقق من إعدادات الموقع في إعدادات الهاتف''',
        ),
        Faq(
          question: 'نسيت كلمة المرور',
          answer: 'يمكنك إعادة تعيين كلمة المرور من خلال الضغط على "نسيت كلمة المرور" في صفحة تسجيل الدخول. سيتم إرسال رمز التحقق إلى بريدك الإلكتروني المسجل.',
        ),
      ],
    ),
  ];

  List<FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;

    return _faqCategories.map((category) {
      final filteredFaqs = category.faqs.where((faq) {
        return faq.question.contains(_searchQuery) ||
            faq.answer.contains(_searchQuery);
      }).toList();

      return FaqCategory(
        title: category.title,
        icon: category.icon,
        faqs: filteredFaqs,
      );
    }).where((category) => category.faqs.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن سؤالك...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Actions
                  _buildQuickActions(),

                  // FAQ Categories
                  ..._filteredCategories.map((category) =>
                      _buildFaqCategory(category)),

                  // Contact Support Section
                  _buildContactSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تواصل سريع',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.phone,
                  label: 'اتصل بنا',
                  color: AppColors.success,
                  onTap: () => UrlLauncherHelper.launchSupportPhone(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.chat,
                  label: 'واتساب',
                  color: Color(0xFF25D366),
                  onTap: () => UrlLauncherHelper.launchSupportWhatsApp(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.email,
                  label: 'البريد',
                  color: AppColors.primary,
                  onTap: () => UrlLauncherHelper.launchSupportEmail(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCategory(FaqCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, color: AppColors.primary),
          ),
          title: Text(
            category.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            '${category.faqs.length} أسئلة',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          children: category.faqs.map((faq) => _buildFaqItem(faq)).toList(),
        ),
      ),
    );
  }

  Widget _buildFaqItem(Faq faq) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          faq.question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                faq.answer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.info.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  size: 40,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لم تجد إجابة لسؤالك؟',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'فريق الدعم متاح على مدار الساعة للرد على استفساراتك',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showSubmitQuestionDialog(),
                icon: const Icon(Icons.send),
                label: const Text('إرسال استفسار'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitQuestionDialog() {
    final questionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إرسال استفسار',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب سؤالك أو استفسارك هنا...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (questionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى كتابة استفسارك'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  final apiService = ref.read(apiServiceProvider);
                  await apiService.post('/support/inquiry', data: {
                    'message': questionController.text.trim(),
                    'type': 'driver_inquiry',
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال استفسارك بنجاح. سنتواصل معك قريباً.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('حدث خطأ. يرجى المحاولة مرة أخرى.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('إرسال'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqCategory {
  final String title;
  final IconData icon;
  final List<Faq> faqs;

  FaqCategory({
    required this.title,
    required this.icon,
    required this.faqs,
  });
}

class Faq {
  final String question;
  final String answer;

  Faq({
    required this.question,
    required this.answer,
  });
}
