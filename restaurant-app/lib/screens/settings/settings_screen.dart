import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/restaurant_service.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  RestaurantProfile? _profile;

  // Notification settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _newOrderNotification = true;
  bool _orderStatusNotification = true;
  bool _reviewNotification = true;

  // Language
  String _selectedLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(restaurantServiceProvider);
      final profile = await service.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('فشل في تحميل الإعدادات');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: _isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Restaurant Status Toggle
                _buildStatusSection(),

                const Divider(height: 1),

                // Opening Hours Section
                _SectionHeader(title: 'ساعات العمل'),
                _buildOpeningHoursSection(),

                const Divider(height: 1),

                // Delivery Settings Section
                _SectionHeader(title: 'إعدادات التوصيل'),
                _buildDeliverySettingsSection(),

                const Divider(height: 1),

                // Notifications Section
                _SectionHeader(title: 'الإشعارات'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('تفعيل الإشعارات'),
                  subtitle: const Text('استقبال إشعارات الطلبات والتقييمات'),
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
                  secondary: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('طلبات جديدة'),
                  subtitle: const Text('إشعار عند وصول طلب جديد'),
                  value: _newOrderNotification,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _newOrderNotification = value);
                        }
                      : null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.local_shipping_outlined),
                  title: const Text('تحديثات الطلبات'),
                  subtitle: const Text('إشعار عند تغيير حالة الطلب'),
                  value: _orderStatusNotification,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _orderStatusNotification = value);
                        }
                      : null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.star_outline),
                  title: const Text('التقييمات الجديدة'),
                  subtitle: const Text('إشعار عند استلام تقييم جديد'),
                  value: _reviewNotification,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _reviewNotification = value);
                        }
                      : null,
                ),

                const Divider(height: 1),

                // Language Section
                _SectionHeader(title: 'اللغة'),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('لغة التطبيق'),
                  subtitle: Text(_selectedLanguage == 'ar' ? 'العربية' : 'English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLanguageDialog,
                ),

                const Divider(height: 1),

                // Account Section
                _SectionHeader(title: 'الحساب'),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('تغيير كلمة المرور'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('المساعدة والدعم'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSupportDialog,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('عن التطبيق'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutDialog,
                ),

                const Divider(height: 1),

                // Logout Section
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(),
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

                const SizedBox(height: 16),

                // App Version
                Center(
                  child: Column(
                    children: [
                      Text(
                        'توصيل الباجور - المطعم',
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

  Widget _buildStatusSection() {
    final isOpen = _profile?.isOpen ?? false;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: isOpen ? AppColors.success : AppColors.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.store : Icons.store_mall_directory,
            color: isOpen ? AppColors.success : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'المطعم مفتوح' : 'المطعم مغلق',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isOpen ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  isOpen
                      ? 'يمكن للعملاء إجراء طلبات جديدة'
                      : 'لن يتمكن العملاء من إجراء طلبات',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: _toggleRestaurantStatus,
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursSection() {
    final days = {
      'sunday': 'الأحد',
      'monday': 'الإثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
    };

    return Column(
      children: [
        ...days.entries.map((entry) {
          final dayKey = entry.key;
          final dayName = entry.value;
          final hours = _profile?.openingHours?[dayKey];
          final isOpen = hours?.isOpen ?? false;

          return ListTile(
            title: Text(dayName),
            subtitle: Text(
              !isOpen
                  ? 'مغلق'
                  : hours?.openTime != null && hours?.closeTime != null
                      ? '${hours!.openTime} - ${hours.closeTime}'
                      : 'غير محدد',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isOpen,
                  onChanged: (value) => _updateDayOpenStatus(dayKey, value),
                  activeThumbColor: AppColors.success,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditHoursDialog(dayKey, dayName, hours),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDeliverySettingsSection() {
    final settings = _profile?.deliverySettings;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('رسوم التوصيل'),
          subtitle: Text('${settings?.deliveryFee.toStringAsFixed(2) ?? '0'} ج.م'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showEditDeliveryFeeDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('الحد الأدنى للطلب'),
          subtitle: Text('${settings?.minimumOrder.toStringAsFixed(2) ?? '0'} ج.م'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showEditMinimumOrderDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('وقت التوصيل المتوقع'),
          subtitle: Text('${settings?.estimatedDeliveryTime ?? 30} دقيقة'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showEditDeliveryTimeDialog(),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.local_offer),
          title: const Text('توصيل مجاني'),
          subtitle: Text(
            (settings?.freeDeliveryEnabled ?? false)
                ? 'للطلبات فوق ${settings?.freeDeliveryMinimum?.toStringAsFixed(2) ?? '0'} ج.م'
                : 'غير مفعل',
          ),
          value: settings?.freeDeliveryEnabled ?? false,
          onChanged: (value) => _showEditFreeDeliveryDialog(value),
        ),
      ],
    );
  }

  Future<void> _toggleRestaurantStatus(bool value) async {
    try {
      final service = ref.read(restaurantServiceProvider);
      final newStatus = await service.toggleStatus(value);

      if (mounted) {
        setState(() {
          _profile = RestaurantProfile(
            id: _profile!.id,
            name: _profile!.name,
            nameAr: _profile!.nameAr,
            description: _profile!.description,
            descriptionAr: _profile!.descriptionAr,
            logo: _profile!.logo,
            coverImage: _profile!.coverImage,
            phone: _profile!.phone,
            email: _profile!.email,
            address: _profile!.address,
            location: _profile!.location,
            cuisineTypes: _profile!.cuisineTypes,
            rating: _profile!.rating,
            reviewCount: _profile!.reviewCount,
            isOpen: newStatus,
            isActive: _profile!.isActive,
            openingHours: _profile!.openingHours,
            deliverySettings: _profile!.deliverySettings,
            bankDetails: _profile!.bankDetails,
            createdAt: _profile!.createdAt,
          );
        });
        _showSuccess(newStatus ? 'تم فتح المطعم' : 'تم إغلاق المطعم');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _updateDayOpenStatus(String day, bool isOpen) async {
    final currentHours = Map<String, OpeningHours>.from(_profile?.openingHours ?? {});
    final currentDay = currentHours[day] ?? OpeningHours();

    currentHours[day] = OpeningHours(
      isOpen: isOpen,
      openTime: currentDay.openTime,
      closeTime: currentDay.closeTime,
    );

    try {
      final service = ref.read(restaurantServiceProvider);
      final updatedProfile = await service.updateOpeningHours(currentHours);

      if (mounted) {
        setState(() => _profile = updatedProfile);
        _showSuccess('تم تحديث ساعات العمل');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showEditHoursDialog(String dayKey, String dayName, OpeningHours? hours) {
    final openTimeController = TextEditingController(text: hours?.openTime ?? '09:00');
    final closeTimeController = TextEditingController(text: hours?.closeTime ?? '22:00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ساعات العمل - $dayName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: openTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت الفتح',
                        hintText: '09:00',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          openTimeController.text =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: closeTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت الإغلاق',
                        hintText: '22:00',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          closeTimeController.text =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentHours =
                            Map<String, OpeningHours>.from(_profile?.openingHours ?? {});

                        currentHours[dayKey] = OpeningHours(
                          isOpen: true,
                          openTime: openTimeController.text,
                          closeTime: closeTimeController.text,
                        );

                        try {
                          final service = ref.read(restaurantServiceProvider);
                          final updatedProfile =
                              await service.updateOpeningHours(currentHours);

                          if (mounted && context.mounted) {
                            setState(() => _profile = updatedProfile);
                            Navigator.pop(context);
                            _showSuccess('تم تحديث ساعات العمل');
                          }
                        } catch (e) {
                          _showError(e.toString().replaceAll('Exception: ', ''));
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDeliveryFeeDialog() {
    final controller = TextEditingController(
      text: _profile?.deliverySettings?.deliveryFee.toString() ?? '0',
    );

    _showEditDialog(
      title: 'رسوم التوصيل',
      controller: controller,
      label: 'رسوم التوصيل (ج.م)',
      keyboardType: TextInputType.number,
      onSave: (value) async {
        final fee = double.tryParse(value) ?? 0;
        final settings = _profile?.deliverySettings ?? DeliverySettings();
        final newSettings = DeliverySettings(
          deliveryFee: fee,
          minimumOrder: settings.minimumOrder,
          estimatedDeliveryTime: settings.estimatedDeliveryTime,
          deliveryRadius: settings.deliveryRadius,
          freeDeliveryEnabled: settings.freeDeliveryEnabled,
          freeDeliveryMinimum: settings.freeDeliveryMinimum,
        );

        final service = ref.read(restaurantServiceProvider);
        return service.updateDeliverySettings(newSettings);
      },
    );
  }

  void _showEditMinimumOrderDialog() {
    final controller = TextEditingController(
      text: _profile?.deliverySettings?.minimumOrder.toString() ?? '0',
    );

    _showEditDialog(
      title: 'الحد الأدنى للطلب',
      controller: controller,
      label: 'الحد الأدنى (ج.م)',
      keyboardType: TextInputType.number,
      onSave: (value) async {
        final minimum = double.tryParse(value) ?? 0;
        final settings = _profile?.deliverySettings ?? DeliverySettings();
        final newSettings = DeliverySettings(
          deliveryFee: settings.deliveryFee,
          minimumOrder: minimum,
          estimatedDeliveryTime: settings.estimatedDeliveryTime,
          deliveryRadius: settings.deliveryRadius,
          freeDeliveryEnabled: settings.freeDeliveryEnabled,
          freeDeliveryMinimum: settings.freeDeliveryMinimum,
        );

        final service = ref.read(restaurantServiceProvider);
        return service.updateDeliverySettings(newSettings);
      },
    );
  }

  void _showEditDeliveryTimeDialog() {
    final controller = TextEditingController(
      text: _profile?.deliverySettings?.estimatedDeliveryTime.toString() ?? '30',
    );

    _showEditDialog(
      title: 'وقت التوصيل المتوقع',
      controller: controller,
      label: 'الوقت (بالدقائق)',
      keyboardType: TextInputType.number,
      onSave: (value) async {
        final time = int.tryParse(value) ?? 30;
        final settings = _profile?.deliverySettings ?? DeliverySettings();
        final newSettings = DeliverySettings(
          deliveryFee: settings.deliveryFee,
          minimumOrder: settings.minimumOrder,
          estimatedDeliveryTime: time,
          deliveryRadius: settings.deliveryRadius,
          freeDeliveryEnabled: settings.freeDeliveryEnabled,
          freeDeliveryMinimum: settings.freeDeliveryMinimum,
        );

        final service = ref.read(restaurantServiceProvider);
        return service.updateDeliverySettings(newSettings);
      },
    );
  }

  void _showEditFreeDeliveryDialog(bool enabled) {
    if (!enabled) {
      _updateFreeDelivery(false, null);
      return;
    }

    final controller = TextEditingController(
      text: _profile?.deliverySettings?.freeDeliveryMinimum?.toString() ?? '100',
    );

    _showEditDialog(
      title: 'توصيل مجاني',
      controller: controller,
      label: 'الحد الأدنى للتوصيل المجاني (ج.م)',
      keyboardType: TextInputType.number,
      onSave: (value) async {
        final minimum = double.tryParse(value) ?? 100;
        await _updateFreeDelivery(true, minimum);
        return _profile!;
      },
    );
  }

  Future<void> _updateFreeDelivery(bool enabled, double? minimum) async {
    final settings = _profile?.deliverySettings ?? DeliverySettings();
    final newSettings = DeliverySettings(
      deliveryFee: settings.deliveryFee,
      minimumOrder: settings.minimumOrder,
      estimatedDeliveryTime: settings.estimatedDeliveryTime,
      deliveryRadius: settings.deliveryRadius,
      freeDeliveryEnabled: enabled,
      freeDeliveryMinimum: minimum,
    );

    try {
      final service = ref.read(restaurantServiceProvider);
      final updatedProfile = await service.updateDeliverySettings(newSettings);

      if (mounted) {
        setState(() => _profile = updatedProfile);
        _showSuccess('تم تحديث الإعدادات');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showEditDialog({
    required String title,
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required Future<RestaurantProfile> Function(String value) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final updatedProfile = await onSave(controller.text);

                          if (mounted && context.mounted) {
                            setState(() => _profile = updatedProfile);
                            Navigator.pop(context);
                            _showSuccess('تم تحديث الإعدادات');
                          }
                        } catch (e) {
                          _showError(e.toString().replaceAll('Exception: ', ''));
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تغيير كلمة المرور',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          _showError('كلمات المرور غير متطابقة');
                          return;
                        }
                        Navigator.pop(context);
                        _showSuccess('تم تغيير كلمة المرور بنجاح');
                      },
                      child: const Text('تغيير'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'توصيل الباجور - المطعم',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.restaurant,
          color: Colors.white,
        ),
      ),
      children: const [
        Text('تطبيق إدارة المطاعم لمنصة توصيل الباجور'),
      ],
    );
  }

  void _showLogoutDialog() {
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
              if (mounted) {
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
