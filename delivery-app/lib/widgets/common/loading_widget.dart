import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Loading spinner widget with optional text message
/// Supports both full-screen and inline display modes
class LoadingWidget extends StatelessWidget {
  /// Optional loading message to display below spinner
  final String? message;

  /// Whether to center the widget in available space
  final bool isFullScreen;

  /// Size of the loading indicator
  final double size;

  /// Color of the loading indicator (defaults to primary color)
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = true,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: color ?? AppColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Center(child: content);
    }

    return content;
  }
}

/// Loading overlay that covers content while loading
class LoadingOverlay extends StatelessWidget {
  /// Whether loading is in progress
  final bool isLoading;

  /// Child widget to display under overlay
  final Widget child;

  /// Optional loading message
  final String? message;

  /// Overlay opacity (0.0 - 1.0)
  final double overlayOpacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: overlayOpacity),
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}
