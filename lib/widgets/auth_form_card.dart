import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// بطاقة بيضاء تحمل نموذج المصادقة (دخول / إنشاء حساب) فوق خلفية التدرّج.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 21, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTheme.text(
                        size: 17,
                        weight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.text(
                        size: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// رسالة خطأ واضحة أعلى النموذج (كلمة مرور خاطئة، حساب غير موجود…).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cancelledTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33D0504C)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.cancelled,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTheme.text(
                size: 11.5,
                weight: FontWeight.w600,
                color: AppColors.cancelled,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// الزر الرئيسي في نماذج المصادقة مع مؤشر تحميل أثناء تنفيذ العملية.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon = Icons.arrow_back_rounded,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          disabledBackgroundColor: AppColors.primaryLight,
          disabledForegroundColor: Colors.white,
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label),
                  const SizedBox(width: 8),
                  Icon(icon, size: 19),
                ],
              ),
      ),
    );
  }
}
