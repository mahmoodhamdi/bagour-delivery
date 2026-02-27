import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/providers.dart';
import '../../utils/url_launcher_helper.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'يرجى تسجيل الدخول',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
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
        title: const Text('حسابي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: user.avatar != null && user.avatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.avatar!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        user.isPhoneVerified ? Icons.verified : Icons.phone,
                        size: 16,
                        color: user.isPhoneVerified
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            const SizedBox(height: 16),

            // Orders Section
            _MenuSection(
              title: 'طلباتي',
              items: [
                _MenuItem(
                  icon: Icons.receipt_long,
                  title: 'طلباتي السابقة',
                  onTap: () => context.push(AppRoutes.orders),
                ),
              ],
            ),

            // Account Section
            _MenuSection(
              title: 'الحساب',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'تعديل الملف الشخصي',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'عناويني',
                  onTap: () => context.push(AppRoutes.addresses),
                ),
                _MenuItem(
                  icon: Icons.favorite_border,
                  title: 'المفضلة',
                  onTap: () => context.push(AppRoutes.favorites),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
              ],
            ),

            // Settings Section
            _MenuSection(
              title: 'الإعدادات',
              items: [
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'المساعدة والدعم',
                  onTap: () => context.push(AppRoutes.help),
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'عن التطبيق',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'توصيل الباجور',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.white,
                        ),
                      ),
                      children: const [
                        Text('تطبيق توصيل الطعام لمدينة الباجور'),
                      ],
                    );
                  },
                ),
              ],
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'المساعدة والدعم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
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
              subtitle: const Text('+20 100 000 0000'),
              onTap: () {
                Navigator.pop(context);
                UrlLauncherHelper.launchSupportPhone();
              },
            ),
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
              subtitle: const Text('تواصل عبر واتساب'),
              onTap: () {
                Navigator.pop(context);
                UrlLauncherHelper.launchSupportWhatsApp();
              },
            ),
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
              subtitle: const Text('support@bagour.com'),
              onTap: () {
                Navigator.pop(context);
                UrlLauncherHelper.launchSupportEmail();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        ...items,
        const Divider(),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
