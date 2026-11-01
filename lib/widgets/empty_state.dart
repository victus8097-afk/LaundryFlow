import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// حالة فارغة أنيقة تظهر عند عدم وجود بيانات.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.gapLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: Icon(icon, size: 40, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.text(
                size: 15.5,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.text(
                size: 12.5,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
