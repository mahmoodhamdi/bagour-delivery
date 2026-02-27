import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/menu_service.dart';

/// Categories state
class CategoriesState {
  final List<MenuCategory> categories;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  CategoriesState copyWith({
    List<MenuCategory>? categories,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
    bool clearError = false,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// Categories notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final MenuService _menuService;

  CategoriesNotifier(this._menuService) : super(const CategoriesState());

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

  /// Reorder categories locally
  void reorderCategories(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = List<MenuCategory>.from(state.categories);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update sort order
    final updatedItems = items.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();

    state = state.copyWith(categories: updatedItems, hasUnsavedChanges: true);
  }

  /// Save reordered categories
  Future<bool> saveOrder() async {
    if (!state.hasUnsavedChanges) return true;

    state = state.copyWith(isSaving: true);
    try {
      final orderedCategories = state.categories
          .map((cat) => {'id': cat.id, 'sortOrder': cat.sortOrder})
          .toList();
      await _menuService.reorderCategories(orderedCategories);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Create category
  Future<bool> createCategory({
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final newCategory = await _menuService.createCategory(
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        imagePath: imagePath,
      );
      state = state.copyWith(
        categories: [...state.categories, newCategory],
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Update category
  Future<bool> updateCategory({
    required String categoryId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    bool? isActive,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final updatedCategory = await _menuService.updateCategory(
        categoryId: categoryId,
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        imagePath: imagePath,
        isActive: isActive,
      );
      final updatedCategories = state.categories.map((cat) {
        if (cat.id == categoryId) {
          return updatedCategory;
        }
        return cat;
      }).toList();
      state = state.copyWith(categories: updatedCategories, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Toggle category active status
  Future<void> toggleCategoryActive(String categoryId, bool isActive) async {
    try {
      await _menuService.updateCategory(
        categoryId: categoryId,
        isActive: isActive,
      );
      final updatedCategories = state.categories.map((cat) {
        if (cat.id == categoryId) {
          return cat.copyWith(isActive: isActive);
        }
        return cat;
      }).toList();
      state = state.copyWith(categories: updatedCategories);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    state = state.copyWith(isSaving: true);
    try {
      await _menuService.deleteCategory(categoryId);
      final updatedCategories =
          state.categories.where((cat) => cat.id != categoryId).toList();
      state = state.copyWith(categories: updatedCategories, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Categories provider
final categoriesProvider =
    StateNotifierProvider.autoDispose<CategoriesNotifier, CategoriesState>(
        (ref) {
  final menuService = ref.watch(menuServiceProvider);
  return CategoriesNotifier(menuService);
});

/// Categories management screen
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesProvider);
    final notifier = ref.read(categoriesProvider.notifier);

    // Listen for errors
    ref.listen<CategoriesState>(categoriesProvider, (previous, next) {
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

    return PopScope(
      canPop: !state.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && state.hasUnsavedChanges) {
          final shouldSave = await _showUnsavedChangesDialog();
          if (shouldSave == true) {
            final success = await notifier.saveOrder();
            if (success && context.mounted) {
              Navigator.pop(context);
            }
          } else if (shouldSave == false && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ادارة الاقسام'),
          actions: [
            if (state.hasUnsavedChanges)
              TextButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final success = await notifier.saveOrder();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ الترتيب بنجاح'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
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
                label: const Text(
                  'حفظ',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.categories.isEmpty
                ? _buildEmptyState()
                : _buildCategoriesList(state, notifier),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCategoryDialog(),
          icon: const Icon(Icons.add),
          label: const Text('قسم جديد'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد اقسام',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضف اقسام لتنظيم قائمة الطعام',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('اضافة قسم'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(CategoriesState state, CategoriesNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.infoLight,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'اسحب واسقط لاعادة ترتيب الاقسام',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.info,
                      ),
                ),
              ),
            ],
          ),
        ),
        // Categories list
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: state.categories.length,
            onReorder: notifier.reorderCategories,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final animValue = Curves.easeInOut.transform(animation.value);
                  final elevation = 4 + (animValue * 4);
                  return Material(
                    elevation: elevation,
                    borderRadius: AppRadius.radiusMd,
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _CategoryCard(
                key: ValueKey(category.id),
                category: category,
                onEdit: () => _showCategoryDialog(category: category),
                onDelete: () => _showDeleteDialog(category, notifier),
                onToggleActive: (isActive) {
                  notifier.toggleCategoryActive(category.id, isActive);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغييرات غير محفوظة'),
        content: const Text('لديك تغييرات غير محفوظة. هل تريد حفظها؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تجاهل'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog({MenuCategory? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final nameArController = TextEditingController(text: category?.nameAr ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    final descriptionArController =
        TextEditingController(text: category?.descriptionAr ?? '');
    String? imagePath;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'تعديل القسم' : 'قسم جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => imagePath = image.path);
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.border),
                        image: imagePath != null
                            ? DecorationImage(
                                image: AssetImage(imagePath!),
                                fit: BoxFit.cover,
                              )
                            : category?.image != null
                                ? DecorationImage(
                                    image: NetworkImage(category!.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (imagePath == null && category?.image == null)
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 32, color: AppColors.grey500),
                                SizedBox(height: 4),
                                Text(
                                  'اضافة صورة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Arabic name
                  TextFormField(
                    controller: nameArController,
                    decoration: const InputDecoration(
                      labelText: 'اسم القسم (عربي) *',
                      hintText: 'مثال: المشويات',
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الاسم بالعربية مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // English name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم القسم (انجليزي) *',
                      hintText: 'Example: Grills',
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الاسم بالانجليزية مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Arabic description
                  TextFormField(
                    controller: descriptionArController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (عربي)',
                      hintText: 'وصف اختياري للقسم',
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // English description
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (انجليزي)',
                      hintText: 'Optional description',
                    ),
                    textDirection: TextDirection.ltr,
                    maxLines: 2,
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
              child: Text(isEditing ? 'حفظ' : 'اضافة'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final notifier = ref.read(categoriesProvider.notifier);
      bool success;
      if (isEditing) {
        success = await notifier.updateCategory(
          categoryId: category.id,
          name: nameController.text,
          nameAr: nameArController.text,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          descriptionAr: descriptionArController.text.isEmpty
              ? null
              : descriptionArController.text,
          imagePath: imagePath,
        );
      } else {
        success = await notifier.createCategory(
          name: nameController.text,
          nameAr: nameArController.text,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          descriptionAr: descriptionArController.text.isEmpty
              ? null
              : descriptionArController.text,
          imagePath: imagePath,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? 'تم تحديث القسم بنجاح' : 'تم اضافة القسم بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    nameController.dispose();
    nameArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
  }

  Future<void> _showDeleteDialog(
      MenuCategory category, CategoriesNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القسم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل انت متأكد من حذف "${category.nameAr}"؟'),
            if (category.itemCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'هذا القسم يحتوي على ${category.itemCount} صنف. يجب نقل او حذف الاصناف اولا.',
                        style: const TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('الغاء'),
          ),
          if (category.itemCount == 0)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('حذف'),
            ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await notifier.deleteCategory(category.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف القسم بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

/// Category card widget
class _CategoryCard extends StatelessWidget {
  final MenuCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: AppColors.grey400),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: AppRadius.radiusSm,
              child: category.image != null
                  ? Image.network(
                      category.image!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ],
        ),
        title: Text(
          category.nameAr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? AppColors.successLight
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isActive ? 'نشط' : 'معطل',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          category.isActive ? AppColors.success : AppColors.grey600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${category.itemCount} صنف',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: category.isActive,
              onChanged: onToggleActive,
              activeThumbColor: AppColors.success,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  enabled: category.itemCount == 0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: category.itemCount == 0
                            ? AppColors.error
                            : AppColors.grey400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حذف',
                        style: TextStyle(
                          color: category.itemCount == 0
                              ? AppColors.error
                              : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.grey200,
      child: const Icon(
        Icons.category,
        size: 24,
        color: AppColors.grey400,
      ),
    );
  }
}
