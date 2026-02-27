import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import 'widgets/restaurant_card.dart';

/// Screen showing restaurants filtered by category
class CategoryRestaurantsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryRestaurantsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryRestaurantsScreen> createState() =>
      _CategoryRestaurantsScreenState();
}

class _CategoryRestaurantsScreenState
    extends ConsumerState<CategoryRestaurantsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'rating';
  bool? _isOpenOnly;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchRestaurants();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(restaurantSearchProvider.notifier).loadMore();
    }
  }

  void _fetchRestaurants() {
    final params = RestaurantSearchParams(
      category: widget.categoryId,
      sortBy: _sortBy,
      sortOrder: _sortBy == 'rating' ? 'desc' : 'asc',
      isOpen: _isOpenOnly,
    );
    ref.read(restaurantSearchProvider.notifier).search(params);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(restaurantSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort and filter bar
          _buildSortBar(),

          // Results count
          if (searchState.restaurants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${searchState.restaurants.length} مطعم',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  if (_isOpenOnly == true)
                    Chip(
                      label: const Text('مفتوح الآن'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _isOpenOnly = null;
                        });
                        _fetchRestaurants();
                      },
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

          // Restaurant list
          Expanded(
            child: _buildRestaurantList(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(
            Icons.sort,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'ترتيب حسب:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('rating', 'التقييم'),
                  _buildSortChip('distance', 'المسافة'),
                  _buildSortChip('deliveryFee', 'رسوم التوصيل'),
                  _buildSortChip('deliveryTime', 'وقت التوصيل'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _sortBy = value;
            });
            _fetchRestaurants();
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildRestaurantList(RestaurantSearchState state) {
    if (state.isLoading && state.restaurants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRestaurants,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مطاعم في هذا القسم',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث في أقسام أخرى',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة للأقسام'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchRestaurants();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.restaurants.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.restaurants.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final restaurant = state.restaurants[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(
              restaurant: restaurant,
              isHorizontal: true,
              onTap: () => context.push('/restaurant/${restaurant.slug}'),
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'خيارات التصفية',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Open now filter
                  SwitchListTile(
                    title: const Text('مفتوح الآن فقط'),
                    subtitle: const Text('عرض المطاعم المفتوحة حالياً'),
                    value: _isOpenOnly ?? false,
                    onChanged: (value) {
                      setModalState(() {
                        _isOpenOnly = value ? true : null;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        _fetchRestaurants();
                        Navigator.pop(context);
                      },
                      child: const Text('تطبيق'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setModalState(() {
                          _isOpenOnly = null;
                        });
                        setState(() {
                          _isOpenOnly = null;
                        });
                        _fetchRestaurants();
                        Navigator.pop(context);
                      },
                      child: const Text('إعادة تعيين'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
