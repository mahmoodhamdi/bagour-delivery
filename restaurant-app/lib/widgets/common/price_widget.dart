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

/// Menu item price display
class MenuItemPriceWidget extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currency;
  final bool isAvailable;

  const MenuItemPriceWidget({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'ج.م',
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return PriceWidget(
      price: price,
      originalPrice: originalPrice,
      currency: currency,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isAvailable ? AppColors.primary : AppColors.textDisabled,
    );
  }
}

/// Revenue display for restaurant dashboard
class RevenueWidget extends StatelessWidget {
  final double amount;
  final String label;
  final String currency;
  final String? trend;
  final bool isPositiveTrend;

  const RevenueWidget({
    super.key,
    required this.amount,
    this.label = 'الإيرادات',
    this.currency = 'ج.م',
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        PriceWidget(
          price: amount,
          currency: currency,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.revenue,
        ),
        if (trend != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: isPositiveTrend ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                trend!,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isPositiveTrend ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Order total summary widget for restaurant
class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double? discount;
  final String currency;

  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.discount,
    this.currency = 'ج.م',
  });

  @override
  Widget build(BuildContext context) {
    final total = subtotal + deliveryFee - (discount ?? 0);

    return Column(
      children: [
        _buildRow('المجموع الفرعي', subtotal),
        const SizedBox(height: 8),
        _buildRow('رسوم التوصيل', deliveryFee),
        if (discount != null && discount! > 0) ...[
          const SizedBox(height: 8),
          _buildRow('الخصم', -discount!, isDiscount: true),
        ],
        const Divider(height: 16),
        _buildRow('المجموع', total, isBold: true),
      ],
    );
  }

  Widget _buildRow(String label, double value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        PriceWidget(
          price: value.abs(),
          currency: currency,
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: isDiscount ? AppColors.success : (isBold ? AppColors.primary : AppColors.textPrimary),
        ),
      ],
    );
  }
}
