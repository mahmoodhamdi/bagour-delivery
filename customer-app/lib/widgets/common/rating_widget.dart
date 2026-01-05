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
            onHorizontalDragUpdate: allowHalfRating
                ? (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final pos = box.globalToLocal(details.globalPosition);
                    final starWidth = starSize + spacing;
                    final starIndex = (pos.dx / starWidth).floor();
                    final withinStar = pos.dx - (starIndex * starWidth);

                    double newRating;
                    if (withinStar < starSize / 2) {
                      newRating = starIndex + 0.5;
                    } else {
                      newRating = starIndex + 1.0;
                    }

                    newRating = newRating.clamp(0.5, maxRating.toDouble());
                    if (newRating != rating) {
                      onRatingChanged(newRating);
                    }
                  }
                : null,
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
