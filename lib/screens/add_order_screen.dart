import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/laundry_order.dart';
import '../models/order_item.dart';
import '../providers/orders_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/price_calculator.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/order_item_form.dart';
import '../widgets/section_card.dart';

/// الشاشة الرابعة: إضافة طلب جديد أو تعديل طلب موجود.
class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key, this.order});

  /// الطلب المطلوب تعديله (null عند إنشاء طلب جديد).
  final LaundryOrder? order;

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

/// عنصر مسودة داخل النموذج: يحمل معرّفًا ثابتًا للمفاتيح، والقطعة الأصلية.
class _ItemDraft {
  _ItemDraft({required this.id, this.initial, this.item});

  final int id;
  final OrderItem? initial;
  OrderItem? item;
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<_ItemDraft> _drafts = <_ItemDraft>[];

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  late DateTime _receivedDate;
  late DateTime _dueDate;

  int _nextDraftId = 1;
  bool _isSaving = false;
  String? _itemsError;

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final LaundryOrder? order = widget.order;
    final DateTime today = AppFormatters.dateOnly(DateTime.now());

    _nameController = TextEditingController(text: order?.customerName ?? '');
    _phoneController = TextEditingController(text: order?.customerPhone ?? '');
    _notesController = TextEditingController(text: order?.notes ?? '');

    _receivedDate = order == null
        ? today
        : AppFormatters.dateOnly(order.receivedAt);
    _dueDate = order == null
        ? today.add(const Duration(days: AppConstants.defaultDeliveryDays))
        : AppFormatters.dateOnly(order.dueAt);

    if (order != null && order.items.isNotEmpty) {
      for (final OrderItem item in order.items) {
        _drafts.add(_ItemDraft(id: _nextDraftId++, initial: item, item: item));
      }
    } else {
      _drafts.add(_ItemDraft(id: _nextDraftId++));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // حسابات مباشرة
  // ---------------------------------------------------------------------------

  List<OrderItem> get _validItems {
    final List<OrderItem> items = <OrderItem>[];
    for (final _ItemDraft draft in _drafts) {
      final OrderItem? item = draft.item;
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  int get _total => PriceCalculator.total(_validItems);

  int get _piecesCount => PriceCalculator.piecesCount(_validItems);

  String? get _dateError => _dueDate.isBefore(_receivedDate)
      ? 'موعد التسليم لا يمكن أن يسبق تاريخ الاستلام'
      : null;

  // ---------------------------------------------------------------------------
  // تحقق من الحقول
  // ---------------------------------------------------------------------------

  String? _validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'اسم العميل مطلوب';
    }
    if (text.length < AppConstants.minCustomerNameLength) {
      return 'الاسم يجب ألا يقل عن حرفين';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
      return 'يُسمح بالأرقام فقط';
    }
    if (text.length != AppConstants.maxCustomerPhoneDigits) {
      return 'رقم الهاتف يجب أن يتكون من 9 أرقام';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // تعديل القطع
  // ---------------------------------------------------------------------------

  void _addDraft() {
    setState(() {
      _drafts.add(_ItemDraft(id: _nextDraftId++));
      _itemsError = null;
    });
  }

  void _removeDraft(int id) {
    setState(() {
      _drafts.removeWhere((_ItemDraft draft) => draft.id == id);
    });
  }

  void _handleItemChanged(int id, OrderItem? item) {
    final int index =
        _drafts.indexWhere((_ItemDraft draft) => draft.id == id);
    if (index < 0) {
      return;
    }
    setState(() {
      _drafts[index].item = item;
      if (item != null) {
        _itemsError = null;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // اختيار التواريخ
  // ---------------------------------------------------------------------------

  Future<void> _pickDate({required bool isReceived}) async {
    final DateTime initial = isReceived ? _receivedDate : _dueDate;
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: isReceived ? 'تاريخ استلام الملابس' : 'موعد التسليم المتوقع',
      confirmText: 'اختيار',
      cancelText: 'إلغاء',
    ) ?? initial;

    if (!mounted) {
      return;
    }
    setState(() {
      if (isReceived) {
        _receivedDate = AppFormatters.dateOnly(picked);
      } else {
        _dueDate = AppFormatters.dateOnly(picked);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // الحفظ
  // ---------------------------------------------------------------------------

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    final bool formValid = _formKey.currentState?.validate() ?? false;
    final List<OrderItem> items = _validItems;
    // كل مسودة يجب أن تكون مكتملة (نوع + خدمة + كمية صحيحة) قبل الحفظ.
    final bool allDraftsComplete = _drafts.length == items.length;

    setState(() {
      if (items.isEmpty) {
        _itemsError = 'أضف قطعة واحدة على الأقل وحدد نوعها وخدمتها';
      } else if (!allDraftsComplete) {
        _itemsError = 'أكمل بيانات جميع القطع أو احذف القطع الناقصة';
      } else {
        _itemsError = null;
      }
    });

    if (!formValid || items.isEmpty || !allDraftsComplete) {
      showAppSnackBar(
        context,
        items.isNotEmpty && !allDraftsComplete
            ? 'أكمل بيانات جميع القطع (النوع والخدمة والكمية) قبل الحفظ'
            : 'تحقق من البيانات المطلوبة قبل حفظ الطلب',
        isError: true,
      );
      return;
    }

    if (_dateError != null) {
      showAppSnackBar(context, _dateError!, isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final OrdersProvider provider = context.read<OrdersProvider>();
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String notes = _notesController.text.trim();

    bool saved;
    late String code;

    if (_isEditing) {
      final LaundryOrder updated = widget.order!.copyWith(
        customerName: name,
        customerPhone: phone,
        receivedAt: _receivedDate,
        dueAt: _dueDate,
        items: List<OrderItem>.unmodifiable(items),
        notes: notes,
      );
      saved = await provider.updateOrder(updated);
      code = updated.code;
    } else {
      final LaundryOrder created = await provider.createOrder(
        customerName: name,
        customerPhone: phone,
        receivedAt: _receivedDate,
        dueAt: _dueDate,
        items: items,
        notes: notes,
      );
      saved = true;
      code = created.code;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    final NavigatorState navigator = Navigator.of(context);

    if (!saved) {
      showAppSnackBar(
        context,
        'تعذر حفظ التعديلات: الطلبات المسلَّمة أو الملغاة للقراءة فقط.',
        isError: true,
      );
      return;
    }

    showAppSnackBar(
      context,
      _isEditing
          ? 'تم تحديث الطلب $code بنجاح'
          : 'تم إنشاء الطلب $code بنجاح',
      isSuccess: true,
    );
    navigator.pop(true);
  }

  // ---------------------------------------------------------------------------
  // الواجهة
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEditing ? 'تعديل الطلب ${widget.order!.code}' : 'طلب جديد',
        subtitle: _isEditing
            ? 'حدّث البيانات ثم احفظ التعديلات'
            : 'سجّل بيانات العميل وقطع الملابس',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            4,
            AppSpacing.page,
            20,
          ),
          children: <Widget>[
            _buildCustomerSection(),
            const SizedBox(height: 14),
            _buildItemsSection(),
            const SizedBox(height: 14),
            _buildSummarySection(),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'يُحفظ سعر كل قطعة داخل الطلب، لذلك لا تتأثر الفاتورة بتغيّر جدول الأسعار لاحقًا.',
                    style: AppTheme.text(
                      size: 10.5,
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCustomerSection() {
    return SectionCard(
      title: 'بيانات العميل',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppTextField(
            controller: _nameController,
            label: 'اسم العميل',
            hint: 'مثال: أحمد عبدالله',
            prefixIcon: Icons.person_rounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: _validateName,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'مثال: 771234567',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: AppConstants.maxCustomerPhoneDigits,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                AppConstants.maxCustomerPhoneDigits,
              ),
            ],
            validator: _validatePhone,
          ),
          const SizedBox(height: 6),
          _DateSelector(
            label: 'تاريخ استلام الملابس',
            icon: Icons.login_rounded,
            value: _receivedDate,
            hint: AppFormatters.weekday(_receivedDate),
            onTap: () => _pickDate(isReceived: true),
          ),
          const SizedBox(height: 14),
          _DateSelector(
            label: 'موعد التسليم المتوقع',
            icon: Icons.event_available_rounded,
            value: _dueDate,
            hint: AppFormatters.dueLabel(_dueDate),
            errorText: _dateError,
            onTap: () => _pickDate(isReceived: false),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _notesController,
            label: 'ملاحظات إضافية (اختياري)',
            hint: 'مثال: العميل يفضل التسليم بعد العصر',
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
            maxLength: 150,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return SectionCard(
      title: 'تفاصيل الملابس',
      icon: Icons.checkroom_rounded,
      trailing: Text(
        AppFormatters.items(_validItems.length),
        style: AppTheme.text(
          size: 10.5,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_drafts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.checkroom_outlined,
                    size: 28,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم تُضف أي قطعة بعد',
                    style: AppTheme.text(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._drafts.asMap().entries.map(
                  (MapEntry<int, _ItemDraft> entry) => OrderItemForm(
                    key: ValueKey<int>(entry.value.id),
                    index: entry.key,
                    initialItem: entry.value.initial,
                    onChanged: (OrderItem? item) =>
                        _handleItemChanged(entry.value.id, item),
                    onRemove: () => _removeDraft(entry.value.id),
                  ),
                ),
          if (_itemsError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 15,
                    color: AppColors.cancelled,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _itemsError!,
                      style: AppTheme.text(
                        size: 11.5,
                        color: AppColors.cancelled,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addDraft,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('إضافة قطعة أخرى'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return SectionCard(
      title: 'ملخص الفاتورة',
      icon: Icons.receipt_long_rounded,
      showShadow: false,
      child: Column(
        children: <Widget>[
          _SummaryRow(
            label: 'عدد العناصر',
            value: AppFormatters.items(_validItems.length),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'عدد قطع الملابس',
            value: AppFormatters.pieces(_piecesCount),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                'الإجمالي',
                style: AppTheme.text(size: 13.5, weight: FontWeight.w700),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    AppFormatters.currency(_total),
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
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          12,
          AppSpacing.page,
          12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'الإجمالي المستحق',
                  style: AppTheme.text(
                    size: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  AppFormatters.currency(_total),
                  style: AppTheme.text(
                    size: 15,
                    weight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _isEditing ? 'حفظ التعديلات' : 'حفظ الطلب',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// اختيار تاريخ عبر Date Picker بتصميم مطابق لبقية الحقول.
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.hint,
    this.errorText,
  });

  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final String? hint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 2),
          child: Text(
            label,
            style: AppTheme.text(
              size: 11.5,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.field),
                border: Border.all(
                  color: hasError ? AppColors.cancelled : AppColors.border,
                  width: hasError ? 1.5 : 1.3,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 19, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppFormatters.fullDate(value),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.text(
                            size: 12.5,
                            weight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        if (hint != null)
                          Text(
                            hint!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.text(
                              size: 10,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 2),
            child: Text(
              errorText!,
              style: AppTheme.text(
                size: 11.5,
                color: AppColors.cancelled,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: AppTheme.text(
            size: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.text(size: 12, weight: FontWeight.w700),
        ),
      ],
    );
  }
}
