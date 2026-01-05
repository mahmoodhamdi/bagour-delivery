import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Error display widget with retry button
/// Shows error icon, message, and optional retry action
class AppErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional title (defaults to Arabic "Error occurred")
  final String? title;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Label for retry button (defaults to Arabic "Retry")
  final String? retryLabel;

  /// Custom icon to display
  final IconData icon;

  /// Icon color
  final Color? iconColor;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline,
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
                color: (iconColor ?? AppColors.error).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget with appropriate messaging
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'خطأ في الاتصال',
      message: 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}
