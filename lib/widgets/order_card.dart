import 'package:flutter/material.dart';

import '../models/laundry_order.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

/// بطاقة طلب تُستخدم في قائمة الطلبات وفي أحدث الطلبات بلوحة التحكم.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showDates = true,
  });

  final LaundryOrder order;
  final VoidCallback? onTap;
  final bool showDates;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                order.code,
                                style: AppTheme.text(
                                  size: 12,
                                  weight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              if (order.isOverdue) ...<Widget>[
                                const SizedBox(width: 6),
                                const OverdueBadge(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            order.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.text(
                              size: 15,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              _MetaInline(
                                icon: Icons.inventory_2_outlined,
                                text: AppFormatters.pieces(order.totalPieces),
                              ),
                              _MetaInline(
                                icon: Icons.layers_outlined,
                                text: AppFormatters.items(order.itemsCount),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        StatusBadge(status: order.status, compact: true),
                        const SizedBox(height: 10),
                        Text(
                          AppFormatters.currency(order.total),
                          style: AppTheme.text(
                            size: 13,
                            weight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (showDates) ...<Widget>[
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _DateMeta(
                          icon: Icons.login_rounded,
                          label: 'الاستلام',
                          value: AppFormatters.numericDate(order.receivedAt),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateMeta(
                          icon: Icons.event_available_rounded,
                          label: order.status.isFinished ? 'التسليم' : 'التسليم المتوقع',
                          value: AppFormatters.numericDate(
                            order.deliveredAt ?? order.dueAt,
                          ),
                        ),
                      ),
                    ],
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

class _MetaInline extends StatelessWidget {
  const _MetaInline({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.text(
            size: 11.5,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _DateMeta extends StatelessWidget {
  const _DateMeta({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text(
                  size: 10.5,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.text(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
