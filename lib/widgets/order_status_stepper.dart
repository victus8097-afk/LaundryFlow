import 'package:flutter/material.dart';

import '../models/order_enums.dart';
import '../utils/app_theme.dart';

/// شريط تقدّم رأسي يعرض مراحل الطلب الخمس بشكل واضح.
class OrderStatusStepper extends StatelessWidget {
  const OrderStatusStepper({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const _CancelledNotice();
    }

    final int currentIndex = status.flowIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < OrderStatus.flow.length; index++)
          _StatusStepRow(
            step: OrderStatus.flow[index],
            index: index,
            currentIndex: currentIndex,
            isLast: index == OrderStatus.flow.length - 1,
          ),
      ],
    );
  }
}

class _StatusStepRow extends StatelessWidget {
  const _StatusStepRow({
    required this.step,
    required this.index,
    required this.currentIndex,
    required this.isLast,
  });

  final OrderStatus step;
  final int index;
  final int currentIndex;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool isDone = index < currentIndex;
    final bool isCurrent = index == currentIndex;
    final bool isUpcoming = index > currentIndex;
    final Color activeColor = isCurrent ? step.color : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isUpcoming ? AppColors.surfaceMuted : activeColor,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? <BoxShadow>[
                        BoxShadow(
                          color: activeColor.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : step.icon,
                size: 16,
                color: isUpcoming ? AppColors.textMuted : Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.4,
                height: 26,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 26),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    step.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text(
                      size: 13.5,
                      weight: isUpcoming ? FontWeight.w400 : FontWeight.w700,
                      color: isUpcoming ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: step.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'المرحلة الحالية',
                      style: AppTheme.text(
                        size: 9.5,
                        weight: FontWeight.w700,
                        color: step.color,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelledNotice extends StatelessWidget {
  const _CancelledNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cancelledTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33D0504C)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cancel_rounded, color: AppColors.cancelled, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تم إلغاء هذا الطلب — لا يمكن تغيير حالته أو تعديل بياناته.',
              style: AppTheme.text(
                size: 12,
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
