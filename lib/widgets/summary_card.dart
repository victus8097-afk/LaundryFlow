import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// بطاقة إحصائية في لوحة التحكم (إجمالي الطلبات، قيد التنفيذ، ...).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.tint,
    this.caption,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? tint;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: tint ?? AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      const Icon(
                        Icons.north_east_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: AppTheme.text(
                      size: 22,
                      weight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (caption != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text(
                      size: 10,
                      color: AppColors.textMuted,
                      height: 1.3,
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
