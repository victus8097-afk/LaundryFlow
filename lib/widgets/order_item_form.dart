import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/order_enums.dart';
import '../models/order_item.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/price_calculator.dart';

/// نموذج إضافة/تعديل قطعة واحدة داخل الطلب:
/// نوع الملابس + نوع الخدمة + الكمية، مع حساب سعر القطعة تلقائيًا.
class OrderItemForm extends StatefulWidget {
  const OrderItemForm({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    this.initialItem,
  });

  /// ترتيب القطعة داخل الطلب (يبدأ من صفر) — يُستخدم في العنوان.
  final int index;

  /// القطعة الأصلية عند تعديل طلب موجود.
  final OrderItem? initialItem;

  /// يُستدعى عند أي تغيير، مع القطعة المحسوبة أو null إذا كانت غير مكتملة.
  final ValueChanged<OrderItem?> onChanged;

  final VoidCallback onRemove;

  @override
  State<OrderItemForm> createState() => _OrderItemFormState();
}

class _OrderItemFormState extends State<OrderItemForm> {
  LaundryItemType? _type;
  ServiceType? _service;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _type = widget.initialItem?.type;
    _service = widget.initialItem?.service;
    _quantityController = TextEditingController(
      text: (widget.initialItem?.quantity ?? 1).toString(),
    );
    _quantityController.addListener(_handleQuantityChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_handleQuantityChanged);
    _quantityController.dispose();
    super.dispose();
  }

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;

  /// سعر الوحدة: يبقى سعر الطلب الأصلي ما دام النوع والخدمة لم يتغيرا
  /// (حتى لا تتغير فواتير الطلبات القديمة)، وإلا يُحسب من جدول الأسعار.
  int get _unitPrice {
    final LaundryItemType? type = _type;
    final ServiceType? service = _service;
    if (type == null || service == null) {
      return 0;
    }
    final OrderItem? original = widget.initialItem;
    if (original != null &&
        original.type == type &&
        original.service == service) {
      return original.unitPrice;
    }
    return PriceCalculator.unitPrice(type, service);
  }

  OrderItem? get _currentItem {
    final LaundryItemType? type = _type;
    final ServiceType? service = _service;
    if (type == null || service == null || _quantity <= 0) {
      return null;
    }
    return OrderItem(
      type: type,
      service: service,
      quantity: _quantity,
      unitPrice: _unitPrice,
    );
  }

  void _notifyParent() {
    if (!mounted) {
      return;
    }
    setState(() {});
    widget.onChanged(_currentItem);
  }

  void _handleQuantityChanged() => _notifyParent();

  void _changeQuantity(int delta) {
    final int next = (_quantity + delta).clamp(1, AppConstants.maxItemQuantity).toInt();
    final String text = next.toString();
    if (text == _quantityController.text) {
      return;
    }
    _quantityController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String? _validateType(LaundryItemType? value) =>
      value == null ? 'اختر نوع الملابس' : null;

  String? _validateService(ServiceType? value) =>
      value == null ? 'اختر نوع الخدمة' : null;

  String? _validateQuantity(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'أدخل الكمية';
    }
    final int? quantity = int.tryParse(text);
    if (quantity == null) {
      return 'أدخل رقمًا صحيحًا';
    }
    if (quantity <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    if (quantity > AppConstants.maxItemQuantity) {
      return 'الحد الأقصى ${AppConstants.maxItemQuantity}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int unitPrice = _unitPrice;
    final int lineTotal = unitPrice * _quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'قطعة الملابس ${widget.index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(size: 13, weight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                tooltip: 'إزالة القطعة',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.cancelled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<LaundryItemType>(
            isExpanded: true,
            // ignore: deprecated_member_use
            value: _type,
            validator: _validateType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: AppTheme.fieldDecoration(
              label: 'نوع الملابس',
              hint: 'اختر نوع الملابس',
              prefixIcon: _type?.icon ?? Icons.checkroom_outlined,
            ),
            style: AppTheme.text(size: 13.5, weight: FontWeight.w600),
            items: LaundryItemType.values
                .map(
                  (LaundryItemType type) => DropdownMenuItem<LaundryItemType>(
                    value: type,
                    child: Text(type.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (LaundryItemType? value) {
              _type = value;
              _notifyParent();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ServiceType>(
            isExpanded: true,
            // ignore: deprecated_member_use
            value: _service,
            validator: _validateService,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: AppTheme.fieldDecoration(
              label: 'نوع الخدمة',
              hint: 'اختر نوع الخدمة',
              prefixIcon: _service?.icon ?? Icons.local_laundry_service_outlined,
            ),
            style: AppTheme.text(size: 13.5, weight: FontWeight.w600),
            items: ServiceType.values
                .map(
                  (ServiceType service) => DropdownMenuItem<ServiceType>(
                    value: service,
                    child: Text(service.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (ServiceType? value) {
              _service = value;
              _notifyParent();
            },
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 2),
            child: Text(
              'الكمية',
              style: AppTheme.text(
                size: 11.5,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _QuantityButton(
                icon: Icons.remove_rounded,
                onTap: _quantity > 1 ? () => _changeQuantity(-1) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: _validateQuantity,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: AppTheme.text(size: 14, weight: FontWeight.w700),
                  cursorColor: AppColors.primary,
                  decoration: AppTheme.fieldDecoration(hint: '1').copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _QuantityButton(
                icon: Icons.add_rounded,
                onTap: _quantity < AppConstants.maxItemQuantity
                    ? () => _changeQuantity(1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _PriceTile(
                  label: 'سعر القطعة',
                  value: unitPrice == 0 ? '—' : AppFormatters.currency(unitPrice),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PriceTile(
                  label: 'إجمالي القطعة',
                  value: AppFormatters.currency(lineTotal),
                  highlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _service?.description ?? 'اختر نوع الملابس والخدمة لحساب السعر تلقائيًا',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text(
              size: 10.5,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.surface : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// مربّع صغير يعرض سعرًا (سعر القطعة أو إجماليها).
class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryTint : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? const Color(0x330E7C86) : AppColors.border,
        ),
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
              color: AppColors.textSecondary,
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
                size: 12,
                weight: FontWeight.w800,
                color: highlighted ? AppColors.primaryDark : AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
