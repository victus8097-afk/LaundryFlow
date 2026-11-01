import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/laundry_order.dart';
import '../models/order_enums.dart';
import '../models/order_item.dart';
import '../providers/orders_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_status_stepper.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import 'add_order_screen.dart';

/// الشاشة الخامسة: تفاصيل الطلب وإدارة حالته.
///
/// تستقبل رقم الطلب فقط وتقرأ أحدث نسخة منه من [OrdersProvider]، لذلك تبقى
/// البيانات محدّثة تلقائيًا بعد أي تعديل أو تغيير حالة.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderNumber});

  final int orderNumber;

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();
    final LaundryOrder? order = provider.orderByNumber(orderNumber);

    if (order == null) {
      return Scaffold(
        appBar: AppTopBar(title: 'تفاصيل الطلب'),
        body: EmptyState(
          title: 'الطلب غير موجود',
          message: 'ربما تم حذف الطلب أو لم يعد متاحًا.',
          icon: Icons.receipt_long_rounded,
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: order.code,
        subtitle: 'تفاصيل الطلب وحالته',
        actions: <Widget>[
          if (order.isEditable)
            IconButton(
              onPressed: () => _openEdit(context, order),
              tooltip: 'تعديل الطلب',
              icon: const Icon(Icons.edit_outlined),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          4,
          AppSpacing.page,
          28,
        ),
        children: <Widget>[
          _HeaderCard(order: order),
          const SizedBox(height: 14),
          _buildCustomerCard(order),
          const SizedBox(height: 14),
          _buildProgressCard(order),
          const SizedBox(height: 14),
          _buildInvoiceCard(order),
          if (order.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            SectionCard(
              title: 'ملاحظات',
              icon: Icons.notes_rounded,
              showShadow: false,
              child: Text(
                order.notes,
                style: AppTheme.text(
                  size: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.9,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _buildActions(context, order),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // بطاقات الشاشة
  // ---------------------------------------------------------------------------

  Widget _buildCustomerCard(LaundryOrder order) {
    return SectionCard(
      title: 'بيانات العميل',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _initialOf(order.customerName),
                  style: AppTheme.text(
                    size: 17,
                    weight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.customerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.text(size: 14.5, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.phone(order.customerPhone),
                          style: AppTheme.text(
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.login_rounded,
            label: 'تاريخ استلام الملابس',
            value: AppFormatters.fullDate(order.receivedAt),
          ),
          _InfoRow(
            icon: Icons.event_available_rounded,
            label: 'موعد التسليم المتوقع',
            value: AppFormatters.fullDate(order.dueAt),
            hint: order.status.isActive ? AppFormatters.dueLabel(order.dueAt) : null,
            hintColor: order.isOverdue ? AppColors.warning : AppColors.primary,
          ),
          if (order.deliveredAt != null)
            _InfoRow(
              icon: Icons.verified_rounded,
              label: 'تم التسليم في',
              value:
                  '${AppFormatters.date(order.deliveredAt!)} • ${AppFormatters.time(order.deliveredAt!)}',
              hintColor: AppColors.delivered,
            ),
          if (order.cancelledAt != null)
            _InfoRow(
              icon: Icons.cancel_rounded,
              label: 'تم إلغاء الطلب في',
              value:
                  '${AppFormatters.date(order.cancelledAt!)} • ${AppFormatters.time(order.cancelledAt!)}',
              hintColor: AppColors.cancelled,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(LaundryOrder order) {
    final bool active = order.status.isActive;
    final double progress = order.status.flowIndex <= 0
        ? 0
        : order.status.flowIndex / (OrderStatus.flow.length - 1);

    return SectionCard(
      title: 'مراحل الطلب',
      icon: Icons.route_rounded,
      trailing: Text(
        active
            ? 'المرحلة ${order.status.stepNumber} من ${OrderStatus.flow.length}'
            : order.status.label,
        style: AppTheme.text(
          size: 10.5,
          weight: FontWeight.w600,
          color: order.status.color,
        ),
      ),
      child: Column(
        children: <Widget>[
          if (order.status != OrderStatus.cancelled) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                color: order.status == OrderStatus.delivered
                    ? AppColors.delivered
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
          ],
          OrderStatusStepper(status: order.status),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(LaundryOrder order) {
    return SectionCard(
      title: 'الملابس والخدمات',
      icon: Icons.checkroom_rounded,
      trailing: Text(
        AppFormatters.items(order.itemsCount),
        style: AppTheme.text(
          size: 10.5,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final OrderItem item in order.items) _InvoiceLine(item: item),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                'إجمالي الفاتورة',
                style: AppTheme.text(size: 13.5, weight: FontWeight.w700),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    AppFormatters.currency(order.total),
                    style: AppTheme.text(
                      size: 18,
                      weight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormatters.pieces(order.totalPieces)} • سعر كل قطعة محفوظ داخل الطلب',
            style: AppTheme.text(
              size: 10,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // الإجراءات
  // ---------------------------------------------------------------------------

  Widget _buildActions(BuildContext context, LaundryOrder order) {
    if (order.status.isFinished) {
      final bool delivered = order.status == OrderStatus.delivered;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: delivered ? AppColors.deliveredTint : AppColors.cancelledTint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              delivered ? Icons.verified_rounded : Icons.cancel_rounded,
              color: delivered ? AppColors.delivered : AppColors.cancelled,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                delivered
                    ? 'تم تسليم الطلب وأصبح في سجل الطلبات — للقراءة فقط.'
                    : 'تم إلغاء الطلب — لا يمكن تعديله أو تغيير حالته.',
                style: AppTheme.text(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: delivered ? AppColors.delivered : AppColors.cancelled,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final OrderStatus? next = order.status.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (order.status == OrderStatus.ready)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.ready),
            onPressed: () => _confirmDelivery(context, order),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
            label: const Text('تأكيد التسليم'),
          )
        else
          FilledButton.icon(
            onPressed:
                next == null ? null : () => _advanceStatus(context, order),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(
              next == null
                  ? 'لا توجد مرحلة تالية'
                  : 'الانتقال إلى «${next.label}»',
            ),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _openEdit(context, order),
          icon: const Icon(Icons.edit_outlined, size: 20),
          label: const Text('تعديل بيانات الطلب'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cancelled,
            side: const BorderSide(color: Color(0x33D0504C), width: 1.4),
            textStyle: AppTheme.text(
              size: 14.5,
              weight: FontWeight.w700,
              color: AppColors.cancelled,
            ),
          ),
          onPressed: () => _cancelOrder(context, order),
          icon: const Icon(Icons.cancel_outlined, size: 20),
          label: const Text('إلغاء الطلب'),
        ),
      ],
    );
  }

  void _openEdit(BuildContext context, LaundryOrder order) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AddOrderScreen(order: order),
      ),
    );
  }

  Future<void> _advanceStatus(BuildContext context, LaundryOrder order) async {
    final OrdersProvider provider = context.read<OrdersProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final OrderStatus? result = await provider.advanceStatus(order);
    if (result == null) {
      showAppSnackBarOn(
        messenger,
        'تعذر تغيير حالة الطلب، حاول مرة أخرى',
        isError: true,
      );
      return;
    }
    showAppSnackBarOn(
      messenger,
      'تم تحديث حالة الطلب إلى «${result.label}»',
      isSuccess: true,
    );
  }

  Future<void> _confirmDelivery(
    BuildContext context,
    LaundryOrder order,
  ) async {
    final OrdersProvider provider = context.read<OrdersProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool confirmed = await showConfirmDialog(
      context,
      title: 'تأكيد تسليم الملابس',
      message: 'هل استلم العميل ${order.customerName} ملابسه؟ '
          'سيصبح الطلب «تم التسليم»، وينتقل إلى سجل الطلبات، '
          'وتُحتسب قيمته ضمن الإيرادات.',
      confirmLabel: 'نعم، تم التسليم',
      icon: Icons.assignment_turned_in_outlined,
    );
    if (!confirmed) {
      return;
    }

    final bool done = await provider.confirmDelivery(order);
    showAppSnackBarOn(
      messenger,
      done
          ? 'تم تسليم الطلب ${order.code} وأصبح في السجل'
          : 'تعذر تأكيد التسليم، حاول مرة أخرى',
      isError: !done,
      isSuccess: done,
    );
  }

  Future<void> _cancelOrder(BuildContext context, LaundryOrder order) async {
    final OrdersProvider provider = context.read<OrdersProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool confirmed = await showConfirmDialog(
      context,
      title: 'إلغاء الطلب ${order.code}؟',
      message: 'سيتم إلغاء الطلب نهائيًا ونقله إلى سجل الطلبات، '
          'ولن تُحتسب قيمته ضمن الإيرادات. لا يمكن التراجع عن هذه العملية.',
      confirmLabel: 'نعم، إلغاء الطلب',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );
    if (!confirmed) {
      return;
    }

    final bool done = await provider.cancelOrder(order);
    showAppSnackBarOn(
      messenger,
      done ? 'تم إلغاء الطلب ${order.code}' : 'تعذر إلغاء الطلب',
      isError: !done,
      isSuccess: done,
    );
  }

  static String _initialOf(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '؟';
    }
    return trimmed.substring(0, 1);
  }
}

// -----------------------------------------------------------------------------
// أجزاء مساعدة
// -----------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'رقم الطلب',
                      style: AppTheme.text(
                        size: 10.5,
                        color: const Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.code,
                      style: AppTheme.text(
                        size: 23,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeaderStat(
                  label: 'إجمالي الفاتورة',
                  value: AppFormatters.currency(order.total),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  label: 'قطع الملابس',
                  value: '${order.totalPieces}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  label: 'الخدمات',
                  value: '${order.itemsCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x26FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text(
              size: 9.5,
              color: const Color(0xCCFFFFFF),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: AppTheme.text(
                size: 13,
                weight: FontWeight.w800,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.hint,
    this.hintColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final Color? hintColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(
                    size: 10.5,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (hintColor ?? AppColors.primary).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hint!,
                style: AppTheme.text(
                  size: 9.5,
                  weight: FontWeight.w700,
                  color: hintColor ?? AppColors.primary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  const _InvoiceLine({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.type.icon, size: 17, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${item.type.label} • ${item.service.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(size: 12.5, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} × ${AppFormatters.currency(item.unitPrice)}',
                  style: AppTheme.text(
                    size: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppFormatters.currency(item.total),
            style: AppTheme.text(size: 12, weight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
