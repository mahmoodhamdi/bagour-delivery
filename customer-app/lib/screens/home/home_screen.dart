import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/restaurant_provider.dart';
import '../favorites/favorites_screen.dart';
import 'widgets/restaurant_card.dart';
import 'widgets/category_chip.dart';
import 'widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    // Fetch nearby restaurants with default location
    ref.read(nearbyRestaurantsProvider.notifier).fetchNearby(
          lat: 30.4167,
          lng: 30.7133,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeTabContent(),
          OrdersPlaceholder(),
          FavoritesScreen(),
          ProfilePlaceholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class HomeTabContent extends ConsumerWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredState = ref.watch(featuredRestaurantsProvider);
    final nearbyState = ref.watch(nearbyRestaurantsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(featuredRestaurantsProvider.notifier).refresh();
          await ref.read(nearbyRestaurantsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBarWidget(
                  onTap: () => context.push(AppRoutes.search),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildCategories(context),
            ),

            // Featured Restaurants Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: 'المطاعم المميزة',
                onSeeAll: () => context.push(AppRoutes.search),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildFeaturedRestaurants(context, featuredState),
            ),

            // Nearby Restaurants Section
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: 'المطاعم القريبة منك',
                onSeeAll: () => context.push(AppRoutes.search),
              ),
            ),
            _buildNearbyRestaurants(context, nearbyState),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توصيل إلى',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'الباجور، المنوفية',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'icon': Icons.restaurant, 'name': 'الكل'},
      {'icon': Icons.local_pizza, 'name': 'بيتزا'},
      {'icon': Icons.lunch_dining, 'name': 'برجر'},
      {'icon': Icons.kebab_dining, 'name': 'مشويات'},
      {'icon': Icons.ramen_dining, 'name': 'مأكولات شرقية'},
      {'icon': Icons.bakery_dining, 'name': 'معجنات'},
      {'icon': Icons.icecream, 'name': 'حلويات'},
      {'icon': Icons.local_cafe, 'name': 'مشروبات'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            icon: category['icon'] as IconData,
            name: category['name'] as String,
            isSelected: index == 0,
            onTap: () {
              // TODO: Filter by category
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('عرض الكل'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRestaurants(
    BuildContext context,
    FeaturedRestaurantsState state,
  ) {
    if (state.isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error!),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('لا توجد مطاعم مميزة حالياً'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = state.restaurants[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 280,
              child: RestaurantCard(
                restaurant: restaurant,
                onTap: () => context.push('/restaurant/${restaurant.slug}'),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverList _buildNearbyRestaurants(
    BuildContext context,
    NearbyRestaurantsState state,
  ) {
    if (state.isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
        ]),
      );
    }

    if (state.error != null) {
      return SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error!),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    }

    if (state.restaurants.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(
            height: 200,
            child: Center(
              child: Text('لا توجد مطاعم قريبة منك'),
            ),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final restaurant = state.restaurants[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: RestaurantCard(
              restaurant: restaurant,
              isHorizontal: true,
              onTap: () => context.push('/restaurant/${restaurant.slug}'),
            ),
          );
        },
        childCount: state.restaurants.length,
      ),
    );
  }
}

// Placeholder widgets for other tabs
class OrdersPlaceholder extends StatelessWidget {
  const OrdersPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('الطلبات'),
    );
  }
}


class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('حسابي'),
    );
  }
}
