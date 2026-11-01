import '../models/laundry_order.dart';
import '../models/order_enums.dart';
import '../models/order_item.dart';
import '../utils/formatters.dart';
import '../utils/price_calculator.dart';

/// بيانات تجريبية تُضاف مرة واحدة فقط عند أول تشغيل للتطبيق.
///
/// الغرض منها عرض حالات مختلفة أمام الدكتور، وهي تتصرف كطلبات حقيقية:
/// يمكن تعديلها، نقلها للمرحلة التالية، تسليمها أو إلغاؤها.
/// لا تُضاف مرة أخرى بعد أول تشغيل حتى لو حذفها/عدّلها المستخدم.
class SampleData {
  const SampleData._();

  static List<LaundryOrder> build({DateTime? now}) {
    final DateTime today = AppFormatters.dateOnly(now ?? DateTime.now());

    OrderItem item(LaundryItemType type, ServiceType service, int quantity) {
      return OrderItem(
        type: type,
        service: service,
        quantity: quantity,
        unitPrice: PriceCalculator.unitPrice(type, service),
      );
    }

    LaundryOrder order({
      required int number,
      required String name,
      required String phone,
      required int receivedDaysAgo,
      required int dueDaysFromNow,
      required List<OrderItem> items,
      required OrderStatus status,
      String notes = '',
      int? deliveredDaysAgo,
      int? cancelledDaysAgo,
    }) {
      final DateTime received = today.subtract(Duration(days: receivedDaysAgo));
      return LaundryOrder.create(
        number: number,
        customerName: name,
        customerPhone: phone,
        receivedAt: received,
        dueAt: today.add(Duration(days: dueDaysFromNow)),
        items: items,
        notes: notes,
        status: status,
        createdAt: received.add(const Duration(hours: 9, minutes: 30)),
        deliveredAt: deliveredDaysAgo == null
            ? null
            : today.subtract(Duration(days: deliveredDaysAgo)).add(
                  const Duration(hours: 17),
                ),
        cancelledAt: cancelledDaysAgo == null
            ? null
            : today.subtract(Duration(days: cancelledDaysAgo)).add(
                  const Duration(hours: 11),
                ),
      );
    }

    return <LaundryOrder>[
      // أقدم طلب في السجل — ملغى (لا يُحتسب ضمن الإيرادات)
      order(
        number: 1,
        name: 'نورا أحمد',
        phone: '770334455',
        receivedDaysAgo: 6,
        dueDaysFromNow: -4,
        items: <OrderItem>[item(LaundryItemType.blanket, ServiceType.washOnly, 1)],
        status: OrderStatus.cancelled,
        notes: 'طلب العميل إلغاء الطلب قبل بدء الغسيل.',
        cancelledDaysAgo: 6,
      ),
      // طلب مسلّم (يُحتسب في الإيرادات ويظهر في السجل)
      order(
        number: 2,
        name: 'سمية حسن',
        phone: '778112233',
        receivedDaysAgo: 5,
        dueDaysFromNow: -3,
        items: <OrderItem>[
          item(LaundryItemType.dress, ServiceType.washAndIron, 2),
          item(LaundryItemType.thobe, ServiceType.ironOnly, 1),
        ],
        status: OrderStatus.delivered,
        notes: 'تم التسليم للعميل واستلام المبلغ نقدًا.',
        deliveredDaysAgo: 3,
      ),
      // جاهز للاستلام (بانتظار العميل)
      order(
        number: 3,
        name: 'خالد ناصر',
        phone: '771445566',
        receivedDaysAgo: 3,
        dueDaysFromNow: 0,
        items: <OrderItem>[
          item(LaundryItemType.jacket, ServiceType.washOnly, 1),
          item(LaundryItemType.shirt, ServiceType.washAndIron, 2),
        ],
        status: OrderStatus.ready,
        notes: 'الملابس جاهزة على الرف رقم 2.',
      ),
      // قيد التجهيز (كي)
      order(
        number: 4,
        name: 'فاطمة علي',
        phone: '772998877',
        receivedDaysAgo: 2,
        dueDaysFromNow: 1,
        items: <OrderItem>[
          item(LaundryItemType.thobe, ServiceType.washAndIron, 2),
          item(LaundryItemType.dress, ServiceType.ironOnly, 1),
        ],
        status: OrderStatus.preparing,
      ),
      // قيد الغسيل
      order(
        number: 5,
        name: 'محمد صالح',
        phone: '773556677',
        receivedDaysAgo: 1,
        dueDaysFromNow: 1,
        items: <OrderItem>[
          item(LaundryItemType.blanket, ServiceType.washAndIron, 1),
          item(LaundryItemType.pants, ServiceType.washOnly, 3),
        ],
        status: OrderStatus.washing,
        notes: 'بطانية كبيرة — غسيل منفصل.',
      ),
      // أحدث طلب: تم الاستلام اليوم
      order(
        number: 6,
        name: 'أحمد عبدالله',
        phone: '771234567',
        receivedDaysAgo: 0,
        dueDaysFromNow: 2,
        items: <OrderItem>[
          item(LaundryItemType.shirt, ServiceType.washAndIron, 3),
          item(LaundryItemType.pants, ServiceType.washOnly, 2),
        ],
        status: OrderStatus.received,
        notes: 'العميل يفضل تسليم الملابس بعد العصر.',
      ),
    ];
  }
}
