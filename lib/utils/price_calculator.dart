import '../models/laundry_order.dart';
import '../models/order_enums.dart';
import '../models/order_item.dart';
import 'app_constants.dart';

/// حساب الأسعار اعتمادًا على جدول الأسعار الثابت في [AppConstants].
class PriceCalculator {
  const PriceCalculator._();

  /// سعر القطعة الواحدة حسب نوع الملابس ونوع الخدمة.
  static int unitPrice(LaundryItemType type, ServiceType service) {
    final Map<ServiceType, int>? servicePrices = AppConstants.priceTable[type];
    return servicePrices?[service] ?? 0;
  }

  /// إجمالي سطر واحد.
  static int itemTotal(OrderItem item) => item.unitPrice * item.quantity;

  /// إجمالي مجموعة قطع.
  static int total(Iterable<OrderItem> items) {
    int sum = 0;
    for (final OrderItem item in items) {
      sum += item.unitPrice * item.quantity;
    }
    return sum;
  }

  /// عدد القطع الكلي.
  static int piecesCount(Iterable<OrderItem> items) {
    int sum = 0;
    for (final OrderItem item in items) {
      sum += item.quantity;
    }
    return sum;
  }

  /// إجمالي إيرادات قائمة طلبات (تُحتسب الطلبات المسلّمة فقط).
  static int deliveredRevenue(Iterable<LaundryOrder> orders) {
    int sum = 0;
    for (final LaundryOrder order in orders) {
      if (order.status == OrderStatus.delivered) {
        sum += order.total;
      }
    }
    return sum;
  }
}
