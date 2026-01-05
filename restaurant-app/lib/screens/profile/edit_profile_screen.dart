import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _deliveryTimeController = TextEditingController();

  File? _logoFile;
  File? _coverFile;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final restaurant = ref.read(restaurantProvider).restaurant;
    if (restaurant != null && !_isInitialized) {
      setState(() {
        _nameController.text = restaurant.name ?? '';
        _nameEnController.text = restaurant.nameEn ?? '';
        _descriptionController.text = restaurant.description ?? '';
        _phoneController.text = restaurant.phone ?? '';
        _addressController.text = restaurant.address ?? '';
        _minOrderController.text = restaurant.minOrderAmount?.toString() ?? '';
        _deliveryTimeController.text = restaurant.deliveryTime?.toString() ?? '';
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _minOrderController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isLogo ? 512 : 1920,
      maxHeight: isLogo ? 512 : 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(pickedFile.path);
        } else {
          _coverFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(restaurantProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        minOrderAmount: double.tryParse(_minOrderController.text),
        deliveryTime: int.tryParse(_deliveryTimeController.text),
        logoFile: _logoFile,
        coverFile: _coverFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث الملف الشخصي: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantProvider);

    if (restaurantState.isLoading && !_isInitialized) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _coverFile != null
                        ? DecorationImage(
                            image: FileImage(_coverFile!),
                            fit: BoxFit.cover,
                          )
                        : restaurantState.restaurant?.coverImage != null
                            ? DecorationImage(
                                image: NetworkImage(restaurantState.restaurant!.coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: _coverFile == null && restaurantState.restaurant?.coverImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('صورة الغلاف', style: TextStyle(color: Colors.grey[600])),
                          ],
                        )
                      : null,
                ),
              ),

              // Logo
              Transform.translate(
                offset: const Offset(0, -40),
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                        image: _logoFile != null
                            ? DecorationImage(
                                image: FileImage(_logoFile!),
                                fit: BoxFit.cover,
                              )
                            : restaurantState.restaurant?.logo != null
                                ? DecorationImage(
                                    image: NetworkImage(restaurantState.restaurant!.logo!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: _logoFile == null && restaurantState.restaurant?.logo == null
                          ? Icon(Icons.restaurant, size: 32, color: Colors.grey[400])
                          : null,
                    ),
                  ),
                ),
              ),

              CustomTextField(
                controller: _nameController,
                label: 'اسم المطعم (عربي)',
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameEnController,
                label: 'اسم المطعم (إنجليزي)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'الوصف',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'العنوان',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _minOrderController,
                      label: 'الحد الأدنى للطلب',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _deliveryTimeController,
                      label: 'وقت التوصيل (دقيقة)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _handleSubmit,
                text: 'حفظ التغييرات',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
