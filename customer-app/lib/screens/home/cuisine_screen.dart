import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import 'widgets/restaurant_card.dart';

/// Cuisine type data model
class CuisineType {
  final String id;
  final String name;
  final String nameAr;
  final String? imageUrl;
  final Color accentColor;

  const CuisineType({
    required this.id,
    required this.name,
    required this.nameAr,
    this.imageUrl,
    required this.accentColor,
  });
}

/// Screen showing restaurants filtered by cuisine type
class CuisineScreen extends ConsumerStatefulWidget {
  final String cuisineId;
  final String cuisineName;

  const CuisineScreen({
    super.key,
    required this.cuisineId,
    required this.cuisineName,
  });

  @override
  ConsumerState<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends ConsumerState<CuisineScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'rating';
  bool? _isOpenOnly;
  int? _priceRange;

  // Available cuisine types
  static const List<CuisineType> cuisineTypes = [
    CuisineType(
      id: 'egyptian',
      name: 'Egyptian',
      nameAr: 'مصري',
      accentColor: Color(0xFFD4AF37),
    ),
    CuisineType(
      id: 'lebanese',
      name: 'Lebanese',
      nameAr: 'لبناني',
      accentColor: Color(0xFF4CAF50),
    ),
    CuisineType(
      id: 'syrian',
      name: 'Syrian',
      nameAr: 'سوري',
      accentColor: Color(0xFFE91E63),
    ),
    CuisineType(
      id: 'turkish',
      name: 'Turkish',
      nameAr: 'تركي',
      accentColor: Color(0xFFE53935),
    ),
    CuisineType(
      id: 'indian',
      name: 'Indian',
      nameAr: 'هندي',
      accentColor: Color(0xFFFF9800),
    ),
    CuisineType(
      id: 'italian',
      name: 'Italian',
      nameAr: 'إيطالي',
      accentColor: Color(0xFF4CAF50),
    ),
    CuisineType(
      id: 'american',
      name: 'American',
      nameAr: 'أمريكي',
      accentColor: Color(0xFF2196F3),
    ),
    CuisineType(
      id: 'asian',
      name: 'Asian',
      nameAr: 'آسيوي',
      accentColor: Color(0xFFF44336),
    ),
    CuisineType(
      id: 'mexican',
      name: 'Mexican',
      nameAr: 'مكسيكي',
      accentColor: Color(0xFF8BC34A),
    ),
    CuisineType(
      id: 'mediterranean',
      name: 'Mediterranean',
      nameAr: 'بحر أبيض متوسط',
      accentColor: Color(0xFF00BCD4),
    ),
  ];

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
    // Use cuisine as a tag/category search
    final params = RestaurantSearchParams(
      search: widget.cuisineId,
      sortBy: _sortBy,
      sortOrder: _sortBy == 'rating' ? 'desc' : 'asc',
      isOpen: _isOpenOnly,
      priceRange: _priceRange,
    );
    ref.read(restaurantSearchProvider.notifier).search(params);
  }

  CuisineType? get _currentCuisine {
    try {
      return cuisineTypes.firstWhere((c) => c.id == widget.cuisineId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(restaurantSearchProvider);
    final cuisine = _currentCuisine;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with cuisine info
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.cuisineName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cuisine?.accentColor ?? AppColors.primary,
                      (cuisine?.accentColor ?? AppColors.primary)
                          .withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemBuilder: (context, index) => const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Cuisine icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilterBottomSheet,
                ),
              ),
            ],
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: _buildFilterSection(),
          ),

          // Results info
          SliverToBoxAdapter(
            child: _buildResultsInfo(searchState),
          ),

          // Restaurant list
          _buildRestaurantList(searchState),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort options
          Text(
            'ترتيب حسب',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip('rating', 'الأعلى تقييماً'),
                _buildSortChip('distance', 'الأقرب'),
                _buildSortChip('deliveryFee', 'أقل رسوم توصيل'),
                _buildSortChip('deliveryTime', 'الأسرع'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price range filter
          Text(
            'نطاق السعر',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (index) {
              final price = index + 1;
              final isSelected = _priceRange == price;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text('\$' * price),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _priceRange = selected ? price : null;
                    });
                    _fetchRestaurants();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              );
            }),
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
      ),
    );
  }

  Widget _buildResultsInfo(RestaurantSearchState state) {
    if (state.restaurants.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${state.restaurants.length} مطعم',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          if (_isOpenOnly == true)
            Chip(
              label: const Text('مفتوح'),
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
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(RestaurantSearchState state) {
    if (state.isLoading && state.restaurants.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.restaurants.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchRestaurants,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return SliverFillRemaining(
        child: Center(
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
                'لا توجد مطاعم بهذا المطبخ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'جرب البحث في أنواع مطابخ أخرى',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: state.restaurants.length + (state.hasMore ? 1 : 0),
        ),
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
                    activeColor: AppColors.primary,
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
                          _priceRange = null;
                        });
                        setState(() {
                          _isOpenOnly = null;
                          _priceRange = null;
                          _sortBy = 'rating';
                        });
                        _fetchRestaurants();
                        Navigator.pop(context);
                      },
                      child: const Text('إعادة تعيين الكل'),
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
