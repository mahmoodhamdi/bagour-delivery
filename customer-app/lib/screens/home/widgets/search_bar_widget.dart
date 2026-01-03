import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText ?? 'ابحث عن مطعم أو طبق...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: AppColors.divider,
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
