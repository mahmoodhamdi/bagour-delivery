import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  String _selectedLanguage = 'ar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _SectionHeader(title: 'الإشعارات'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('استقبال إشعارات الطلبات والعروض'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('صوت الإشعارات'),
            value: _soundEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _soundEnabled = value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.receipt_long_outlined),
            title: const Text('تحديثات الطلبات'),
            subtitle: const Text('إشعارات حالة الطلب'),
            value: _orderUpdates,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _orderUpdates = value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_offer_outlined),
            title: const Text('العروض والخصومات'),
            subtitle: const Text('إشعارات العروض الخاصة'),
            value: _promotions,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _promotions = value);
                  }
                : null,
          ),
          const Divider(),

          // Language Section
          _SectionHeader(title: 'اللغة'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('لغة التطبيق'),
            subtitle: Text(_selectedLanguage == 'ar' ? 'العربية' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(),

          // Privacy Section
          _SectionHeader(title: 'الخصوصية والأمان'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('تغيير كلمة المرور'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('حذف الحساب'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeleteAccountDialog(),
          ),
          const Divider(),

          // App Info Section
          _SectionHeader(title: 'معلومات التطبيق'),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('الشروط والأحكام'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show terms
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('قيم التطبيق'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open app store
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('شارك التطبيق'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Share app
            },
          ),
          const Divider(),

          // Version
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'توصيل الباجور',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'الإصدار 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ سيتم حذف جميع بياناتك بشكل نهائي ولا يمكن استرجاعها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب حذف الحساب'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
