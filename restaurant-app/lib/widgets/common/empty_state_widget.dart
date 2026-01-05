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

/// Preset empty states for restaurant app
class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyOrdersWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد طلبات',
      description: 'لا توجد طلبات جديدة حاليا',
      actionLabel: onRefresh != null ? 'تحديث' : null,
      onAction: onRefresh,
    );
  }
}

class EmptyMenuWidget extends StatelessWidget {
  final VoidCallback? onAddItem;

  const EmptyMenuWidget({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.restaurant_menu,
      title: 'القائمة فارغة',
      description: 'أضف أصناف جديدة لقائمة الطعام',
      actionLabel: onAddItem != null ? 'إضافة صنف' : null,
      onAction: onAddItem,
    );
  }
}

class EmptyCategoriesWidget extends StatelessWidget {
  final VoidCallback? onAddCategory;

  const EmptyCategoriesWidget({super.key, this.onAddCategory});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.category_outlined,
      title: 'لا توجد فئات',
      description: 'أضف فئات لتنظيم قائمة الطعام',
      actionLabel: onAddCategory != null ? 'إضافة فئة' : null,
      onAction: onAddCategory,
    );
  }
}

class EmptyReviewsWidget extends StatelessWidget {
  const EmptyReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.star_outline,
      title: 'لا توجد تقييمات',
      description: 'ستظهر هنا تقييمات العملاء',
    );
  }
}
