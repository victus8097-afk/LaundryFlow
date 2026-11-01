import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/laundry_order.dart';
import '../models/order_enums.dart';
import '../providers/orders_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_filter_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_card.dart';

/// فلترة سجل الطلبات.
enum HistoryFilter {
  all('الكل'),
  delivered('تم التسليم'),
  cancelled('ملغى');

  const HistoryFilter(this.label);

  final String label;
}

/// الشاشة السادسة: سجل الطلبات السابقة (المسلّمة والملغاة).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onOpenOrder});

  final ValueChanged<int> onOpenOrder;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  HistoryFilter _filter = HistoryFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LaundryOrder> _applyFilters(List<LaundryOrder> orders) {
    final String query = AppFormatters.normalize(_query);
    return orders.where((LaundryOrder order) {
      if (_filter == HistoryFilter.delivered &&
          order.status != OrderStatus.delivered) {
        return false;
      }
      if (_filter == HistoryFilter.cancelled &&
          order.status != OrderStatus.cancelled) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return AppFormatters.normalize(order.customerName).contains(query) ||
          AppFormatters.normalize(order.code).contains(query) ||
          '${order.number}'.contains(query) ||
          order.customerPhone.contains(query);
    }).toList(growable: false);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = HistoryFilter.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();
    final List<LaundryOrder> history = provider.historyOrders;
    final List<LaundryOrder> filtered = _applyFilters(history);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        4,
        AppSpacing.page,
        120,
      ),
      children: <Widget>[
        _RevenueSummary(provider: provider),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (String value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          style: AppTheme.text(size: 13.5, weight: FontWeight.w400),
          cursorColor: AppColors.primary,
          decoration: AppTheme.fieldDecoration(
            hint: 'ابحث باسم العميل أو رقم الطلب',
            prefixIcon: Icons.search_rounded,
          ).copyWith(
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: _resetFilters,
                    tooltip: 'مسح البحث',
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              for (final HistoryFilter filter in HistoryFilter.values)
                AppFilterChip(
                  label: filter.label,
                  count: _countFor(history, filter),
                  color: _colorFor(filter),
                  selected: _filter == filter,
                  onTap: () => setState(() => _filter = filter),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Text(
              filtered.isEmpty
                  ? 'لا توجد طلبات مطابقة'
                  : '${filtered.length} طلب في السجل',
              style: AppTheme.text(
                size: 11.5,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (filtered.isNotEmpty)
              Text(
                '${AppFormatters.currency(_valueOf(filtered))}',
                style: AppTheme.text(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          SizedBox(
            height: 320,
            child: history.isEmpty
                ? const EmptyState(
                    title: 'لا يوجد سجل بعد',
                    message: 'ستظهر هنا الطلبات المسلّمة والملغاة بعد إتمامها.',
                    icon: Icons.history_rounded,
                  )
                : EmptyState(
                    title: 'لا توجد نتائج مطابقة',
                    message: 'جرّب كلمة بحث أخرى أو غيّر نوع الفلترة.',
                    icon: Icons.search_off_rounded,
                    actionLabel: 'إعادة تعيين البحث',
                    onAction: _resetFilters,
                  ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              final LaundryOrder order = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  order: order,
                  onTap: () => widget.onOpenOrder(order.number),
                ),
              );
            },
          ),
      ],
    );
  }

  static Color _colorFor(HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all:
        return AppColors.primary;
      case HistoryFilter.delivered:
        return AppColors.delivered;
      case HistoryFilter.cancelled:
        return AppColors.cancelled;
    }
  }

  static int _countFor(List<LaundryOrder> orders, HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all:
        return orders.length;
      case HistoryFilter.delivered:
        return orders
            .where((LaundryOrder order) => order.status == OrderStatus.delivered)
            .length;
      case HistoryFilter.cancelled:
        return orders
            .where((LaundryOrder order) => order.status == OrderStatus.cancelled)
            .length;
    }
  }

  /// قيمة الطلبات المسلّمة فقط داخل النتائج المعروضة.
  static int _valueOf(List<LaundryOrder> orders) {
    int total = 0;
    for (final LaundryOrder order in orders) {
      if (order.status == OrderStatus.delivered) {
        total += order.total;
      }
    }
    return total;
  }
}

/// بطاقة إجمالي الإيرادات في أعلى السجل.
class _RevenueSummary extends StatelessWidget {
  const _RevenueSummary({required this.provider});

  final OrdersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'إجمالي قيمة الطلبات المسلّمة',
                  style: AppTheme.text(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppFormatters.currency(provider.deliveredRevenue),
              style: AppTheme.text(
                size: 25,
                weight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              _SummaryPill(
                icon: Icons.verified_rounded,
                label: '${provider.deliveredCount} مسلَّم',
              ),
              _SummaryPill(
                icon: Icons.cancel_rounded,
                label: '${provider.cancelledCount} ملغى',
              ),
              const _SummaryPill(
                icon: Icons.inventory_2_rounded,
                label: 'الملغاة لا تُحتسب',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTheme.text(
              size: 10,
              weight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
