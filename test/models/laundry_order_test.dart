import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/models/laundry_order.dart';
import 'package:laundry_flow/models/order_enums.dart';
import 'package:laundry_flow/models/order_item.dart';

void main() {
  const OrderItem threeShirts = OrderItem(
    type: LaundryItemType.shirt,
    service: ServiceType.washAndIron,
    quantity: 3,
    unitPrice: 600,
  );
  const OrderItem twoPants = OrderItem(
    type: LaundryItemType.pants,
    service: ServiceType.washOnly,
    quantity: 2,
    unitPrice: 500,
  );

  LaundryOrder buildOrder() {
    return LaundryOrder.create(
      number: 1,
      customerName: '  أحمد عبدالله  ',
      customerPhone: ' 771234567 ',
      receivedAt: DateTime(2025, 3, 1),
      dueAt: DateTime(2025, 3, 3),
      items: const <OrderItem>[threeShirts, twoPants],
      notes: '  ملاحظة للعميل  ',
    );
  }

  group('LaundryOrder - الحسابات', () {
    test('يحسب إجمالي الفاتورة من سعر الوحدة المحفوظ', () {
      final LaundryOrder order = buildOrder();
      expect(order.total, 3 * 600 + 2 * 500);
      expect(order.total, 2800);
    });

    test('يحسب عدد القطع وعدد العناصر', () {
      final LaundryOrder order = buildOrder();
      expect(order.totalPieces, 5);
      expect(order.itemsCount, 2);
    });

    test('ينشئ رقم الطلب بالصيغة ORD-0001', () {
      final LaundryOrder order = buildOrder();
      expect(order.code, 'ORD-0001');
    });

    test('يقصّ المسافات الزائدة من اسم العميل والهاتف والملاحظات', () {
      final LaundryOrder order = buildOrder();
      expect(order.customerName, 'أحمد عبدالله');
      expect(order.customerPhone, '771234567');
      expect(order.notes, 'ملاحظة للعميل');
    });

    test('الطلب الجديد يبدأ بحالة «تم الاستلام» وقابل للتعديل', () {
      final LaundryOrder order = buildOrder();
      expect(order.status, OrderStatus.received);
      expect(order.isEditable, isTrue);
      expect(order.deliveredAt, isNull);
      expect(order.cancelledAt, isNull);
    });
  });

  group('LaundryOrder - التخزين المحلي', () {
    test('التحويل إلى JSON ثم القراءة يحافظ على كل البيانات', () {
      final LaundryOrder order = buildOrder().copyWith(
        status: OrderStatus.delivered,
        deliveredAt: DateTime(2025, 3, 4, 17, 30),
      );

      final LaundryOrder restored = LaundryOrder.fromJson(order.toJson());

      expect(restored.number, order.number);
      expect(restored.customerName, order.customerName);
      expect(restored.customerPhone, order.customerPhone);
      expect(restored.status, OrderStatus.delivered);
      expect(restored.receivedAt, order.receivedAt);
      expect(restored.dueAt, order.dueAt);
      expect(restored.deliveredAt, order.deliveredAt);
      expect(restored.notes, order.notes);
      expect(restored.items.length, 2);
      expect(restored.items.first, threeShirts);
      expect(restored.total, order.total);
    });

    test('الطلب المنتهي (مسلَّم) غير قابل للتعديل', () {
      final LaundryOrder order = buildOrder();
      final LaundryOrder delivered = order.copyWith(
        status: OrderStatus.delivered,
        deliveredAt: DateTime(2025, 3, 4),
      );
      expect(delivered.isEditable, isFalse);
      expect(delivered.status.isFinished, isTrue);
    });
  });

  group('OrderStatus - دورة الحالة', () {
    test('المسار الصحيح خطوة بخطوة', () {
      expect(OrderStatus.received.next, OrderStatus.washing);
      expect(OrderStatus.washing.next, OrderStatus.preparing);
      expect(OrderStatus.preparing.next, OrderStatus.ready);
      expect(OrderStatus.ready.next, OrderStatus.delivered);
      expect(OrderStatus.delivered.next, isNull);
      expect(OrderStatus.cancelled.next, isNull);
    });

    test('لا يمكن تخطي المراحل', () {
      expect(OrderStatus.received.canMoveTo(OrderStatus.washing), isTrue);
      expect(OrderStatus.received.canMoveTo(OrderStatus.preparing), isFalse);
      expect(OrderStatus.received.canMoveTo(OrderStatus.delivered), isFalse);
      expect(OrderStatus.ready.canMoveTo(OrderStatus.delivered), isTrue);
      expect(OrderStatus.delivered.canMoveTo(OrderStatus.cancelled), isFalse);
    });

    test('الإلغاء متاح للطلبات النشطة فقط', () {
      expect(OrderStatus.received.canMoveTo(OrderStatus.cancelled), isTrue);
      expect(OrderStatus.washing.canMoveTo(OrderStatus.cancelled), isTrue);
      expect(OrderStatus.delivered.canMoveTo(OrderStatus.cancelled), isFalse);
      expect(OrderStatus.cancelled.canMoveTo(OrderStatus.cancelled), isFalse);
    });

    test('أرقام المراحل وحالة النشاط', () {
      expect(OrderStatus.received.stepNumber, 1);
      expect(OrderStatus.ready.stepNumber, 4);
      expect(OrderStatus.delivered.stepNumber, 5);
      expect(OrderStatus.cancelled.stepNumber, 0);
      expect(OrderStatus.received.isActive, isTrue);
      expect(OrderStatus.delivered.isActive, isFalse);
      expect(OrderStatus.cancelled.isActive, isFalse);
    });
  });
}
