import '../utils/app_constants.dart';
import 'order_enums.dart';
import 'order_item.dart';

/// نموذج طلب الغسيل: بيانات العميل + القطع + الحالة + التواريخ.
class LaundryOrder {
  const LaundryOrder({
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.receivedAt,
    required this.dueAt,
    required this.items,
    required this.status,
    required this.createdAt,
    this.notes = '',
    this.deliveredAt,
    this.cancelledAt,
  });

  /// إنشاء طلب جديد بحالة «تم الاستلام» وسعر محسوب لكل قطعة.
  factory LaundryOrder.create({
    required int number,
    required String customerName,
    required String customerPhone,
    required DateTime receivedAt,
    required DateTime dueAt,
    required List<OrderItem> items,
    String notes = '',
    OrderStatus status = OrderStatus.received,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return LaundryOrder(
      number: number,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      receivedAt: receivedAt,
      dueAt: dueAt,
      items: List<OrderItem>.unmodifiable(items),
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      notes: notes.trim(),
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
    );
  }

  final int number;
  final String customerName;
  final String customerPhone;
  final DateTime receivedAt;
  final DateTime dueAt;
  final List<OrderItem> items;
  final OrderStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  /// رقم الطلب بصيغته المعروضة: ORD-0001
  String get code => AppConstants.orderCode(number);

  /// إجمالي الفاتورة = مجموع (سعر الوحدة × الكمية) لكل القطع.
  int get total {
    int sum = 0;
    for (final OrderItem item in items) {
      sum += item.total;
    }
    return sum;
  }

  /// عدد قطع الملابس الكلي.
  int get totalPieces {
    int sum = 0;
    for (final OrderItem item in items) {
      sum += item.quantity;
    }
    return sum;
  }

  int get itemsCount => items.length;

  /// الطلب قابل للتعديل فقط ما دام نشطًا.
  bool get isEditable => !status.isFinished;

  /// هل تجاوز الطلب موعد التسليم المتوقع وما زال نشطًا؟
  bool get isOverdue {
    if (!status.isActive) {
      return false;
    }
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime due = DateTime(dueAt.year, dueAt.month, dueAt.day);
    return due.isBefore(today);
  }

  /// آخر حدث على الطلب — يُستخدم لترتيب سجل الطلبات.
  DateTime get lastActivityAt => deliveredAt ?? cancelledAt ?? createdAt;

  LaundryOrder copyWith({
    int? number,
    String? customerName,
    String? customerPhone,
    DateTime? receivedAt,
    DateTime? dueAt,
    List<OrderItem>? items,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return LaundryOrder(
      number: number ?? this.number,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      receivedAt: receivedAt ?? this.receivedAt,
      dueAt: dueAt ?? this.dueAt,
      items: items ?? this.items,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'number': number,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'receivedAt': receivedAt.toIso8601String(),
      'dueAt': dueAt.toIso8601String(),
      'items': items.map((OrderItem item) => item.toJson()).toList(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  factory LaundryOrder.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['items'] as List<dynamic>?) ?? <dynamic>[];
    final DateTime fallback = DateTime.now();
    return LaundryOrder(
      number: (json['number'] as num?)?.toInt() ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ?? fallback,
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '') ?? fallback,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(growable: false),
      status: OrderStatus.fromName(json['status'] as String?),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? fallback,
      deliveredAt: DateTime.tryParse(json['deliveredAt'] as String? ?? ''),
      cancelledAt: DateTime.tryParse(json['cancelledAt'] as String? ?? ''),
    );
  }

  @override
  String toString() => 'LaundryOrder($code, $customerName, ${status.name})';
}
