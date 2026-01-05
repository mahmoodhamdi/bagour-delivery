import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Drag handle widget for bottom sheets
class BottomSheetHandle extends StatelessWidget {
  /// Width of the handle
  final double width;

  /// Height of the handle
  final double height;

  /// Handle color
  final Color? color;

  /// Vertical margin
  final double verticalMargin;

  const BottomSheetHandle({
    super.key,
    this.width = 40,
    this.height = 4,
    this.color,
    this.verticalMargin = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      decoration: BoxDecoration(
        color: color ?? AppColors.grey300,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Bottom sheet header with handle and optional title/actions
class BottomSheetHeader extends StatelessWidget {
  /// Title text
  final String? title;

  /// Leading widget (usually close button)
  final Widget? leading;

  /// Trailing widget (usually action button)
  final Widget? trailing;

  /// Whether to show the drag handle
  final bool showHandle;

  /// Whether to show bottom border
  final bool showBorder;

  const BottomSheetHeader({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.showHandle = true,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHandle) const BottomSheetHandle(),
        if (title != null || leading != null || trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: showBorder
                ? const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.grey200),
                    ),
                  )
                : null,
            child: Row(
              children: [
                if (leading != null) leading!,
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: leading == null ? TextAlign.start : TextAlign.center,
                    ),
                  ),
                if (leading != null && trailing == null)
                  const SizedBox(width: 48),
                if (trailing != null) trailing!,
              ],
            ),
          ),
      ],
    );
  }
}

/// Pre-built bottom sheet container with handle
class BottomSheetContainer extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Title text
  final String? title;

  /// Leading widget
  final Widget? leading;

  /// Trailing widget
  final Widget? trailing;

  /// Whether to show the drag handle
  final bool showHandle;

  /// Padding for the content
  final EdgeInsets contentPadding;

  /// Maximum height as fraction of screen height
  final double? maxHeightFraction;

  const BottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.trailing,
    this.showHandle = true,
    this.contentPadding = const EdgeInsets.all(16),
    this.maxHeightFraction,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomSheetHeader(
          title: title,
          leading: leading,
          trailing: trailing,
          showHandle: showHandle,
          showBorder: title != null,
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: contentPadding,
            child: child,
          ),
        ),
      ],
    );

    if (maxHeightFraction != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFraction!,
        ),
        child: content,
      );
    }

    return content;
  }
}

/// Helper function to show a standard bottom sheet
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showHandle = true,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  double? maxHeightFraction,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: BottomSheetContainer(
          title: title,
          showHandle: showHandle,
          maxHeightFraction: maxHeightFraction,
          child: child,
        ),
      ),
    ),
  );
}
