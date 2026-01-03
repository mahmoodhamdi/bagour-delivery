import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildVerticalCard(context);
  }

  Widget _buildVerticalCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _buildImage(),
                ),
                // Status badges
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildStatusBadges(),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildFavoriteButton(),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(context),
                  const SizedBox(height: 4),
                  _buildDeliveryInfo(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              // Image
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: _buildImage(),
                  ),
                  // Favorite button
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _buildFavoriteButton(small: true),
                  ),
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadges(small: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(context),
                      const SizedBox(height: 6),
                      _buildDeliveryInfo(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = restaurant.coverImage ?? restaurant.logo;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.restaurant,
            size: 40,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.restaurant,
            size: 40,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadges({bool small = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!restaurant.isOpen)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: small ? 6 : 8,
              vertical: small ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'مغلق',
              style: TextStyle(
                color: Colors.white,
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else if (restaurant.isPaused)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: small ? 6 : 8,
              vertical: small ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'مشغول',
              style: TextStyle(
                color: Colors.white,
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton({bool small = false}) {
    return Container(
      width: small ? 28 : 32,
      height: small ? 28 : 32,
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
      child: Icon(
        restaurant.isFavorite ? Icons.favorite : Icons.favorite_outline,
        size: small ? 16 : 18,
        color: restaurant.isFavorite ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        // Rating
        const Icon(
          Icons.star,
          size: 16,
          color: AppColors.rating,
        ),
        const SizedBox(width: 2),
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
        const SizedBox(width: 12),
        // Categories
        if (restaurant.categories.isNotEmpty)
          Expanded(
            child: Text(
              restaurant.categories.take(2).join(' • '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    final deliveryTime = restaurant.estimatedDeliveryTime;
    return Row(
      children: [
        // Delivery time
        if (deliveryTime != null) ...[
          const Icon(
            Icons.access_time,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${deliveryTime.min}-${deliveryTime.max} دقيقة',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
        ],
        // Delivery fee
        const Icon(
          Icons.delivery_dining,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          restaurant.deliveryFee == 0
              ? 'توصيل مجاني'
              : '${restaurant.deliveryFee.toStringAsFixed(0)} ج.م',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: restaurant.deliveryFee == 0 ? AppColors.success : null,
              ),
        ),
        // Distance
        if (restaurant.distance != null) ...[
          const SizedBox(width: 12),
          const Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${restaurant.distance!.toStringAsFixed(1)} كم',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
