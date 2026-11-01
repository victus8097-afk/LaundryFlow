import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// بطاقة بيضاء بحواف دائرية وظل خفيف تُستخدم لتجميع أقسام الواجهات.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.color = AppColors.surface,
    this.showShadow = true,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null) ...<Widget>[
              Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTheme.text(
                        size: 14.5,
                        weight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// عنوان قسم داخل الصفحات (بدون بطاقة).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.action,
  });

  final String title;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: AppTheme.text(
              size: 15.5,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
