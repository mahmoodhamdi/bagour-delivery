import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/review_service.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  int? _selectedRating;
  bool _isLoading = false;
  List<Review> _reviews = [];
  ReviewStats? _stats;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
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
      if (!_isLoading && _hasMore) {
        _loadMoreReviews();
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(reviewServiceProvider);
      final futures = await Future.wait([
        service.getReviewStats(),
        service.getReviews(page: 1, rating: _selectedRating),
      ]);

      if (mounted) {
        setState(() {
          _stats = futures[0] as ReviewStats;
          final response = futures[1] as ReviewsResponse;
          _reviews = response.reviews;
          _totalPages = response.pages;
          _currentPage = 1;
          _hasMore = _currentPage < _totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('فشل في تحميل التقييمات');
      }
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(reviewServiceProvider);
      final response = await service.getReviews(
        page: _currentPage + 1,
        rating: _selectedRating,
      );

      if (mounted) {
        setState(() {
          _reviews.addAll(response.reviews);
          _currentPage++;
          _hasMore = _currentPage < _totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    _currentPage = 1;
    await _loadData();
  }

  void _filterByRating(int? rating) {
    setState(() {
      _selectedRating = rating;
      _currentPage = 1;
      _reviews = [];
    });
    _loadData();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقييمات'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Statistics Section
            SliverToBoxAdapter(
              child: _buildStatisticsSection(),
            ),

            // Filter Section
            SliverToBoxAdapter(
              child: _buildFilterSection(),
            ),

            // Reviews List
            if (_reviews.isEmpty && !_isLoading)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _reviews.length) {
                        return _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      return _ReviewCard(
                        review: _reviews[index],
                        onReply: () => _showReplyDialog(_reviews[index]),
                      );
                    },
                    childCount: _reviews.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    if (_stats == null && _isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _stats ?? ReviewStats();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Average Rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      stats.averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        return Icon(
                          rating <= stats.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.rating,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalReviews} تقييم',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Rating Breakdown
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final percentage = stats.getPercentageForRating(rating);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 14, color: AppColors.rating),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: AppColors.grey200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getRatingColor(rating),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${stats.getCountForRating(rating)}',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.end,
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
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.check_circle_outline,
                label: 'تم الرد',
                value: '${stats.repliedCount}',
                color: AppColors.success,
              ),
              _StatItem(
                icon: Icons.pending_outlined,
                label: 'بانتظار الرد',
                value: '${stats.unrepliedCount}',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'الكل',
            isSelected: _selectedRating == null,
            onTap: () => _filterByRating(null),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: '$rating نجوم',
                icon: Icons.star,
                isSelected: _selectedRating == rating,
                onTap: () => _filterByRating(rating),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedRating != null
                ? 'لا توجد تقييمات بـ $_selectedRating نجوم'
                : 'لا توجد تقييمات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر تقييمات العملاء هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return AppColors.success;
      case 4:
        return Colors.lightGreen;
      case 3:
        return AppColors.warning;
      case 2:
        return Colors.orange;
      case 1:
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }

  void _showReplyDialog(Review review) {
    final controller = TextEditingController(text: review.reply?.content);
    final isEdit = review.hasReply;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? 'تعديل الرد' : 'الرد على التقييم',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (isEdit)
                    TextButton(
                      onPressed: () => _deleteReply(review, context),
                      child: const Text(
                        'حذف',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Original Review
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.customer.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        ...List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppColors.rating,
                        )),
                      ],
                    ),
                    if (review.comment != null && review.comment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Reply Input
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'اكتب ردك هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitReply(
                        review,
                        controller.text,
                        isEdit,
                        context,
                      ),
                      child: Text(isEdit ? 'تحديث' : 'إرسال'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReply(
    Review review,
    String content,
    bool isEdit,
    BuildContext dialogContext,
  ) async {
    if (content.trim().isEmpty) {
      _showError('يرجى كتابة الرد');
      return;
    }

    try {
      final service = ref.read(reviewServiceProvider);
      Review updatedReview;

      if (isEdit) {
        updatedReview = await service.updateReply(review.id, content);
      } else {
        updatedReview = await service.replyToReview(review.id, content);
      }

      // Update local list
      final index = _reviews.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        setState(() {
          _reviews[index] = updatedReview;
        });
      }

      if (mounted && dialogContext.mounted) {
        Navigator.pop(dialogContext);
        _showSuccess(isEdit ? 'تم تحديث الرد' : 'تم إرسال الرد');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _deleteReply(Review review, BuildContext dialogContext) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرد'),
        content: const Text('هل أنت متأكد من حذف هذا الرد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
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

    if (confirm != true) return;

    try {
      final service = ref.read(reviewServiceProvider);
      await service.deleteReply(review.id);

      // Refresh the review in local list
      await _refreshData();

      if (mounted && dialogContext.mounted) {
        Navigator.pop(dialogContext);
        _showSuccess('تم حذف الرد');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.white : AppColors.rating,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onReply;

  const _ReviewCard({
    required this.review,
    required this.onReply,
  });

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
                // Customer Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: review.customer.avatar != null
                      ? NetworkImage(review.customer.avatar!)
                      : null,
                  child: review.customer.avatar == null
                      ? Text(
                          review.customer.name.isNotEmpty
                              ? review.customer.name[0].toUpperCase()
                              : '؟',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customer.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(review.rating).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: _getRatingColor(review.rating),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${review.rating}',
                        style: TextStyle(
                          color: _getRatingColor(review.rating),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Order Number
            if (review.orderNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'طلب رقم: ${review.orderNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Reply Section
            if (review.hasReply) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: AppRadius.radiusSm,
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
                          Icons.reply,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ردك',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(review.reply!.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.reply!.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReply,
                  icon: Icon(
                    review.hasReply ? Icons.edit : Icons.reply,
                    size: 18,
                  ),
                  label: Text(review.hasReply ? 'تعديل الرد' : 'رد'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return AppColors.success;
      case 4:
        return Colors.lightGreen;
      case 3:
        return AppColors.warning;
      case 2:
        return Colors.orange;
      case 1:
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    }
  }
}
