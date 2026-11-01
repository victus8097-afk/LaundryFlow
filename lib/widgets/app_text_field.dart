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
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
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
      enabled: enabled,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      autovalidateMode: autovalidateMode,
      style: AppTheme.text(size: 14, weight: FontWeight.w400),
      cursorColor: AppColors.primary,
      decoration: AppTheme.fieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
