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
      case 'online':
        return AppColors.online;
      case 'offline':
        return AppColors.offline;
      case 'busy':
        return AppColors.busy;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
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
      case 'online':
        return 'متصل';
      case 'offline':
        return 'غير متصل';
      case 'busy':
        return 'مشغول';
      default:
        return status;
    }
  }
}

/// Delivery order status badge
class DeliveryStatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const DeliveryStatusBadge({
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

/// Driver status indicator
class DriverStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const DriverStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.online : AppColors.offline,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.online : AppColors.offline).withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
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
