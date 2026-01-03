import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../home/widgets/restaurant_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  void _fetchFavorites() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(favoritesProvider.notifier).fetchFavorites();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(FavoritesState state) {
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
              onPressed: _fetchFavorites,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = state.restaurants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(restaurant.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await _showRemoveConfirmation(context);
            },
            onDismissed: (direction) {
              ref.read(favoritesProvider.notifier).toggleFavorite(restaurant.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تمت إزالة ${restaurant.name} من المفضلة'),
                  action: SnackBarAction(
                    label: 'تراجع',
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).fetchFavorites();
                    },
                  ),
                ),
              );
            },
            child: RestaurantCard(
              restaurant: restaurant,
              isHorizontal: true,
              onTap: () => context.push('/restaurant/${restaurant.slug}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مفضلات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ بإضافة المطاعم المفضلة لديك للوصول إليها بسهولة لاحقاً',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('استكشف المطاعم'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showRemoveConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إزالة من المفضلة'),
            content: const Text('هل تريد إزالة هذا المطعم من المفضلة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('إزالة'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
