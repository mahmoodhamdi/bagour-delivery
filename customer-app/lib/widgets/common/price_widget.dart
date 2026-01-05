import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Price display widget with currency formatting
class PriceWidget extends StatelessWidget {
  /// Price amount
  final double price;

  /// Currency symbol (defaults to Egyptian Pound)
  final String currency;

  /// Whether to show currency after the price
  final bool currencyAfter;

  /// Text style for the price
  final TextStyle? style;

  /// Text style for the currency
  final TextStyle? currencyStyle;

  /// Original price (for showing discounts)
  final double? originalPrice;

  /// Font size
  final double? fontSize;

  /// Font weight
  final FontWeight? fontWeight;

  /// Text color
  final Color? color;

  /// Number of decimal places
  final int decimalPlaces;

  const PriceWidget({
    super.key,
    required this.price,
    this.currency = 'ج.م',
    this.currencyAfter = true,
    this.style,
    this.currencyStyle,
    this.originalPrice,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.decimalPlaces = 2,
  });

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(decimalPlaces);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        );

    final effectiveCurrencyStyle = currencyStyle ??
        effectiveStyle.copyWith(
          fontSize: (effectiveStyle.fontSize ?? 16) * 0.75,
          fontWeight: FontWeight.w500,
        );

    final priceText = _formatPrice(price);

    Widget priceWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: currencyAfter
          ? [
              Text(priceText, style: effectiveStyle),
              const SizedBox(width: 2),
              Text(currency, style: effectiveCurrencyStyle),
            ]
          : [
              Text(currency, style: effectiveCurrencyStyle),
              const SizedBox(width: 2),
              Text(priceText, style: effectiveStyle),
            ],
    );

    if (originalPrice != null && originalPrice! > price) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          priceWidget,
          const SizedBox(width: 8),
          Text(
            _formatPrice(originalPrice!) + ' $currency',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: (fontSize ?? 16) * 0.75,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return priceWidget;
  }
}

/// Price with "Free" label for zero prices
class PriceOrFreeWidget extends StatelessWidget {
  final double price;
  final String currency;
  final String freeLabel;
  final TextStyle? style;
  final double? fontSize;
  final Color? color;

  const PriceOrFreeWidget({
    super.key,
    required this.price,
    this.currency = 'ج.م',
    this.freeLabel = 'مجاني',
    this.style,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (price <= 0) {
      return Text(
        freeLabel,
        style: style ??
            TextStyle(
              fontFamily: 'Cairo',
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
      );
    }

    return PriceWidget(
      price: price,
      currency: currency,
      style: style,
      fontSize: fontSize,
      color: color,
    );
  }
}

/// Price range display (min - max)
class PriceRangeWidget extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final String currency;
  final TextStyle? style;
  final double? fontSize;

  const PriceRangeWidget({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    this.currency = 'ج.م',
    this.style,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize ?? 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        );

    if (minPrice == maxPrice) {
      return PriceWidget(
        price: minPrice,
        currency: currency,
        style: effectiveStyle,
      );
    }

    return Text(
      '${minPrice.toInt()} - ${maxPrice.toInt()} $currency',
      style: effectiveStyle,
    );
  }
}

/// Total price display with label
class TotalPriceWidget extends StatelessWidget {
  final String label;
  final double price;
  final String currency;
  final bool isHighlighted;

  const TotalPriceWidget({
    super.key,
    this.label = 'المجموع',
    required this.price,
    this.currency = 'ج.م',
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        PriceWidget(
          price: price,
          currency: currency,
          fontSize: isHighlighted ? 18 : 14,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
        ),
      ],
    );
  }
}
