import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

/// Custom styled text field with validation support
class CustomTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text above the field
  final String? label;

  /// Hint text inside the field
  final String? hint;

  /// Helper text below the field
  final String? helperText;

  /// Error text to display
  final String? errorText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Suffix icon callback
  final VoidCallback? onSuffixIconTap;

  /// Whether the field is obscured (for passwords)
  final bool obscureText;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Text input type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum lines
  final int maxLines;

  /// Minimum lines
  final int? minLines;

  /// Maximum length
  final int? maxLength;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// On tap callback
  final VoidCallback? onTap;

  /// Validator function
  final String? Function(String?)? validator;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto-validate mode
  final AutovalidateMode? autovalidateMode;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Text alignment
  final TextAlign textAlign;

  /// Whether to auto-focus
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          autovalidateMode: autovalidateMode,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          autofocus: autofocus,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppColors.textSecondary),
                    onPressed: onSuffixIconTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Password text field with visibility toggle
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.autovalidateMode,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label ?? 'كلمة المرور',
      hint: widget.hint ?? 'أدخل كلمة المرور',
      errorText: widget.errorText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixIconTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}

/// Phone number text field
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PhoneTextField({
    super.key,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'رقم الهاتف',
      hint: '01xxxxxxxxx',
      errorText: errorText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
    );
  }
}

/// Price input text field
class PriceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const PriceTextField({
    super.key,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label ?? 'السعر',
      hint: '0.00',
      errorText: errorText,
      prefixIcon: Icons.attach_money,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }
}

/// Search text field
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hint: hint ?? 'بحث...',
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true ? Icons.clear : null,
      onSuffixIconTap: () {
        controller?.clear();
        onClear?.call();
      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}
