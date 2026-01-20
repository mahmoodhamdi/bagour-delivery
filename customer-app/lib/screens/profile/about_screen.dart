import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    } catch (_) {
      setState(() {
        _version = AppConstants.appVersion;
        _buildNumber = '1';
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=استفسار من تطبيق ${AppConstants.appNameAr}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:${AppConstants.supportPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appNameAr,
      applicationVersion: _version,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delivery_dining,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo and Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appNameAr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اطلب طعامك المفضل الان',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الاصدار $_version ($_buildNumber)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // About Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'عن التطبيق',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'توصيل الباجور هو تطبيق توصيل الطعام الاول في مدينة الباجور، المنوفية. '
                        'نقدم خدمة توصيل سريعة وموثوقة من افضل المطاعم المحلية الى باب منزلك. '
                        'هدفنا هو توفير تجربة طلب طعام سهلة ومريحة لسكان الباجور والمناطق المجاورة.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.restaurant_menu,
                      title: 'تشكيلة واسعة',
                      subtitle: 'اختر من مئات المطاعم والاطباق',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildFeatureItem(
                      icon: Icons.delivery_dining,
                      title: 'توصيل سريع',
                      subtitle: 'نوصل طلبك في اقل من 45 دقيقة',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildFeatureItem(
                      icon: Icons.location_on,
                      title: 'تتبع مباشر',
                      subtitle: 'تابع طلبك من المطعم حتى بابك',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildFeatureItem(
                      icon: Icons.payment,
                      title: 'دفع مرن',
                      subtitle: 'نقدي، بطاقة، او محفظة الكترونية',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legal Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'شروط الاستخدام',
                      onTap: () => context.push(AppRoutes.terms),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'سياسة الخصوصية',
                      onTap: () => context.push(AppRoutes.privacyPolicy),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuItem(
                      icon: Icons.article_outlined,
                      title: 'تراخيص المكتبات',
                      onTap: _showLicenses,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.phone_outlined,
                      title: 'اتصل بنا',
                      subtitle: AppConstants.supportPhone,
                      onTap: _callSupport,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuItem(
                      icon: Icons.email_outlined,
                      title: 'راسلنا',
                      subtitle: AppConstants.supportEmail,
                      onTap: _sendEmail,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'الموقع الالكتروني',
                      subtitle: 'www.bagour-delivery.com',
                      onTap: () => _launchUrl('https://www.bagour-delivery.com'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Social Media
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'تابعنا',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            icon: Icons.facebook,
                            color: const Color(0xFF1877F2),
                            onTap: () => _launchUrl('https://facebook.com/bagourdelivery'),
                          ),
                          _buildSocialButton(
                            icon: Icons.camera_alt,
                            color: const Color(0xFFE4405F),
                            onTap: () => _launchUrl('https://instagram.com/bagourdelivery'),
                          ),
                          _buildSocialButton(
                            icon: Icons.close,
                            color: Colors.black,
                            onTap: () => _launchUrl('https://twitter.com/bagourdelivery'),
                          ),
                          _buildSocialButton(
                            icon: Icons.chat,
                            color: const Color(0xFF25D366),
                            onTap: () => _launchUrl('https://wa.me/201000000000'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Rate App
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Open app store for rating
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('شكرا لك! سيتم فتح المتجر للتقييم'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star, color: AppColors.rating),
                  label: const Text('قيم التطبيق'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rating,
                    side: const BorderSide(color: AppColors.rating),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Copyright
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${DateTime.now().year} ${AppConstants.appNameAr}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'جميع الحقوق محفوظة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onLongPress: () {
                      // Easter egg - show debug info
                      Clipboard.setData(ClipboardData(
                        text: 'Version: $_version ($_buildNumber)',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ معلومات الاصدار'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      'صنع بحب في الباجور',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.success, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
