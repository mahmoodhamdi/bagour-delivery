import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/menu_service.dart';

/// Add menu item screen state
class AddMenuItemState {
  final List<MenuCategory> categories;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const AddMenuItemState({
    this.categories = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  AddMenuItemState copyWith({
    List<MenuCategory>? categories,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return AddMenuItemState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Add menu item notifier
class AddMenuItemNotifier extends StateNotifier<AddMenuItemState> {
  final MenuService _menuService;

  AddMenuItemNotifier(this._menuService) : super(const AddMenuItemState());

  /// Load categories
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final categories = await _menuService.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Create menu item
  Future<MenuItem?> createMenuItem({
    required String categoryId,
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    required double price,
    double? discountPrice,
    DateTime? discountEndsAt,
    int? preparationTime,
    int? calories,
    String? servingSize,
    List<MenuAddon>? addons,
    List<MenuVariation>? variations,
    bool isAvailable = true,
    bool isPopular = false,
    List<String>? tags,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final item = await _menuService.createMenuItem(
        categoryId: categoryId,
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        imagePath: imagePath,
        price: price,
        discountPrice: discountPrice,
        discountEndsAt: discountEndsAt,
        preparationTime: preparationTime,
        calories: calories,
        servingSize: servingSize,
        addons: addons,
        variations: variations,
        isAvailable: isAvailable,
        isPopular: isPopular,
        tags: tags,
      );
      state = state.copyWith(isSaving: false);
      return item;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Add menu item provider
final addMenuItemProvider =
    StateNotifierProvider.autoDispose<AddMenuItemNotifier, AddMenuItemState>(
        (ref) {
  final menuService = ref.watch(menuServiceProvider);
  return AddMenuItemNotifier(menuService);
});

/// Add menu item screen
class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  ConsumerState<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends ConsumerState<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Basic info
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  String? _selectedCategoryId;
  File? _imageFile;

  // Pricing
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  DateTime? _discountEndsAt;

  // Details
  final _preparationTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _servingSizeController = TextEditingController();

  // Options
  List<MenuAddon> _addons = [];
  List<MenuVariation> _variations = [];

  // Flags
  bool _isAvailable = true;
  bool _isPopular = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addMenuItemProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _preparationTimeController.dispose();
    _caloriesController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('معرض الصور'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    }
  }

  Future<void> _selectDiscountEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _discountEndsAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _discountEndsAt ?? DateTime.now().add(const Duration(hours: 1))),
      );
      if (time != null) {
        setState(() {
          _discountEndsAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addAddon() {
    _showAddonDialog();
  }

  void _editAddon(int index) {
    _showAddonDialog(addon: _addons[index], index: index);
  }

  void _removeAddon(int index) {
    setState(() => _addons.removeAt(index));
  }

  Future<void> _showAddonDialog({MenuAddon? addon, int? index}) async {
    final nameController = TextEditingController(text: addon?.name ?? '');
    final nameArController = TextEditingController(text: addon?.nameAr ?? '');
    final priceController =
        TextEditingController(text: addon?.price.toString() ?? '');
    final maxQtyController =
        TextEditingController(text: (addon?.maxQuantity ?? 5).toString());
    bool isAvailable = addon?.isAvailable ?? true;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(addon != null ? 'تعديل الاضافة' : 'اضافة جديدة'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameArController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم (عربي) *',
                      hintText: 'مثال: جبنة اضافية',
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالعربية مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم (انجليزي) *',
                      hintText: 'Example: Extra Cheese',
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالانجليزية مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر (ج.م) *',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v?.isEmpty == true ? 'السعر مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: maxQtyController,
                    decoration: const InputDecoration(
                      labelText: 'الحد الاقصى للكمية',
                      hintText: '5',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('متاح'),
                    value: isAvailable,
                    onChanged: (v) => setState(() => isAvailable = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('الغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(addon != null ? 'حفظ' : 'اضافة'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newAddon = MenuAddon(
        id: addon?.id,
        name: nameController.text,
        nameAr: nameArController.text,
        price: double.tryParse(priceController.text) ?? 0,
        maxQuantity: int.tryParse(maxQtyController.text) ?? 5,
        isAvailable: isAvailable,
      );

      setState(() {
        if (index != null) {
          _addons[index] = newAddon;
        } else {
          _addons.add(newAddon);
        }
      });
    }

    nameController.dispose();
    nameArController.dispose();
    priceController.dispose();
    maxQtyController.dispose();
  }

  void _addVariation() {
    _showVariationDialog();
  }

  void _editVariation(int index) {
    _showVariationDialog(variation: _variations[index], index: index);
  }

  void _removeVariation(int index) {
    setState(() => _variations.removeAt(index));
  }

  Future<void> _showVariationDialog(
      {MenuVariation? variation, int? index}) async {
    final nameController = TextEditingController(text: variation?.name ?? '');
    final nameArController =
        TextEditingController(text: variation?.nameAr ?? '');
    bool isRequired = variation?.isRequired ?? false;
    List<VariationOption> options = variation?.options.toList() ?? [];
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(variation != null ? 'تعديل الخيار' : 'خيار جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameArController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الخيار (عربي) *',
                      hintText: 'مثال: الحجم',
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالعربية مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الخيار (انجليزي) *',
                      hintText: 'Example: Size',
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالانجليزية مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('اجباري'),
                    subtitle: const Text('يجب على العميل اختيار احد الخيارات'),
                    value: isRequired,
                    onChanged: (v) => setDialogState(() => isRequired = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'القيم (${options.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final option = await _showOptionDialog(context);
                          if (option != null) {
                            setDialogState(() => options.add(option));
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('اضافة'),
                      ),
                    ],
                  ),
                  if (options.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'اضف على الاقل خيارين',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    )
                  else
                    ...options.asMap().entries.map((entry) {
                      final i = entry.key;
                      final opt = entry.value;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(opt.nameAr),
                        subtitle: Text('${opt.price.toStringAsFixed(0)} ج.م'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () async {
                                final edited =
                                    await _showOptionDialog(context, option: opt);
                                if (edited != null) {
                                  setDialogState(() => options[i] = edited);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: AppColors.error),
                              onPressed: () {
                                setDialogState(() => options.removeAt(i));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('الغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (options.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يجب اضافة على الاقل خيارين'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                }
              },
              child: Text(variation != null ? 'حفظ' : 'اضافة'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newVariation = MenuVariation(
        id: variation?.id,
        name: nameController.text,
        nameAr: nameArController.text,
        isRequired: isRequired,
        options: options,
      );

      setState(() {
        if (index != null) {
          _variations[index] = newVariation;
        } else {
          _variations.add(newVariation);
        }
      });
    }

    nameController.dispose();
    nameArController.dispose();
  }

  Future<VariationOption?> _showOptionDialog(BuildContext context,
      {VariationOption? option}) async {
    final nameController = TextEditingController(text: option?.name ?? '');
    final nameArController = TextEditingController(text: option?.nameAr ?? '');
    final priceController =
        TextEditingController(text: option?.price.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<VariationOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(option != null ? 'تعديل القيمة' : 'قيمة جديدة'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameArController,
                decoration: const InputDecoration(
                  labelText: 'الاسم (عربي) *',
                  hintText: 'مثال: صغير',
                ),
                textDirection: TextDirection.rtl,
                validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم (انجليزي) *',
                  hintText: 'Example: Small',
                ),
                textDirection: TextDirection.ltr,
                validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر الاضافي (ج.م)',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  VariationOption(
                    id: option?.id,
                    name: nameController.text,
                    nameAr: nameArController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                  ),
                );
              }
            },
            child: Text(option != null ? 'حفظ' : 'اضافة'),
          ),
        ],
      ),
    );

    nameController.dispose();
    nameArController.dispose();
    priceController.dispose();

    return result;
  }

  void _addTag() {
    _showTagDialog();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _showTagDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اضافة علامة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'العلامة',
            hintText: 'مثال: حار، نباتي',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('اضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _tags.add(result));
    }

    controller.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار القسم'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final notifier = ref.read(addMenuItemProvider.notifier);
    final price = double.tryParse(_priceController.text) ?? 0;
    final discountPrice = _discountPriceController.text.isNotEmpty
        ? double.tryParse(_discountPriceController.text)
        : null;

    if (discountPrice != null && discountPrice >= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سعر الخصم يجب ان يكون اقل من السعر الاصلي'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final item = await notifier.createMenuItem(
      categoryId: _selectedCategoryId!,
      name: _nameController.text,
      nameAr: _nameArController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      descriptionAr: _descriptionArController.text.isEmpty
          ? null
          : _descriptionArController.text,
      imagePath: _imageFile?.path,
      price: price,
      discountPrice: discountPrice,
      discountEndsAt: discountPrice != null ? _discountEndsAt : null,
      preparationTime: _preparationTimeController.text.isNotEmpty
          ? int.tryParse(_preparationTimeController.text)
          : null,
      calories: _caloriesController.text.isNotEmpty
          ? int.tryParse(_caloriesController.text)
          : null,
      servingSize: _servingSizeController.text.isEmpty
          ? null
          : _servingSizeController.text,
      addons: _addons.isNotEmpty ? _addons : null,
      variations: _variations.isNotEmpty ? _variations : null,
      isAvailable: _isAvailable,
      isPopular: _isPopular,
      tags: _tags.isNotEmpty ? _tags : null,
    );

    if (item != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم اضافة الصنف بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMenuItemProvider);
    final notifier = ref.read(addMenuItemProvider.notifier);

    // Listen for errors
    ref.listen<AddMenuItemState>(addMenuItemProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'اغلاق',
              textColor: AppColors.white,
              onPressed: () => notifier.clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('اضافة صنف جديد'),
        actions: [
          TextButton.icon(
            onPressed: state.isSaving ? null : _saveItem,
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.save, color: AppColors.white),
            label: const Text('حفظ', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Image
                  _buildImagePicker(),
                  const SizedBox(height: 24),

                  // Basic Info Section
                  _buildSectionTitle('المعلومات الاساسية'),
                  const SizedBox(height: 12),

                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'القسم *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: state.categories
                        .map((cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.nameAr),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                    validator: (v) => v == null ? 'يرجى اختيار القسم' : null,
                  ),
                  const SizedBox(height: 16),

                  // Arabic Name
                  TextFormField(
                    controller: _nameArController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الصنف (عربي) *',
                      hintText: 'مثال: شاورما دجاج',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالعربية مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // English Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الصنف (انجليزي) *',
                      hintText: 'Example: Chicken Shawarma',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (v) =>
                        v?.isEmpty == true ? 'الاسم بالانجليزية مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // Arabic Description
                  TextFormField(
                    controller: _descriptionArController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (عربي)',
                      hintText: 'وصف مختصر للصنف',
                      prefixIcon: Icon(Icons.description),
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // English Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (انجليزي)',
                      hintText: 'Short description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    textDirection: TextDirection.ltr,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  _buildSectionTitle('التسعير'),
                  const SizedBox(height: 12),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر (ج.م) *',
                      hintText: '0',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'السعر مطلوب';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return 'يرجى ادخال سعر صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Discount Price
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _discountPriceController,
                          decoration: const InputDecoration(
                            labelText: 'سعر الخصم (ج.م)',
                            hintText: '0',
                            prefixIcon: Icon(Icons.discount),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectDiscountEndDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'تاريخ انتهاء الخصم',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _discountEndsAt != null
                                  ? '${_discountEndsAt!.day}/${_discountEndsAt!.month}/${_discountEndsAt!.year}'
                                  : 'اختر التاريخ',
                              style: TextStyle(
                                color: _discountEndsAt != null
                                    ? null
                                    : AppColors.grey500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Details Section
                  _buildSectionTitle('التفاصيل'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _preparationTimeController,
                          decoration: const InputDecoration(
                            labelText: 'وقت التحضير (دقيقة)',
                            hintText: '15',
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _caloriesController,
                          decoration: const InputDecoration(
                            labelText: 'السعرات',
                            hintText: '250',
                            prefixIcon: Icon(Icons.local_fire_department),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _servingSizeController,
                    decoration: const InputDecoration(
                      labelText: 'حجم الوجبة',
                      hintText: 'مثال: قطعتين',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Addons Section
                  _buildSectionTitle('الاضافات'),
                  const SizedBox(height: 12),
                  _buildAddonsSection(),
                  const SizedBox(height: 24),

                  // Variations Section
                  _buildSectionTitle('الخيارات (الحجم، النوع...)'),
                  const SizedBox(height: 12),
                  _buildVariationsSection(),
                  const SizedBox(height: 24),

                  // Tags Section
                  _buildSectionTitle('العلامات'),
                  const SizedBox(height: 12),
                  _buildTagsSection(),
                  const SizedBox(height: 24),

                  // Flags Section
                  _buildSectionTitle('الحالة'),
                  const SizedBox(height: 12),
                  _buildFlagsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.border),
            image: _imageFile != null
                ? DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imageFile == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate,
                        size: 48, color: AppColors.grey500),
                    SizedBox(height: 8),
                    Text(
                      'اضافة صورة',
                      style: TextStyle(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.error,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppColors.white),
                          onPressed: () => setState(() => _imageFile = null),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAddonsSection() {
    return Column(
      children: [
        if (_addons.isNotEmpty)
          ...List.generate(_addons.length, (index) {
            final addon = _addons[index];
            return Card(
              child: ListTile(
                title: Text(addon.nameAr),
                subtitle: Text('${addon.price.toStringAsFixed(0)} ج.م'),
                leading: Icon(
                  addon.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: addon.isAvailable ? AppColors.success : AppColors.grey400,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editAddon(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _removeAddon(index),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addAddon,
          icon: const Icon(Icons.add),
          label: const Text('اضافة اضافة'),
        ),
      ],
    );
  }

  Widget _buildVariationsSection() {
    return Column(
      children: [
        if (_variations.isNotEmpty)
          ...List.generate(_variations.length, (index) {
            final variation = _variations[index];
            return Card(
              child: ExpansionTile(
                title: Text(variation.nameAr),
                subtitle: Text(
                  '${variation.options.length} خيارات${variation.isRequired ? ' - اجباري' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editVariation(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _removeVariation(index),
                    ),
                  ],
                ),
                children: variation.options
                    .map((opt) => ListTile(
                          dense: true,
                          title: Text(opt.nameAr),
                          trailing: Text(
                            opt.price > 0
                                ? '+${opt.price.toStringAsFixed(0)} ج.م'
                                : 'مجاني',
                          ),
                        ))
                    .toList(),
              ),
            );
          }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addVariation,
          icon: const Icon(Icons.add),
          label: const Text('اضافة خيار'),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(tag),
                )),
            ActionChip(
              label: const Text('+ اضافة'),
              onPressed: _addTag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagsSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('متاح'),
            subtitle: const Text('اظهار الصنف في القائمة'),
            value: _isAvailable,
            onChanged: (v) => setState(() => _isAvailable = v),
            activeColor: AppColors.success,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('شائع'),
            subtitle: const Text('اظهار شارة "شائع" على الصنف'),
            value: _isPopular,
            onChanged: (v) => setState(() => _isPopular = v),
            activeColor: AppColors.tertiary,
          ),
        ],
      ),
    );
  }
}
