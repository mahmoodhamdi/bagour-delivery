import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/review_service.dart';

/// State for restaurant reviews
class RestaurantReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const RestaurantReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingDistribution = const {},
  });

  RestaurantReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    double? averageRating,
    int? totalReviews,
    Map<int, int>? ratingDistribution,
  }) {
    return RestaurantReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }
}

/// Restaurant reviews notifier
class RestaurantReviewsNotifier extends StateNotifier<RestaurantReviewsState> {
  final ReviewService _reviewService;
  final String restaurantId;

  RestaurantReviewsNotifier(this._reviewService, this.restaurantId)
      : super(const RestaurantReviewsState()) {
    fetchReviews();
  }

  Future<void> fetchReviews({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(
      isLoading: true,
      error: null,
      reviews: refresh ? [] : state.reviews,
    );

    try {
      final reviews = await _reviewService.getRestaurantReviews(
        restaurantId: restaurantId,
        page: page,
        limit: 20,
      );

      // Calculate rating distribution
      final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      double totalRating = 0;
      for (final review in reviews) {
        final rating = review.restaurantRating.round();
        distribution[rating] = (distribution[rating] ?? 0) + 1;
        totalRating += review.restaurantRating;
      }

      final avgRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

      state = state.copyWith(
        reviews: refresh ? reviews : [...state.reviews, ...reviews],
        isLoading: false,
        currentPage: page + 1,
        hasMore: reviews.length >= 20,
        averageRating: avgRating,
        totalReviews: state.totalReviews + reviews.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchReviews();
  }

  Future<void> refresh() async {
    await fetchReviews(refresh: true);
  }
}

/// Provider for restaurant reviews
final restaurantReviewsProvider = StateNotifierProvider.family<
    RestaurantReviewsNotifier, RestaurantReviewsState, String>((ref, restaurantId) {
  final reviewService = ref.watch(reviewServiceProvider);
  return RestaurantReviewsNotifier(reviewService, restaurantId);
});

/// All restaurant reviews screen with pagination
class RestaurantReviewsScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final double? initialRating;
  final int? initialReviewCount;

  const RestaurantReviewsScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.initialRating,
    this.initialReviewCount,
  });

  @override
  ConsumerState<RestaurantReviewsScreen> createState() =>
      _RestaurantReviewsScreenState();
}

class _RestaurantReviewsScreenState
    extends ConsumerState<RestaurantReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(restaurantReviewsProvider(widget.restaurantId).notifier).loadMore();
    }
  }

  List<Review> _getFilteredReviews(List<Review> reviews) {
    if (_selectedFilter == 'all') return reviews;
    if (_selectedFilter == 'with_comment') {
      return reviews.where((r) => r.comment?.isNotEmpty == true).toList();
    }
    if (_selectedFilter == 'with_images') {
      return reviews.where((r) => r.images.isNotEmpty).toList();
    }
    final rating = int.tryParse(_selectedFilter);
    if (rating != null) {
      return reviews.where((r) => r.restaurantRating.round() == rating).toList();
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(restaurantReviewsProvider(widget.restaurantId));
    final filteredReviews = _getFilteredReviews(reviewsState.reviews);

    return Scaffold(
      appBar: AppBar(
        title: Text('تقييمات ${widget.restaurantName}'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(restaurantReviewsProvider(widget.restaurantId).notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Rating summary
            SliverToBoxAdapter(
              child: _buildRatingSummary(context, reviewsState),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),

            // Reviews list
            _buildReviewsList(reviewsState, filteredReviews),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(
    BuildContext context,
    RestaurantReviewsState state,
  ) {
    final rating = widget.initialRating ?? state.averageRating;
    final count = widget.initialReviewCount ?? state.totalReviews;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average rating
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 4),
              _buildStarRating(rating),
              const SizedBox(height: 4),
              Text(
                '$count تقييم',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          const VerticalDivider(thickness: 1),
          const SizedBox(width: 24),
          // Rating distribution
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = state.ratingDistribution[star] ?? 0;
                final total = state.reviews.length;
                final percentage = total > 0 ? count / total : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Icon(Icons.star, size: 12, color: AppColors.rating),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.rating,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: AppColors.rating, size: 20);
      }),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'الكل'),
          _buildFilterChip('5', '5 نجوم'),
          _buildFilterChip('4', '4 نجوم'),
          _buildFilterChip('3', '3 نجوم'),
          _buildFilterChip('2', '2 نجوم'),
          _buildFilterChip('1', 'نجمة'),
          _buildFilterChip('with_comment', 'مع تعليق'),
          _buildFilterChip('with_images', 'مع صور'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildReviewsList(
    RestaurantReviewsState state,
    List<Review> filteredReviews,
  ) {
    if (state.isLoading && state.reviews.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.reviews.isEmpty) {
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
                onPressed: () => ref
                    .read(restaurantReviewsProvider(widget.restaurantId).notifier)
                    .refresh(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredReviews.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 80,
                color: AppColors.textHint.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد تقييمات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilter != 'all'
                    ? 'جرب تغيير الفلتر'
                    : 'كن أول من يقيم هذا المطعم',
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
            if (index >= filteredReviews.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final review = filteredReviews[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ReviewCard(review: review),
            );
          },
          childCount: filteredReviews.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: review.customer?.avatar != null
                      ? CachedNetworkImageProvider(review.customer!.avatar!)
                      : null,
                  child: review.customer?.avatar == null
                      ? Text(
                          review.customer?.name.isNotEmpty == true
                              ? review.customer!.name[0].toUpperCase()
                              : 'م',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customer?.name ?? 'عميل',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(review.restaurantRating)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: _getRatingColor(review.restaurantRating),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.restaurantRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: _getRatingColor(review.restaurantRating),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Rating details
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRatingDetail(context, 'المطعم', review.restaurantRating),
                const SizedBox(width: 16),
                _buildRatingDetail(context, 'الطعام', review.foodRating),
                if (review.driverRating != null) ...[
                  const SizedBox(width: 16),
                  _buildRatingDetail(context, 'التوصيل', review.driverRating!),
                ],
              ],
            ),

            // Comment
            if (review.comment?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Images
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: review.images[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.background,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.background,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Restaurant reply
            if (review.restaurantReply?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    right: BorderSide(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رد المطعم',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        if (review.repliedAt != null)
                          Text(
                            _formatDate(review.repliedAt!),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textHint,
                                      fontSize: 10,
                                    ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.restaurantReply!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDetail(BuildContext context, String label, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            size: 12,
            color: AppColors.rating,
          );
        }),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'منذ ${diff.inMinutes} دقيقة';
      }
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else if (diff.inDays < 30) {
      return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    } else if (diff.inDays < 365) {
      return 'منذ ${(diff.inDays / 30).floor()} أشهر';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
