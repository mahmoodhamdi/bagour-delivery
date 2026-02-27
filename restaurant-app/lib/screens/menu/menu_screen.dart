import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../services/menu_service.dart';

/// Menu state for the screen
class MenuScreenState {
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingItems;
  final String? error;
  final bool? filterAvailable;

  const MenuScreenState({
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingItems = false,
    this.error,
    this.filterAvailable,
  });

  MenuScreenState copyWith({
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingItems,
    String? error,
    bool? filterAvailable,
    bool clearSelectedCategory = false,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return MenuScreenState(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId:
          clearSelectedCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      error: clearError ? null : (error ?? this.error),
      filterAvailable: clearFilter ? null : (filterAvailable ?? this.filterAvailable),
    );
  }
}

/// Menu notifier for state management
class MenuNotifier extends StateNotifier<MenuScreenState> {
  final MenuService _menuService;

  MenuNotifier(this._menuService) : super(const MenuScreenState());

  /// Load initial data
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final categories = await _menuService.getCategories();
      final itemsResult = await _menuService.getMenuItems();
      state = state.copyWith(
        categories: categories,
        items: itemsResult.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Select category filter
  Future<void> selectCategory(String? categoryId) async {
    if (categoryId == state.selectedCategoryId) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
    await _loadItems();
  }

  /// Search items
  Future<void> searchItems(String query) async {
    state = state.copyWith(searchQuery: query);
    await _loadItems();
  }

  /// Filter by availability
  Future<void> filterByAvailability(bool? isAvailable) async {
    if (isAvailable == state.filterAvailable) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterAvailable: isAvailable);
    }
    await _loadItems();
  }

  /// Load items with current filters
  Future<void> _loadItems() async {
    state = state.copyWith(isLoadingItems: true);
    try {
      final result = await _menuService.getMenuItems(
        categoryId: state.selectedCategoryId,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        isAvailable: state.filterAvailable,
      );
      state = state.copyWith(items: result.data, isLoadingItems: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingItems: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Toggle item availability
  Future<void> toggleItemAvailability(String itemId, bool isAvailable) async {
    try {
      await _menuService.toggleItemAvailability(
        itemId: itemId,
        isAvailable: isAvailable,
      );
      // Update local state
      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isAvailable: isAvailable);
        }
        return item;
      }).toList();
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Delete item
  Future<bool> deleteItem(String itemId) async {
    try {
      await _menuService.deleteMenuItem(itemId);
      final updatedItems =
          state.items.where((item) => item.id != itemId).toList();
      state = state.copyWith(items: updatedItems);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Duplicate item
  Future<bool> duplicateItem(String itemId) async {
    try {
      final newItem = await _menuService.duplicateMenuItem(itemId);
      state = state.copyWith(items: [...state.items, newItem]);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Menu provider
final menuProvider =
    StateNotifierProvider.autoDispose<MenuNotifier, MenuScreenState>((ref) {
  final menuService = ref.watch(menuServiceProvider);
  return MenuNotifier(menuService);
});

/// Menu management screen
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabController(int length) {
    if (_tabController.length != length) {
      _tabController.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuProvider);
    final notifier = ref.read(menuProvider.notifier);

    // Listen for errors
    ref.listen<MenuScreenState>(menuProvider, (previous, next) {
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

    // Update tab controller when categories change
    final tabCount = state.categories.length + 1; // +1 for "All" tab
    _updateTabController(tabCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الطعام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'ادارة الاقسام',
            onPressed: () => context.push(AppRoutes.categories),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث في القائمة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.searchItems('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => notifier.searchItems(value),
                ),
              ),
              // Category tabs
              if (state.categories.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
                  indicatorColor: AppColors.white,
                  indicatorWeight: 3,
                  tabs: [
                    const Tab(text: 'الكل'),
                    ...state.categories.map((cat) => Tab(text: cat.nameAr)),
                  ],
                  onTap: (index) {
                    if (index == 0) {
                      notifier.selectCategory(null);
                    } else {
                      notifier.selectCategory(state.categories[index - 1].id);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: notifier.refresh,
              child: Column(
                children: [
                  // Filter chips
                  _buildFilterChips(state, notifier),
                  // Items list
                  Expanded(
                    child: state.isLoadingItems
                        ? const Center(child: CircularProgressIndicator())
                        : state.items.isEmpty
                            ? _buildEmptyState()
                            : _buildItemsList(state, notifier),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addMenuItem),
        icon: const Icon(Icons.add),
        label: const Text('اضافة صنف'),
      ),
    );
  }

  Widget _buildFilterChips(MenuScreenState state, MenuNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('متاح'),
              selected: state.filterAvailable == true,
              onSelected: (_) => notifier.filterByAvailability(true),
              selectedColor: AppColors.successLight,
              checkmarkColor: AppColors.success,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('غير متاح'),
              selected: state.filterAvailable == false,
              onSelected: (_) => notifier.filterByAvailability(false),
              selectedColor: AppColors.errorLight,
              checkmarkColor: AppColors.error,
            ),
            if (state.filterAvailable != null) ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('مسح الفلتر'),
                onPressed: () => notifier.filterByAvailability(null),
                avatar: const Icon(Icons.clear, size: 16),
              ),
            ],
          ],
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
            Icons.restaurant_menu,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد اصناف',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضف اصناف جديدة لقائمة الطعام',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addMenuItem),
            icon: const Icon(Icons.add),
            label: const Text('اضافة صنف'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(MenuScreenState state, MenuNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _MenuItemCard(
          item: item,
          onToggleAvailability: (isAvailable) {
            notifier.toggleItemAvailability(item.id, isAvailable);
          },
          onEdit: () => context.goToEditMenuItem(item.id),
          onDelete: () => _showDeleteDialog(item, notifier),
          onDuplicate: () => _duplicateItem(item, notifier),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(MenuItem item, MenuNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصنف'),
        content: Text('هل انت متأكد من حذف "${item.nameAr}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('الغاء'),
          ),
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
      final success = await notifier.deleteItem(item.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الصنف بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _duplicateItem(MenuItem item, MenuNotifier notifier) async {
    final success = await notifier.duplicateItem(item.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ الصنف بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Menu item card widget
class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final ValueChanged<bool> onToggleAvailability;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _MenuItemCard({
    required this.item,
    required this.onToggleAvailability,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onEdit,
        borderRadius: AppRadius.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: AppRadius.radiusSm,
                child: item.image != null
                    ? Image.network(
                        item.image!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.nameAr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'شائع',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (item.isNewItem) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'جديد',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Category
                    if (item.categoryNameAr != null)
                      Text(
                        item.categoryNameAr!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    // Description
                    if (item.descriptionAr != null &&
                        item.descriptionAr!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.descriptionAr!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Price and actions
                    Row(
                      children: [
                        // Price
                        if (item.hasDiscount) ...[
                          Text(
                            '${item.discountPrice!.toStringAsFixed(0)} ج.م',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.price.toStringAsFixed(0)} ج.م',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.grey500,
                                ),
                          ),
                        ] else
                          Text(
                            '${item.price.toStringAsFixed(0)} ج.م',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        const Spacer(),
                        // Availability toggle
                        Switch(
                          value: item.isAvailable,
                          onChanged: onToggleAvailability,
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu button
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
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy_outlined),
                        SizedBox(width: 8),
                        Text('نسخ'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'حذف',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'duplicate':
                      onDuplicate();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.grey200,
      child: const Icon(
        Icons.restaurant,
        size: 32,
        color: AppColors.grey400,
      ),
    );
  }
}
