import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/restaurant.dart';
import '../home/widgets/restaurant_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showFilters = false;

  // Filter state
  String? _selectedCategory;
  int? _selectedPriceRange;
  bool? _isOpenNow;
  String _sortBy = 'rating';

  final List<Map<String, dynamic>> _categories = [
    {'id': null, 'name': 'الكل', 'icon': Icons.restaurant},
    {'id': 'pizza', 'name': 'بيتزا', 'icon': Icons.local_pizza},
    {'id': 'burger', 'name': 'برجر', 'icon': Icons.lunch_dining},
    {'id': 'grill', 'name': 'مشويات', 'icon': Icons.kebab_dining},
    {'id': 'oriental', 'name': 'شرقي', 'icon': Icons.ramen_dining},
    {'id': 'pastry', 'name': 'معجنات', 'icon': Icons.bakery_dining},
    {'id': 'dessert', 'name': 'حلويات', 'icon': Icons.icecream},
    {'id': 'drinks', 'name': 'مشروبات', 'icon': Icons.local_cafe},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(restaurantSearchProvider.notifier).loadMore();
    }
  }

  void _search() {
    final params = RestaurantSearchParams(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      category: _selectedCategory,
      priceRange: _selectedPriceRange,
      isOpen: _isOpenNow,
      sortBy: _sortBy,
      sortOrder: _sortBy == 'rating' ? 'desc' : 'asc',
    );
    ref.read(restaurantSearchProvider.notifier).search(params);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedPriceRange = null;
      _isOpenNow = null;
      _sortBy = 'rating';
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(restaurantSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSearchField(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories
          _buildCategoriesRow(),

          // Filters Toggle
          _buildFilterToggle(),

          // Filters Panel
          if (_showFilters) _buildFiltersPanel(),

          // Results
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'ابحث عن مطعم أو طبق...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(restaurantSearchProvider.notifier).clear();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      onChanged: (value) {
        setState(() {});
        if (value.length >= 2) {
          _search();
        }
      },
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(category['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category['id'] : null;
                });
                _search();
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _showFilters = !_showFilters;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _showFilters ? Icons.tune : Icons.tune_outlined,
              color: _hasActiveFilters
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'فلترة النتائج',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _hasActiveFilters
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _activeFiltersCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              _showFilters
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedPriceRange != null || _isOpenNow != null || _sortBy != 'rating';

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedPriceRange != null) count++;
    if (_isOpenNow != null) count++;
    if (_sortBy != 'rating') count++;
    return count;
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Range
          Text(
            'نطاق السعر',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(4, (index) {
              final priceRange = index + 1;
              final isSelected = _selectedPriceRange == priceRange;
              return ChoiceChip(
                label: Text('\$' * priceRange),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriceRange = selected ? priceRange : null;
                  });
                  _search();
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Open Now
          Row(
            children: [
              Text(
                'مفتوح الآن',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Switch(
                value: _isOpenNow ?? false,
                onChanged: (value) {
                  setState(() {
                    _isOpenNow = value ? true : null;
                  });
                  _search();
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sort By
          Text(
            'ترتيب حسب',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('rating', 'التقييم'),
              _buildSortChip('distance', 'المسافة'),
              _buildSortChip('deliveryFee', 'رسوم التوصيل'),
              _buildSortChip('deliveryTime', 'وقت التوصيل'),
            ],
          ),
          const SizedBox(height: 16),

          // Clear Filters
          if (_hasActiveFilters)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  _clearFilters();
                  _search();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('مسح الفلاتر'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = selected ? value : 'rating';
        });
        _search();
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildResults(RestaurantSearchState state) {
    if (state.isLoading && state.restaurants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _search,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.restaurants.isEmpty && state.params != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة أو تغيير الفلاتر',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _clearFilters();
                  _search();
                },
                child: const Text('مسح الفلاتر'),
              ),
            ],
          ],
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return _buildInitialState();
    }

    return ListView.builder(
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
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Searches
          Text(
            'عمليات بحث شائعة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchSuggestion('بيتزا'),
              _buildSearchSuggestion('برجر'),
              _buildSearchSuggestion('شاورما'),
              _buildSearchSuggestion('فطور'),
              _buildSearchSuggestion('حلويات'),
              _buildSearchSuggestion('قهوة'),
            ],
          ),
          const SizedBox(height: 24),

          // Tips
          Text(
            'نصائح البحث',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildSearchTip(
            Icons.restaurant,
            'ابحث باسم المطعم',
            'مثال: "مطعم الفلاحين"',
          ),
          _buildSearchTip(
            Icons.fastfood,
            'ابحث باسم الطبق',
            'مثال: "بيتزا مارغريتا"',
          ),
          _buildSearchTip(
            Icons.category,
            'ابحث بنوع الطعام',
            'مثال: "مشويات" أو "حلويات"',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestion(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _searchController.text = text;
        _search();
      },
      backgroundColor: AppColors.surface,
    );
  }

  Widget _buildSearchTip(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
