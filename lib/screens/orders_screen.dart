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

/// الشاشة الثالثة: إدارة الطلبات النشطة مع البحث والتصفية.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    required this.onAddOrder,
    required this.onOpenOrder,
  });

  final VoidCallback onAddOrder;
  final ValueChanged<int> onOpenOrder;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  OrderStatus? _statusFilter;
  String _query = '';

  static const List<OrderStatus> _filterStatuses = <OrderStatus>[
    OrderStatus.received,
    OrderStatus.washing,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LaundryOrder> _applyFilters(List<LaundryOrder> orders) {
    final String query = AppFormatters.normalize(_query);
    return orders.where((LaundryOrder order) {
      if (_statusFilter != null && order.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final bool matchesName =
          AppFormatters.normalize(order.customerName).contains(query);
      final bool matchesCode =
          AppFormatters.normalize(order.code).contains(query);
      final bool matchesNumber = '${order.number}'.contains(query);
      final bool matchesPhone = order.customerPhone.contains(query);
      return matchesName || matchesCode || matchesNumber || matchesPhone;
    }).toList(growable: false);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _statusFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();
    final List<LaundryOrder> activeOrders = provider.activeOrders;
    final List<LaundryOrder> filtered = _applyFilters(activeOrders);
    final int filteredValue = filtered.fold<int>(
      0,
      (int sum, LaundryOrder order) => sum + order.total,
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 4, AppSpacing.page, 0),
          child: TextField(
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            children: <Widget>[
              AppFilterChip(
                label: 'الكل',
                count: activeOrders.length,
                selected: _statusFilter == null,
                onTap: () => setState(() => _statusFilter = null),
              ),
              for (final OrderStatus status in _filterStatuses)
                AppFilterChip(
                  label: status.label,
                  count: activeOrders
                      .where((LaundryOrder order) => order.status == status)
                      .length,
                  color: status.color,
                  selected: _statusFilter == status,
                  onTap: () => setState(
                    () => _statusFilter = _statusFilter == status ? null : status,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            12,
            AppSpacing.page,
            8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                filtered.isEmpty
                    ? 'لا توجد طلبات مطابقة'
                    : '${filtered.length} طلب نشط',
                style: AppTheme.text(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (filtered.isNotEmpty)
                Text(
                  'القيمة ${AppFormatters.currency(filteredValue)}',
                  style: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? (activeOrders.isEmpty
                  ? EmptyState(
                      title: 'لا توجد طلبات نشطة',
                      message: 'كل الطلبات مسلَّمة أو ملغاة. '
                          'أضف طلبًا جديدًا لتبدأ متابعة العمل.',
                      icon: Icons.local_laundry_service_rounded,
                      actionLabel: 'إضافة طلب جديد',
                      onAction: widget.onAddOrder,
                    )
                  : EmptyState(
                      title: 'لا توجد نتائج مطابقة',
                      message: 'جرّب كتابة اسم آخر أو تغيير تصفية الحالة.',
                      icon: Icons.search_off_rounded,
                      actionLabel: 'إعادة تعيين البحث',
                      onAction: _resetFilters,
                    ))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    4,
                    AppSpacing.page,
                    120,
                  ),
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
        ),
      ],
    );
  }
}
