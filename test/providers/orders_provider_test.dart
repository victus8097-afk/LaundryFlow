import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/models/laundry_order.dart';
import 'package:laundry_flow/models/order_enums.dart';
import 'package:laundry_flow/models/order_item.dart';
import 'package:laundry_flow/providers/orders_provider.dart';
import 'package:laundry_flow/services/local_storage_service.dart';

/// تخزين وهمي في الذاكرة بدل shared_preferences لاختبار المنطق فقط.
class _FakeStorage extends LocalStorageService {
  _FakeStorage({
    List<LaundryOrder> initialOrders = const <LaundryOrder>[],
    this.seeded = false,
    this.counter = 0,
  }) : orders = List<LaundryOrder>.of(initialOrders);

  List<LaundryOrder> orders;
  bool seeded;
  int counter;

  @override
  Future<List<LaundryOrder>> loadOrders() async =>
      List<LaundryOrder>.of(orders);

  @override
  Future<void> saveOrders(List<LaundryOrder> value) async {
    orders = List<LaundryOrder>.of(value);
  }

  @override
  Future<int> loadLastOrderNumber() async => counter;

  @override
  Future<void> saveLastOrderNumber(int value) async {
    counter = value;
  }

  @override
  Future<bool> hasSeededSampleData() async => seeded;

  @override
  Future<void> markSampleDataSeeded() async {
    seeded = true;
  }
}

const OrderItem _shirt = OrderItem(
  type: LaundryItemType.shirt,
  service: ServiceType.washAndIron,
  quantity: 2,
  unitPrice: 600,
);

void main() {
  group('OrdersProvider - التحميل والبيانات التجريبية', () {
    test('يضيف البيانات التجريبية عند أول تشغيل فقط', () async {
      final _FakeStorage storage = _FakeStorage();
      final OrdersProvider provider = OrdersProvider(storage: storage);

      await provider.load();

      expect(provider.isLoading, isFalse);
      expect(provider.orders.length, 6);
      expect(storage.seeded, isTrue);
      expect(provider.lastOrderNumber, 6);
      expect(provider.activeOrdersCount, 4);
      expect(provider.deliveredCount, 1);
      expect(provider.cancelledCount, 1);

      // إعادة تشغيل التطبيق: لا تتكرر البيانات التجريبية.
      final OrdersProvider second = OrdersProvider(storage: storage);
      await second.load();
      expect(second.orders.length, 6);
      expect(second.lastOrderNumber, 6);
    });

    test('يستعيد الطلبات المحفوظة ولا يعيد البيانات التجريبية', () async {
      final LaundryOrder saved = LaundryOrder.create(
        number: 12,
        customerName: 'عميل محفوظ',
        customerPhone: '771112233',
        receivedAt: DateTime(2025, 2, 1),
        dueAt: DateTime(2025, 2, 3),
        items: const <OrderItem>[_shirt],
      );
      final _FakeStorage storage = _FakeStorage(
        orders: <LaundryOrder>[saved],
        seeded: true,
        counter: 12,
      );
      final OrdersProvider provider = OrdersProvider(storage: storage);

      await provider.load();

      expect(provider.orders.length, 1);
      expect(provider.orders.first.customerName, 'عميل محفوظ');
      expect(provider.lastOrderNumber, 12);
    });
  });

  group('OrdersProvider - إنشاء وتعديل', () {
    test('ينشئ طلبًا برقم فريد وحالة «تم الاستلام» ويحفظه', () async {
      final _FakeStorage storage = _FakeStorage();
      final OrdersProvider provider = OrdersProvider(storage: storage);
      await provider.load();

      final LaundryOrder created = await provider.createOrder(
        customerName: 'علي محمد',
        customerPhone: '770000000',
        receivedAt: DateTime(2025, 5, 1),
        dueAt: DateTime(2025, 5, 3),
        items: const <OrderItem>[_shirt],
      );

      expect(created.code, 'ORD-0007');
      expect(created.status, OrderStatus.received);
      expect(created.total, 1200);
      expect(provider.lastOrderNumber, 7);
      expect(provider.activeOrders.first.number, created.number);
      expect(storage.counter, 7);
      expect(
        storage.orders.any((LaundryOrder o) => o.number == created.number),
        isTrue,
      );
    });

    test('يعدّل طلبًا نشطًا ويحفظ التغييرات', () async {
      final _FakeStorage storage = _FakeStorage();
      final OrdersProvider provider = OrdersProvider(storage: storage);
      await provider.load();

      final LaundryOrder target = provider.activeOrders.first;
      final bool updated = await provider.updateOrder(
        target.copyWith(
          customerName: 'اسم محدّث',
          notes: 'ملاحظة جديدة',
        ),
      );

      expect(updated, isTrue);
      expect(provider.orderByNumber(target.number)!.customerName, 'اسم محدّث');
      expect(
        storage.orders
            .firstWhere((LaundryOrder o) => o.number == target.number)
            .notes,
        'ملاحظة جديدة',
      );
    });

    test('يرفض تعديل طلب مسلَّم (للقراءة فقط)', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final LaundryOrder delivered = provider.orders
          .firstWhere((LaundryOrder o) => o.status == OrderStatus.delivered);

      expect(
        await provider.updateOrder(delivered.copyWith(customerName: 'تغيير')),
        isFalse,
      );
      expect(provider.orderByNumber(delivered.number)!.customerName, isNot('تغيير'));
    });
  });

  group('OrdersProvider - تغيير الحالات', () {
    test('ينتقل خطوة واحدة في كل مرة دون تخطي', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final LaundryOrder received = provider.orders
          .firstWhere((LaundryOrder o) => o.status == OrderStatus.received);

      expect(await provider.advanceStatus(received), OrderStatus.washing);
      expect(
        await provider.advanceStatus(provider.orderByNumber(received.number)!),
        OrderStatus.preparing,
      );
      expect(
        await provider.advanceStatus(provider.orderByNumber(received.number)!),
        OrderStatus.ready,
      );
      // «جاهز للاستلام» لا ينتقل تلقائيًا للتسليم عبر زر المرحلة التالية.
      expect(
        await provider.advanceStatus(provider.orderByNumber(received.number)!),
        isNull,
      );
    });

    test('تأكيد التسليم يعمل فقط للطلب الجاهز', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final LaundryOrder ready = provider.orders
          .firstWhere((LaundryOrder o) => o.status == OrderStatus.ready);
      final LaundryOrder received = provider.orders
          .firstWhere((LaundryOrder o) => o.status == OrderStatus.received);

      expect(await provider.confirmDelivery(received), isFalse);
      expect(await provider.confirmDelivery(ready), isTrue);

      final LaundryOrder delivered = provider.orderByNumber(ready.number)!;
      expect(delivered.status, OrderStatus.delivered);
      expect(delivered.deliveredAt, isNotNull);
      expect(
        provider.historyOrders.any((LaundryOrder o) => o.number == ready.number),
        isTrue,
      );
    });

    test('الإلغاء ينقل الطلب للسجل ولا يُحتسب ضمن الإيرادات', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final int revenueBefore = provider.deliveredRevenue;
      final LaundryOrder active = provider.activeOrders.first;

      expect(await provider.cancelOrder(active), isTrue);
      expect(
        provider.orderByNumber(active.number)!.status,
        OrderStatus.cancelled,
      );
      expect(provider.deliveredRevenue, revenueBefore);
      expect(
        provider.historyOrders.any((LaundryOrder o) => o.number == active.number),
        isTrue,
      );
      expect(
        await provider.cancelOrder(provider.orderByNumber(active.number)!),
        isFalse,
      );
    });

    test('لا يمكن تعديل حالة طلب منتهٍ', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final LaundryOrder delivered = provider.orders
          .firstWhere((LaundryOrder o) => o.status == OrderStatus.delivered);

      expect(await provider.advanceStatus(delivered), isNull);
      expect(await provider.cancelOrder(delivered), isFalse);
    });
  });

  group('OrdersProvider - الإحصائيات', () {
    test('الإيرادات تساوي مجموع الطلبات المسلّمة فقط', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      int expected = 0;
      for (final LaundryOrder order in provider.orders) {
        if (order.status == OrderStatus.delivered) {
          expected += order.total;
        }
      }

      expect(provider.deliveredRevenue, expected);
      expect(provider.deliveredRevenue, greaterThan(0));
    });

    test('عدد الطلبات النشطة = الإجمالي - المسلّمة - الملغاة', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      expect(
        provider.activeOrdersCount,
        provider.totalOrdersCount -
            provider.deliveredCount -
            provider.cancelledCount,
      );
    });

    test('الطلبات النشطة مرتبة من الأحدث إلى الأقدم', () async {
      final OrdersProvider provider =
          OrdersProvider(storage: _FakeStorage());
      await provider.load();

      final List<LaundryOrder> active = provider.activeOrders;
      for (int i = 1; i < active.length; i++) {
        expect(
          active[i - 1].createdAt.isBefore(active[i].createdAt),
          isFalse,
        );
      }
    });
  });
}
