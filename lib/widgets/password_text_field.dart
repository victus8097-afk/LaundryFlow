import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'app_text_field.dart';

/// حقل كلمة مرور موحّد: يخفي النص افتراضيًا مع زر لإظهاره/إخفائه.
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    this.label = 'كلمة المرور',
    this.hint,
    this.helperText,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscure,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        onPressed: _toggleVisibility,
        tooltip: _obscure ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
        icon: Icon(
          _obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
