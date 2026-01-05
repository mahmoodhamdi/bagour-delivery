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
                color: AppColors.background,
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

/// Preset empty states for common use cases
class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback? onBrowseRestaurants;

  const EmptyOrdersWidget({super.key, this.onBrowseRestaurants});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد طلبات',
      description: 'لم تقم بأي طلبات بعد',
      actionLabel: onBrowseRestaurants != null ? 'تصفح المطاعم' : null,
      onAction: onBrowseRestaurants,
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onBrowseRestaurants;

  const EmptyCartWidget({super.key, this.onBrowseRestaurants});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'السلة فارغة',
      description: 'أضف بعض الأطباق اللذيذة إلى سلتك',
      actionLabel: onBrowseRestaurants != null ? 'تصفح المطاعم' : null,
      onAction: onBrowseRestaurants,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      description: 'جرب البحث بكلمات مختلفة',
    );
  }
}
