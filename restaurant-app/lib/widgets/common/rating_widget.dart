import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Star rating display widget
class RatingWidget extends StatelessWidget {
  /// Current rating value (0.0 - 5.0)
  final double rating;

  /// Maximum rating (default 5)
  final int maxRating;

  /// Size of each star
  final double starSize;

  /// Color for filled stars
  final Color? filledColor;

  /// Color for empty stars
  final Color? emptyColor;

  /// Spacing between stars
  final double spacing;

  /// Whether to show the rating number
  final bool showRatingText;

  /// Number of reviews (optional)
  final int? reviewCount;

  /// Text style for rating number
  final TextStyle? textStyle;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 16,
    this.filledColor,
    this.emptyColor,
    this.spacing = 2,
    this.showRatingText = true,
    this.reviewCount,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          IconData iconData;
          Color color;

          if (rating >= starValue) {
            iconData = Icons.star;
            color = filledColor ?? AppColors.rating;
          } else if (rating >= starValue - 0.5) {
            iconData = Icons.star_half;
            color = filledColor ?? AppColors.rating;
          } else {
            iconData = Icons.star_border;
            color = emptyColor ?? AppColors.textHint;
          }

          return Padding(
            padding: EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
            child: Icon(
              iconData,
              size: starSize,
              color: color,
            ),
          );
        }),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: textStyle ??
                TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: starSize * 0.875,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: starSize * 0.75,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive star rating input widget
class RatingInputWidget extends StatelessWidget {
  /// Current rating value
  final double rating;

  /// Callback when rating changes
  final ValueChanged<double> onRatingChanged;

  /// Maximum rating
  final int maxRating;

  /// Size of each star
  final double starSize;

  /// Color for filled stars
  final Color? filledColor;

  /// Color for empty stars
  final Color? emptyColor;

  /// Spacing between stars
  final double spacing;

  /// Whether half ratings are allowed
  final bool allowHalfRating;

  const RatingInputWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
    this.starSize = 32,
    this.filledColor,
    this.emptyColor,
    this.spacing = 8,
    this.allowHalfRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData iconData;
        Color color;

        if (rating >= starValue) {
          iconData = Icons.star;
          color = filledColor ?? AppColors.rating;
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          iconData = Icons.star_half;
          color = filledColor ?? AppColors.rating;
        } else {
          iconData = Icons.star_border;
          color = emptyColor ?? AppColors.textHint;
        }

        return Padding(
          padding: EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
          child: GestureDetector(
            onTap: () => onRatingChanged(starValue.toDouble()),
            child: Icon(
              iconData,
              size: starSize,
              color: color,
            ),
          ),
        );
      }),
    );
  }
}

/// Compact rating display (star icon + number)
class CompactRatingWidget extends StatelessWidget {
  final double rating;
  final double iconSize;
  final TextStyle? textStyle;

  const CompactRatingWidget({
    super.key,
    required this.rating,
    this.iconSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: AppColors.rating,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: textStyle ??
              TextStyle(
                fontFamily: 'Cairo',
                fontSize: iconSize * 0.875,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

/// Restaurant rating summary widget
class RestaurantRatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const RestaurantRatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.rating.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 18,
                color: AppColors.rating,
              ),
              const SizedBox(width: 4),
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$totalReviews تقييم',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
