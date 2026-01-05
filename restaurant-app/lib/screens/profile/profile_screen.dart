import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/restaurant_service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;
  RestaurantProfile? _profile;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;

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
        _showError('فشل في تحميل بيانات المطعم');
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
      body: _isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: CustomScrollView(
                slivers: [
                  // Cover Image and Header
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildCoverImage(),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditProfileDialog(),
                      ),
                    ],
                  ),

                  // Profile Content
                  SliverToBoxAdapter(
                    child: _buildProfileContent(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover Image
        if (_profile?.coverImage != null && _profile!.coverImage!.isNotEmpty)
          Image.network(
            _profile!.coverImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Upload Cover Button
        Positioned(
          bottom: 80,
          left: 16,
          child: _isUploadingCover
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                  ),
                  onPressed: _uploadCoverImage,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
        ),

        // Logo and Name
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Logo
              GestureDetector(
                onTap: _uploadLogo,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: _profile?.logo != null && _profile!.logo!.isNotEmpty
                            ? Image.network(
                                _profile!.logo!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.restaurant,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.restaurant,
                                size: 40,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                    if (_isUploadingLogo)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.nameAr ?? _profile?.name ?? 'اسم المطعم',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (_profile?.isOpen ?? false)
                                ? AppColors.success
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            (_profile?.isOpen ?? false) ? 'مفتوح' : 'مغلق',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_profile != null) ...[
                          const Icon(
                            Icons.star,
                            color: AppColors.rating,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_profile!.rating.toStringAsFixed(1)} (${_profile!.reviewCount})',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    if (_profile == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Info Section
          _SectionCard(
            title: 'معلومات المطعم',
            icon: Icons.restaurant,
            onEdit: () => _showEditProfileDialog(),
            children: [
              _InfoRow(
                icon: Icons.store,
                label: 'اسم المطعم',
                value: _profile!.nameAr ?? _profile!.name,
              ),
              if (_profile!.description != null &&
                  _profile!.description!.isNotEmpty)
                _InfoRow(
                  icon: Icons.description,
                  label: 'الوصف',
                  value: _profile!.descriptionAr ?? _profile!.description!,
                ),
              _InfoRow(
                icon: Icons.phone,
                label: 'رقم الهاتف',
                value: _profile!.phone ?? 'غير محدد',
              ),
              _InfoRow(
                icon: Icons.email,
                label: 'البريد الإلكتروني',
                value: _profile!.email ?? 'غير محدد',
              ),
              _InfoRow(
                icon: Icons.location_on,
                label: 'العنوان',
                value: _profile!.address ?? 'غير محدد',
              ),
              if (_profile!.cuisineTypes.isNotEmpty)
                _InfoRow(
                  icon: Icons.category,
                  label: 'نوع المطبخ',
                  value: _profile!.cuisineTypes.join('، '),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Opening Hours Section
          _SectionCard(
            title: 'ساعات العمل',
            icon: Icons.access_time,
            onEdit: () => context.push(AppRoutes.settings),
            children: [
              if (_profile!.openingHours != null &&
                  _profile!.openingHours!.isNotEmpty)
                ..._buildOpeningHoursRows()
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لم يتم تحديد ساعات العمل',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Delivery Settings Section
          _SectionCard(
            title: 'إعدادات التوصيل',
            icon: Icons.delivery_dining,
            onEdit: () => context.push(AppRoutes.settings),
            children: [
              _InfoRow(
                icon: Icons.attach_money,
                label: 'رسوم التوصيل',
                value:
                    '${_profile!.deliverySettings?.deliveryFee.toStringAsFixed(2) ?? '0'} ج.م',
              ),
              _InfoRow(
                icon: Icons.shopping_cart,
                label: 'الحد الأدنى للطلب',
                value:
                    '${_profile!.deliverySettings?.minimumOrder.toStringAsFixed(2) ?? '0'} ج.م',
              ),
              _InfoRow(
                icon: Icons.timer,
                label: 'وقت التوصيل المتوقع',
                value:
                    '${_profile!.deliverySettings?.estimatedDeliveryTime ?? 30} دقيقة',
              ),
              _InfoRow(
                icon: Icons.radar,
                label: 'نطاق التوصيل',
                value:
                    '${_profile!.deliverySettings?.deliveryRadius ?? 5} كم',
              ),
              if (_profile!.deliverySettings?.freeDeliveryEnabled ?? false)
                _InfoRow(
                  icon: Icons.local_offer,
                  label: 'توصيل مجاني فوق',
                  value:
                      '${_profile!.deliverySettings?.freeDeliveryMinimum?.toStringAsFixed(2) ?? '0'} ج.م',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Bank Details Section
          _SectionCard(
            title: 'البيانات البنكية',
            icon: Icons.account_balance,
            onEdit: () => _showEditBankDetailsDialog(),
            children: [
              _InfoRow(
                icon: Icons.business,
                label: 'اسم البنك',
                value: _profile!.bankDetails?.bankName ?? 'غير محدد',
                isSecure: false,
              ),
              _InfoRow(
                icon: Icons.credit_card,
                label: 'رقم الحساب',
                value: _profile!.bankDetails?.accountNumber != null
                    ? _maskAccountNumber(_profile!.bankDetails!.accountNumber!)
                    : 'غير محدد',
                isSecure: true,
              ),
              _InfoRow(
                icon: Icons.person,
                label: 'اسم صاحب الحساب',
                value: _profile!.bankDetails?.accountHolderName ?? 'غير محدد',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildOpeningHoursRows() {
    final days = {
      'sunday': 'الأحد',
      'monday': 'الإثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
    };

    final List<Widget> rows = [];
    _profile!.openingHours!.forEach((key, value) {
      final dayName = days[key.toLowerCase()] ?? key;
      String hoursText;

      if (!value.isOpen) {
        hoursText = 'مغلق';
      } else if (value.openTime != null && value.closeTime != null) {
        hoursText = '${value.openTime} - ${value.closeTime}';
      } else {
        hoursText = 'غير محدد';
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  dayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hoursText,
                  style: TextStyle(
                    color: value.isOpen
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                value.isOpen ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: value.isOpen ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ),
      );
    });

    return rows;
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.menu_book,
                    label: 'القائمة',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.menu),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'الطلبات',
                    color: AppColors.info,
                    onTap: () => context.push(AppRoutes.orders),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.star,
                    label: 'التقييمات',
                    color: AppColors.rating,
                    onTap: () => context.push(AppRoutes.reviews),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.settings,
                    label: 'الإعدادات',
                    color: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    final visible = accountNumber.substring(accountNumber.length - 4);
    return '****$visible';
  }

  Future<void> _uploadLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null) return;

    setState(() => _isUploadingLogo = true);

    try {
      final service = ref.read(restaurantServiceProvider);
      final newLogoUrl = await service.updateLogo(image.path);

      if (mounted) {
        setState(() {
          _profile = RestaurantProfile(
            id: _profile!.id,
            name: _profile!.name,
            nameAr: _profile!.nameAr,
            description: _profile!.description,
            descriptionAr: _profile!.descriptionAr,
            logo: newLogoUrl,
            coverImage: _profile!.coverImage,
            phone: _profile!.phone,
            email: _profile!.email,
            address: _profile!.address,
            location: _profile!.location,
            cuisineTypes: _profile!.cuisineTypes,
            rating: _profile!.rating,
            reviewCount: _profile!.reviewCount,
            isOpen: _profile!.isOpen,
            isActive: _profile!.isActive,
            openingHours: _profile!.openingHours,
            deliverySettings: _profile!.deliverySettings,
            bankDetails: _profile!.bankDetails,
            createdAt: _profile!.createdAt,
          );
          _isUploadingLogo = false;
        });
        _showSuccess('تم تحديث الشعار بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _uploadCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image == null) return;

    setState(() => _isUploadingCover = true);

    try {
      final service = ref.read(restaurantServiceProvider);
      final newCoverUrl = await service.updateCoverImage(image.path);

      if (mounted) {
        setState(() {
          _profile = RestaurantProfile(
            id: _profile!.id,
            name: _profile!.name,
            nameAr: _profile!.nameAr,
            description: _profile!.description,
            descriptionAr: _profile!.descriptionAr,
            logo: _profile!.logo,
            coverImage: newCoverUrl,
            phone: _profile!.phone,
            email: _profile!.email,
            address: _profile!.address,
            location: _profile!.location,
            cuisineTypes: _profile!.cuisineTypes,
            rating: _profile!.rating,
            reviewCount: _profile!.reviewCount,
            isOpen: _profile!.isOpen,
            isActive: _profile!.isActive,
            openingHours: _profile!.openingHours,
            deliverySettings: _profile!.deliverySettings,
            bankDetails: _profile!.bankDetails,
            createdAt: _profile!.createdAt,
          );
          _isUploadingCover = false;
        });
        _showSuccess('تم تحديث صورة الغلاف بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingCover = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profile?.nameAr ?? _profile?.name);
    final descriptionController =
        TextEditingController(text: _profile?.descriptionAr ?? _profile?.description);
    final phoneController = TextEditingController(text: _profile?.phone);
    final emailController = TextEditingController(text: _profile?.email);
    final addressController = TextEditingController(text: _profile?.address);

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل معلومات المطعم',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المطعم',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.location_on),
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
                            final service = ref.read(restaurantServiceProvider);
                            final updatedProfile = await service.updateProfile(
                              nameAr: nameController.text,
                              descriptionAr: descriptionController.text,
                              phone: phoneController.text,
                              email: emailController.text,
                              address: addressController.text,
                            );

                            if (mounted && context.mounted) {
                              setState(() => _profile = updatedProfile);
                              Navigator.pop(context);
                              _showSuccess('تم تحديث البيانات بنجاح');
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
      ),
    );
  }

  void _showEditBankDetailsDialog() {
    final bankNameController =
        TextEditingController(text: _profile?.bankDetails?.bankName);
    final accountNumberController =
        TextEditingController(text: _profile?.bankDetails?.accountNumber);
    final accountHolderController =
        TextEditingController(text: _profile?.bankDetails?.accountHolderName);
    final ibanController =
        TextEditingController(text: _profile?.bankDetails?.iban);

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعديل البيانات البنكية',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم استخدام هذه البيانات لتحويل أرباحك',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم البنك',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم الحساب',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountHolderController,
                  decoration: const InputDecoration(
                    labelText: 'اسم صاحب الحساب',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ibanController,
                  decoration: const InputDecoration(
                    labelText: 'IBAN (اختياري)',
                    prefixIcon: Icon(Icons.numbers),
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
                            final service = ref.read(restaurantServiceProvider);
                            final updatedProfile = await service.updateBankDetails(
                              BankDetails(
                                bankName: bankNameController.text,
                                accountNumber: accountNumberController.text,
                                accountHolderName: accountHolderController.text,
                                iban: ibanController.text.isNotEmpty
                                    ? ibanController.text
                                    : null,
                              ),
                            );

                            if (mounted && context.mounted) {
                              setState(() => _profile = updatedProfile);
                              Navigator.pop(context);
                              _showSuccess('تم تحديث البيانات البنكية بنجاح');
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
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onEdit;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSecure;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isSecure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
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
