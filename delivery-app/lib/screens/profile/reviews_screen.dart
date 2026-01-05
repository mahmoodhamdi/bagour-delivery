import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/earnings_provider.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../providers/order_provider.dart' show apiServiceProvider;
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/drivers/reviews');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final reviewsData = response.data['data']?['reviews'] as List<dynamic>? ?? [];
        setState(() {
          _reviews = reviewsData.map((r) => Review.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data['message'] ?? 'حدث خطأ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في الاتصال';
        _isLoading = false;
      });
    }
  }

  List<Review> get _filteredReviews {
    switch (_selectedFilter) {
      case '5':
        return _reviews.where((r) => r.rating == 5).toList();
      case '4':
        return _reviews.where((r) => r.rating == 4).toList();
      case '3':
        return _reviews.where((r) => r.rating >= 1 && r.rating <= 3).toList();
      default:
        return _reviews;
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(0, (sum, r) => sum + r.rating) / _reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in _reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييمات العملاء'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'جاري تحميل التقييمات...');
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onRetry: _loadReviews,
      );
    }

    if (_reviews.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border,
        title: 'لا توجد تقييمات',
        message: 'ستظهر تقييمات العملاء هنا بعد إتمام توصيلاتك',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Rating Summary Card
            _buildRatingSummary(),

            // Filter Chips
            _buildFilterChips(),

            // Reviews List
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.driverGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    if (index < _averageRating.floor()) {
                      return const Icon(Icons.star, color: AppColors.warning, size: 20);
                    } else if (index < _averageRating) {
                      return const Icon(Icons.star_half, color: AppColors.warning, size: 20);
                    } else {
                      return const Icon(Icons.star_border, color: Colors.white54, size: 20);
                    }
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_reviews.length} تقييم',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 100,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [5, 4, 3, 2, 1].map((rating) {
                  final count = _ratingDistribution[rating] ?? 0;
                  final percentage = _reviews.isNotEmpty
                      ? (count / _reviews.length * 100)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '$rating',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: AppColors.warning, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage / 100,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'الكل',
            count: _reviews.length,
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          _FilterChip(
            label: 'ممتاز',
            count: _ratingDistribution[5] ?? 0,
            isSelected: _selectedFilter == '5',
            onTap: () => setState(() => _selectedFilter = '5'),
            icon: Icons.star,
            color: AppColors.success,
          ),
          _FilterChip(
            label: 'جيد',
            count: _ratingDistribution[4] ?? 0,
            isSelected: _selectedFilter == '4',
            onTap: () => setState(() => _selectedFilter = '4'),
            icon: Icons.star,
            color: AppColors.primary,
          ),
          _FilterChip(
            label: 'يحتاج تحسين',
            count: (_ratingDistribution[1] ?? 0) +
                (_ratingDistribution[2] ?? 0) +
                (_ratingDistribution[3] ?? 0),
            isSelected: _selectedFilter == '3',
            onTap: () => setState(() => _selectedFilter = '3'),
            icon: Icons.star,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviews = _filteredReviews;

    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.star_border, size: 48, color: AppColors.grey300),
              const SizedBox(height: 12),
              Text(
                'لا توجد تقييمات في هذا التصنيف',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return _ReviewCard(review: reviews[index]);
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? color : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    review.customerName.isNotEmpty
                        ? review.customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                _RatingBadge(rating: review.rating),
              ],
            ),

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Order Info
            if (review.orderNumber != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'طلب #${review.orderNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _RatingBadge extends StatelessWidget {
  final int rating;

  const _RatingBadge({required this.rating});

  Color get _color {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String id;
  final String customerName;
  final int rating;
  final String? comment;
  final String? orderNumber;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.customerName,
    required this.rating,
    this.comment,
    this.orderNumber,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      customerName: json['customerName'] ?? json['customer']?['name'] ?? 'عميل',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      orderNumber: json['orderNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
