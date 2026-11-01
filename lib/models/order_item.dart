import 'order_enums.dart';

/// قطعة واحدة داخل الطلب: نوع الملابس + الخدمة + الكمية + سعر الوحدة.
///
/// [unitPrice] يُحفظ داخل الطلب لحظة إنشائه، لذلك لا تتغير فواتير الطلبات
/// القديمة إذا عُدّل جدول الأسعار في `AppConstants` لاحقًا.
class OrderItem {
  const OrderItem({
    required this.type,
    required this.service,
    required this.quantity,
    required this.unitPrice,
  });

  final LaundryItemType type;
  final ServiceType service;
  final int quantity;
  final int unitPrice;

  /// إجمالي السطر = سعر الوحدة × الكمية.
  int get total => unitPrice * quantity;

  OrderItem copyWith({
    LaundryItemType? type,
    ServiceType? service,
    int? quantity,
    int? unitPrice,
  }) {
    return OrderItem(
      type: type ?? this.type,
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'service': service.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      type: LaundryItemType.fromName(json['type'] as String?),
      service: ServiceType.fromName(json['service'] as String?),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is OrderItem &&
        other.type == type &&
        other.service == service &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice;
  }

  @override
  int get hashCode => Object.hash(type, service, quantity, unitPrice);

  @override
  String toString() => 'OrderItem(${type.name}, ${service.name}, x$quantity)';
}
