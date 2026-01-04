import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: authState.maybeWhen(
        authenticated: (user, driver) => SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.driverGradient,
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.white,
                      child: user.avatar != null
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Driver stats
                    if (driver != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            icon: Icons.star,
                            value: driver.rating.toStringAsFixed(1),
                            label: 'التقييم',
                          ),
                          _StatItem(
                            icon: Icons.delivery_dining,
                            value: driver.totalDeliveries.toString(),
                            label: 'التوصيلات',
                          ),
                          _StatItem(
                            icon: Icons.account_balance_wallet,
                            value: '${driver.currentBalance.toStringAsFixed(0)} ج.م',
                            label: 'الرصيد',
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Menu Items
              const SizedBox(height: 16),
              _MenuItem(
                icon: Icons.person_outline,
                title: 'تعديل الملف الشخصي',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'المستندات',
                subtitle: 'رخصة القيادة والهوية',
                onTap: () => context.push(AppRoutes.documents),
              ),
              _MenuItem(
                icon: Icons.two_wheeler,
                title: 'معلومات المركبة',
                onTap: () => context.push(AppRoutes.vehicle),
              ),
              _MenuItem(
                icon: Icons.attach_money,
                title: 'الأرباح',
                onTap: () => context.push(AppRoutes.earnings),
              ),
              const Divider(height: 32),
              _MenuItem(
                icon: Icons.settings_outlined,
                title: 'الإعدادات',
                onTap: () => context.push(AppRoutes.settings),
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: 'الدعم والمساعدة',
                onTap: () => context.push(AppRoutes.support),
              ),
              const Divider(height: 32),
              _MenuItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                textColor: AppColors.error,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        orElse: () => const Center(child: CircularProgressIndicator()),
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
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
