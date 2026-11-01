import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// زر تصفية (Chip) قابل لإعادة الاستخدام في شاشتي الطلبات والسجل.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.color = AppColors.primary,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: selected ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                if (count != null) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0x33FFFFFF)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: AppTheme.text(
                        size: 9.5,
                        weight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
