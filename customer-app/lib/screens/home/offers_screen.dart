import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/restaurant.dart';
import '../../services/api_service.dart';

/// Offer model representing promotional deals
class Offer {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String? imageUrl;
  final double? discountPercentage;
  final double? discountAmount;
  final String? promoCode;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final double? minimumOrder;
  final String? restaurantId;
  final Restaurant? restaurant;
  final bool isActive;

  const Offer({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    this.imageUrl,
    this.discountPercentage,
    this.discountAmount,
    this.promoCode,
    this.validFrom,
    this.validUntil,
    this.minimumOrder,
    this.restaurantId,
    this.restaurant,
    this.isActive = true,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['titleAr'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      promoCode: json['promoCode'],
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'])
          : null,
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'])
          : null,
      minimumOrder: (json['minimumOrder'] as num?)?.toDouble(),
      restaurantId: json['restaurantId'],
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  String get discountText {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '${discountPercentage!.toInt()}% خصم';
    }
    if (discountAmount != null && discountAmount! > 0) {
      return '${discountAmount!.toStringAsFixed(0)} ج.م خصم';
    }
    return 'عرض خاص';
  }
}

/// State for offers
class OffersState {
  final List<Offer> offers;
  final bool isLoading;
  final String? error;

  const OffersState({
    this.offers = const [],
    this.isLoading = false,
    this.error,
  });

  OffersState copyWith({
    List<Offer>? offers,
    bool? isLoading,
    String? error,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Offers notifier
class OffersNotifier extends StateNotifier<OffersState> {
  final ApiService _apiService;

  OffersNotifier(this._apiService) : super(const OffersState()) {
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/offers');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final offersList = (data['data']?['offers'] as List? ?? [])
            .map((e) => Offer.fromJson(e as Map<String, dynamic>))
            .where((offer) => offer.isValid)
            .toList();

        state = state.copyWith(
          offers: offersList,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'فشل في جلب العروض',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ أثناء جلب العروض',
      );
    }
  }

  Future<void> refresh() async {
    await fetchOffers();
  }
}

/// Offers provider
final offersProvider = StateNotifierProvider<OffersNotifier, OffersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OffersNotifier(apiService);
});

/// Current offers and promotions screen
class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersState = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض والخصومات'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(offersProvider.notifier).refresh(),
        child: _buildContent(context, offersState, ref),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OffersState state,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.offers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.offers.isEmpty) {
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
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(offersProvider.notifier).refresh(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Show demo offers if API returns empty
    final offers = state.offers.isNotEmpty ? state.offers : _getDemoOffers();

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عروض حالياً',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'تابعنا للحصول على أحدث العروض',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Featured offer banner
        if (offers.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFeaturedOfferBanner(context, offers.first),
          ),

        // Active offers header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${offers.length} عرض متاح',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Offers list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final offer = offers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _OfferCard(offer: offer),
                );
              },
              childCount: offers.length,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildFeaturedOfferBanner(BuildContext context, Offer offer) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935),
            Color(0xFFFF5722),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) => const Icon(
                    Icons.percent,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    offer.discountText,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  offer.titleAr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  offer.descriptionAr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (offer.promoCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'كود الخصم: ${offer.promoCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Offer> _getDemoOffers() {
    return [
      const Offer(
        id: '1',
        title: 'Free Delivery',
        titleAr: 'توصيل مجاني',
        description: 'Free delivery on orders above 100 EGP',
        descriptionAr: 'توصيل مجاني على الطلبات فوق 100 جنيه',
        discountAmount: 20,
        minimumOrder: 100,
        promoCode: 'FREEDEL',
      ),
      const Offer(
        id: '2',
        title: '20% Off',
        titleAr: 'خصم 20%',
        description: '20% discount on your first order',
        descriptionAr: 'خصم 20% على طلبك الأول',
        discountPercentage: 20,
        promoCode: 'FIRST20',
      ),
      const Offer(
        id: '3',
        title: 'Weekend Special',
        titleAr: 'عرض نهاية الأسبوع',
        description: 'Special offers every weekend',
        descriptionAr: 'عروض خاصة كل نهاية أسبوع',
        discountPercentage: 15,
        promoCode: 'WEEKEND15',
      ),
      const Offer(
        id: '4',
        title: 'Lunch Deal',
        titleAr: 'عرض الغداء',
        description: 'Get 10% off on lunch orders from 12pm to 3pm',
        descriptionAr: 'احصل على خصم 10% على طلبات الغداء من 12 ظهراً حتى 3 مساءً',
        discountPercentage: 10,
        promoCode: 'LUNCH10',
      ),
    ];
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showOfferDetails(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer header with discount badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (offer.discountPercentage != null)
                          Text(
                            '${offer.discountPercentage!.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        else
                          Text(
                            offer.discountAmount?.toStringAsFixed(0) ?? '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        Text(
                          offer.discountPercentage != null ? 'خصم' : 'ج.م',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Offer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.titleAr,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.descriptionAr,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
            // Offer details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Promo code
                  if (offer.promoCode != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer.promoCode!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Minimum order
                  if (offer.minimumOrder != null && offer.minimumOrder! > 0)
                    Text(
                      'الحد الأدنى: ${offer.minimumOrder!.toStringAsFixed(0)} ج.م',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  const Spacer(),
                  // Validity
                  if (offer.validUntil != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(offer.validUntil!),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays <= 0) {
      return 'ينتهي اليوم';
    } else if (diff.inDays == 1) {
      return 'ينتهي غداً';
    } else if (diff.inDays <= 7) {
      return 'ينتهي خلال ${diff.inDays} أيام';
    } else {
      return 'حتى ${date.day}/${date.month}';
    }
  }

  void _showOfferDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 24),

              // Offer title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.titleAr,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.discountText,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                offer.descriptionAr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),

              // Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (offer.promoCode != null)
                      _buildDetailRow(
                        context,
                        Icons.local_offer,
                        'كود الخصم',
                        offer.promoCode!,
                        isCopyable: true,
                      ),
                    if (offer.minimumOrder != null && offer.minimumOrder! > 0)
                      _buildDetailRow(
                        context,
                        Icons.shopping_cart,
                        'الحد الأدنى للطلب',
                        '${offer.minimumOrder!.toStringAsFixed(0)} ج.م',
                      ),
                    if (offer.validUntil != null)
                      _buildDetailRow(
                        context,
                        Icons.calendar_today,
                        'صالح حتى',
                        '${offer.validUntil!.day}/${offer.validUntil!.month}/${offer.validUntil!.year}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Use offer button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/home');
                  },
                  child: const Text('استخدام العرض'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          if (isCopyable)
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم نسخ الكود: $value'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.copy,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}
