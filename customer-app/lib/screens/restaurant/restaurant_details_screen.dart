import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/restaurant.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/restaurant_header.dart';

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  final String slug;

  const RestaurantDetailsScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState
    extends ConsumerState<RestaurantDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _fetchRestaurant();
  }

  void _fetchRestaurant() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(restaurantDetailsProvider.notifier).fetchRestaurant(widget.slug);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailsProvider);

    if (state.isLoading && state.restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchRestaurant,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final restaurant = state.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('المطعم غير موجود')),
      );
    }

    // Initialize tab controller when menu is loaded
    if (_tabController == null && state.menu.isNotEmpty) {
      _tabController = TabController(
        length: state.menu.length,
        vsync: this,
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Restaurant Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RestaurantHeader(restaurant: restaurant),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    restaurant.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: restaurant.isFavorite
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    ref.read(restaurantDetailsProvider.notifier).toggleFavorite();
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Share restaurant
                  },
                ),
              ),
            ],
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: _buildRestaurantInfo(context, restaurant),
          ),

          // Menu Tabs
          if (state.menu.isNotEmpty && _tabController != null) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: state.menu
                      .map((category) => Tab(text: category.name))
                      .toList(),
                ),
              ),
            ),
          ],

          // Menu Items
          if (state.menu.isNotEmpty && _tabController != null)
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: state.menu.map((category) {
                  return _buildMenuCategory(context, category, restaurant);
                }).toList(),
              ),
            )
          else if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            const SliverFillRemaining(
              child: Center(child: Text('لا توجد قائمة طعام')),
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(BuildContext context, Restaurant restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              _buildStatusBadge(restaurant),
            ],
          ),
          const SizedBox(height: 8),

          // Categories
          if (restaurant.categories.isNotEmpty)
            Text(
              restaurant.categories.join(' • '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          const SizedBox(height: 12),

          // Info Row
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.rating.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.rating),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      ' (${restaurant.totalRatings})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Delivery Time
              if (restaurant.estimatedDeliveryTime != null) ...[
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${restaurant.estimatedDeliveryTime!.min}-${restaurant.estimatedDeliveryTime!.max} دقيقة',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
              ],

              // Minimum Order
              if (restaurant.minimumOrder > 0) ...[
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'الحد الأدنى ${restaurant.minimumOrder.toStringAsFixed(0)} ج.م',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Delivery Fee
          Row(
            children: [
              const Icon(
                Icons.delivery_dining,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.deliveryFee == 0
                    ? 'توصيل مجاني'
                    : 'رسوم التوصيل: ${restaurant.deliveryFee.toStringAsFixed(0)} ج.م',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: restaurant.deliveryFee == 0
                          ? AppColors.success
                          : null,
                    ),
              ),
              if (restaurant.freeDeliveryAbove != null &&
                  restaurant.deliveryFee > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '(مجاني للطلبات أعلى من ${restaurant.freeDeliveryAbove!.toStringAsFixed(0)} ج.م)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ],
            ],
          ),

          // Description
          if (restaurant.description != null &&
              restaurant.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              restaurant.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Restaurant restaurant) {
    if (!restaurant.isOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'مغلق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (restaurant.isPaused) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'مشغول',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'مفتوح',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuCategory(BuildContext context, MenuCategory category, Restaurant restaurant) {
    if (category.items.isEmpty) {
      return const Center(
        child: Text('لا توجد أصناف في هذا القسم'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: category.items.length,
      itemBuilder: (context, index) {
        final item = category.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MenuItemCard(
            item: item,
            onTap: () {
              context.push(
                AppRoutes.menuItem,
                extra: {
                  'menuItem': item,
                  'restaurant': restaurant,
                },
              );
            },
            onAddToCart: () {
              // Quick add without customization
              context.push(
                AppRoutes.menuItem,
                extra: {
                  'menuItem': item,
                  'restaurant': restaurant,
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
