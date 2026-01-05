import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Empty state widget with icon, title, and description
/// Used when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Optional description text
  final String? description;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Optional custom icon widget
  final Widget? customIcon;

  /// Icon size
  final double iconSize;

  /// Icon color
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.iconSize = 64,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: customIcon ??
                  Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset empty states for delivery driver app
class EmptyDeliveriesWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyDeliveriesWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.delivery_dining_outlined,
      title: 'لا توجد طلبات متاحة',
      description: 'لا توجد طلبات توصيل متاحة حاليا',
      actionLabel: onRefresh != null ? 'تحديث' : null,
      onAction: onRefresh,
    );
  }
}

class EmptyOrderHistoryWidget extends StatelessWidget {
  const EmptyOrderHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.history,
      title: 'لا توجد طلبات سابقة',
      description: 'ستظهر هنا الطلبات التي قمت بتوصيلها',
    );
  }
}

class EmptyEarningsWidget extends StatelessWidget {
  const EmptyEarningsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'لا توجد أرباح',
      description: 'ابدأ بتوصيل الطلبات لتحقيق أرباح',
    );
  }
}
