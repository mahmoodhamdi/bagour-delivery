import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Order status badge widget with colors
class StatusBadge extends StatelessWidget {
  /// Status text to display
  final String status;

  /// Badge background color
  final Color? backgroundColor;

  /// Badge text color
  final Color? textColor;

  /// Badge padding
  final EdgeInsets? padding;

  /// Badge border radius
  final double borderRadius;

  /// Font size
  final double fontSize;

  /// Whether to use outlined style
  final bool isOutlined;

  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius = 20,
    this.fontSize = 12,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? _getStatusColor(status);
    final foregroundColor = textColor ?? (isOutlined ? color : Colors.white);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color,
        border: isOutlined ? Border.all(color: color, width: 1.5) : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'picked_up':
      case 'pickedup':
        return AppColors.statusPickedUp;
      case 'on_the_way':
      case 'ontheway':
        return AppColors.statusOnTheWay;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'open':
        return AppColors.restaurantOpen;
      case 'closed':
        return AppColors.restaurantClosed;
      case 'busy':
        return AppColors.restaurantBusy;
      case 'available':
        return AppColors.menuItemAvailable;
      case 'unavailable':
        return AppColors.menuItemUnavailable;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'جاري التحضير';
      case 'ready':
        return 'جاهز للاستلام';
      case 'picked_up':
      case 'pickedup':
        return 'تم الاستلام';
      case 'on_the_way':
      case 'ontheway':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      case 'open':
        return 'مفتوح';
      case 'closed':
        return 'مغلق';
      case 'busy':
        return 'مشغول';
      case 'available':
        return 'متاح';
      case 'unavailable':
        return 'غير متاح';
      default:
        return status;
    }
  }
}

/// Order status badge for restaurant
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'picked_up':
      case 'pickedup':
        return AppColors.statusPickedUp;
      case 'on_the_way':
      case 'ontheway':
        return AppColors.statusOnTheWay;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.inventory_2_outlined;
      case 'picked_up':
      case 'pickedup':
        return Icons.local_shipping;
      case 'on_the_way':
      case 'ontheway':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'جاري التحضير';
      case 'ready':
        return 'جاهز للاستلام';
      case 'picked_up':
      case 'pickedup':
        return 'تم الاستلام';
      case 'on_the_way':
      case 'ontheway':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

/// Restaurant open/closed status badge
class RestaurantStatusBadge extends StatelessWidget {
  final bool isOpen;
  final bool isBusy;

  const RestaurantStatusBadge({
    super.key,
    required this.isOpen,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBusy
        ? AppColors.restaurantBusy
        : (isOpen ? AppColors.restaurantOpen : AppColors.restaurantClosed);
    final text = isBusy ? 'مشغول' : (isOpen ? 'مفتوح' : 'مغلق');
    final icon = isBusy
        ? Icons.schedule
        : (isOpen ? Icons.storefront : Icons.storefront_outlined);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu item availability badge
class MenuItemAvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const MenuItemAvailabilityBadge({
    super.key,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.menuItemAvailable.withValues(alpha: 0.15)
            : AppColors.menuItemUnavailable.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'متاح' : 'غير متاح',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isAvailable ? AppColors.menuItemAvailable : AppColors.menuItemUnavailable,
        ),
      ),
    );
  }
}

/// Simple dot status indicator
class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
