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
            '${_formatPrice(originalPrice!)} $currency',
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

/// Earnings display widget for drivers
class EarningsWidget extends StatelessWidget {
  final double amount;
  final String label;
  final String currency;
  final bool isHighlighted;

  const EarningsWidget({
    super.key,
    required this.amount,
    this.label = 'الأرباح',
    this.currency = 'ج.م',
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        PriceWidget(
          price: amount,
          currency: currency,
          fontSize: isHighlighted ? 24 : 18,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? AppColors.success : AppColors.textPrimary,
        ),
      ],
    );
  }
}

/// Delivery fee display
class DeliveryFeeWidget extends StatelessWidget {
  final double fee;
  final String currency;

  const DeliveryFeeWidget({
    super.key,
    required this.fee,
    this.currency = 'ج.م',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.delivery_dining,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        PriceWidget(
          price: fee,
          currency: currency,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

/// Order total for drivers
class OrderTotalWidget extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final String currency;

  const OrderTotalWidget({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.currency = 'ج.م',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow('قيمة الطلب', subtotal),
        const SizedBox(height: 8),
        _buildRow('رسوم التوصيل', deliveryFee, isHighlighted: true),
        const Divider(height: 16),
        _buildRow('المجموع', subtotal + deliveryFee, isBold: true),
      ],
    );
  }

  Widget _buildRow(String label, double value, {bool isHighlighted = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? AppColors.success : AppColors.textPrimary,
          ),
        ),
        PriceWidget(
          price: value,
          currency: currency,
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: isHighlighted ? AppColors.success : AppColors.textPrimary,
        ),
      ],
    );
  }
}
