import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _restaurantNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showError('يجب الموافقة على الشروط والاحكام');
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          restaurantName: _restaurantNameController.text.trim(),
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authProvider);
    authState.mapOrNull(
      requiresVerification: (state) {
        context.push(
          AppRoutes.otp,
          extra: {
            'email': state.email,
            'type': 'email_verification',
          },
        );
      },
      error: (error) => _showError(error.message),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
    ref.read(authProvider.notifier).clearError();
  }

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'الشروط والاحكام',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '''
شروط واحكام استخدام تطبيق توصيل الباجور للمطاعم

1. التسجيل والحساب
- يجب ان تكون صاحب مطعم مرخص للتسجيل في التطبيق
- يجب تقديم معلومات صحيحة ودقيقة عند التسجيل
- انت مسؤول عن الحفاظ على سرية بيانات حسابك

2. الطلبات والتوصيل
- يجب قبول الطلبات في الوقت المناسب
- يجب تحضير الطلبات بجودة عالية
- يجب الالتزام بمعايير النظافة والسلامة الغذائية

3. العمولات والدفع
- يتم خصم عمولة من كل طلب وفقا للاتفاقية
- يتم تحويل الارباح اسبوعيا الى حسابك البنكي

4. التقييمات
- يحق للعملاء تقييم المطعم والطلبات
- التقييمات السلبية المتكررة قد تؤدي لايقاف الحساب

5. الغاء الحساب
- يمكنك الغاء حسابك في اي وقت
- نحتفظ بحق ايقاف الحساب في حالة مخالفة الشروط

للمزيد من المعلومات، تواصل معنا على support@bagourdelivery.com
                  ''',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.8,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'سياسة الخصوصية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '''
سياسة الخصوصية لتطبيق توصيل الباجور للمطاعم

1. البيانات التي نجمعها
- معلومات الحساب (الاسم، البريد الالكتروني، رقم الهاتف)
- معلومات المطعم (الاسم، العنوان، الترخيص)
- بيانات الطلبات والمبيعات

2. كيف نستخدم بياناتك
- لتقديم خدمات التوصيل
- لتحسين تجربة المستخدم
- للتواصل معك بخصوص الطلبات
- لارسال اشعارات مهمة

3. حماية البيانات
- نستخدم تشفير SSL لحماية بياناتك
- نخزن البيانات في خوادم امنة
- لا نشارك بياناتك مع اطراف ثالثة

4. حقوقك
- يمكنك طلب نسخة من بياناتك
- يمكنك طلب حذف بياناتك
- يمكنك تعديل بياناتك في اي وقت

للاستفسارات، تواصل معنا على privacy@bagourdelivery.com
                  ''',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.8,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انشاء حساب مطعم'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section: Owner Info
                _buildSectionHeader('معلومات صاحب المطعم'),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الاسم مطلوب';
                    }
                    if (value.length < 2) {
                      return 'الاسم يجب ان يكون حرفين على الاقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'البريد الالكتروني',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'البريد الالكتروني مطلوب';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'البريد الالكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '01XXXXXXXXX',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'رقم الهاتف مطلوب';
                    }
                    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                      return 'رقم الهاتف غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section: Restaurant Info
                _buildSectionHeader('معلومات المطعم'),
                const SizedBox(height: 16),

                // Restaurant name field
                TextFormField(
                  controller: _restaurantNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'اسم المطعم',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'اسم المطعم مطلوب';
                    }
                    if (value.length < 2) {
                      return 'اسم المطعم يجب ان يكون حرفين على الاقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address field (optional)
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المطعم (اختياري)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'ادخل عنوان المطعم بالتفصيل',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Security
                _buildSectionHeader('الامان'),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'كلمة المرور مطلوبة';
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return 'كلمة المرور يجب ان تكون ${AppConstants.minPasswordLength} احرف على الاقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'تاكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تاكيد كلمة المرور مطلوب';
                    }
                    if (value != _passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Terms and conditions checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() => _acceptedTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'اوافق على '),
                              TextSpan(
                                text: 'الشروط والاحكام',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsAndConditions,
                              ),
                              const TextSpan(text: ' و '),
                              TextSpan(
                                text: 'سياسة الخصوصية',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showPrivacyPolicy,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('انشاء حساب'),
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
