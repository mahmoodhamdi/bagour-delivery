import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Button style variants
enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

/// Button size variants
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom button widget with multiple style variants
class CustomButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Button press callback
  final VoidCallback? onPressed;

  /// Button style variant
  final ButtonVariant variant;

  /// Button size
  final ButtonSize size;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button takes full width
  final bool isFullWidth;

  /// Leading icon
  final IconData? icon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Custom background color (overrides variant)
  final Color? backgroundColor;

  /// Custom text color (overrides variant)
  final Color? textColor;

  /// Custom border radius
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final buttonChild = _buildButtonChild(context);

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getLoadingIndicatorColor(),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(SizedBox(width: size == ButtonSize.small ? 4 : 8));
    }

    children.add(Text(label));

    if (trailingIcon != null) {
      children.add(SizedBox(width: size == ButtonSize.small ? 4 : 8));
      children.add(Icon(trailingIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final radius = borderRadius ?? 12.0;

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          minimumSize: _getMinimumSize(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: _getTextStyle(),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          foregroundColor: textColor ?? AppColors.white,
          minimumSize: _getMinimumSize(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: _getTextStyle(),
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(color: backgroundColor ?? AppColors.primary),
          minimumSize: _getMinimumSize(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: _getTextStyle(),
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          minimumSize: _getMinimumSize(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: _getTextStyle(),
        );
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case ButtonSize.small:
        return const Size(0, 36);
      case ButtonSize.medium:
        return const Size(0, 48);
      case ButtonSize.large:
        return const Size(0, 56);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.medium:
        return const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.large:
        return const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingIndicatorColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return textColor ?? AppColors.white;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return textColor ?? AppColors.primary;
    }
  }
}

/// Driver status toggle button
class DriverStatusButton extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  final bool isLoading;

  const DriverStatusButton({
    super.key,
    required this.isOnline,
    required this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: isOnline ? 'متصل' : 'غير متصل',
      icon: isOnline ? Icons.toggle_on : Icons.toggle_off,
      backgroundColor: isOnline ? AppColors.online : AppColors.offline,
      onPressed: isLoading ? null : onToggle,
      isLoading: isLoading,
    );
  }
}
