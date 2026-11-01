import 'package:flutter/material.dart';

import '../models/order_enums.dart';
import '../utils/app_theme.dart';

/// شارة ملوّنة توضح حالة الطلب.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTheme.text(
              size: compact ? 10.5 : 11.5,
              weight: FontWeight.w700,
              color: color,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// شارة صغيرة لتنبيه أن الطلب تجاوز موعد التسليم.
class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.schedule_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            'متأخر',
            style: AppTheme.text(
              size: 10,
              weight: FontWeight.w700,
              color: AppColors.warning,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
