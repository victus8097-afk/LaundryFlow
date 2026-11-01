import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

/// حقل إدخال موحّد الشكل يعتمد على [TextFormField] ليعمل مع الـForm والـValidation.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      autovalidateMode: autovalidateMode,
      style: AppTheme.text(size: 14, weight: FontWeight.w400),
      cursorColor: AppColors.primary,
      decoration: AppTheme.fieldDecoration(
        label: label,
        hint: hint,
        helper: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
