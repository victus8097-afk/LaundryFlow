import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/models/laundry_order.dart';
import 'package:laundry_flow/models/order_enums.dart';
import 'package:laundry_flow/models/order_item.dart';
import 'package:laundry_flow/utils/app_constants.dart';
import 'package:laundry_flow/utils/price_calculator.dart';

void main() {
  group('PriceCalculator - جدول الأسعار', () {
    test('كل أنواع الملابس والخدمات لها سعر أكبر من صفر', () {
      for (final LaundryItemType type in LaundryItemType.values) {
        for (final ServiceType service in ServiceType.values) {
          expect(
            PriceCalculator.unitPrice(type, service),
            greaterThan(0),
            reason: 'لا يوجد سعر لـ ${type.label} / ${service.label}',
          );
        }
      }
    });

    test('أسعار محددة من الجدول الثابت', () {
      expect(PriceCalculator.unitPrice(LaundryItemType.shirt, ServiceType.washOnly), 400);
      expect(PriceCalculator.unitPrice(LaundryItemType.pants, ServiceType.washAndIron), 700);
      expect(PriceCalculator.unitPrice(LaundryItemType.thobe, ServiceType.ironOnly), 500);
      expect(
        PriceCalculator.unitPrice(LaundryItemType.blanket, ServiceType.washAndIron),
        2000,
      );
    });

    test('الخدمة الشاملة أغلى من الغسيل فقط لنفس النوع', () {
      for (final LaundryItemType type in LaundryItemType.values) {
        expect(
          PriceCalculator.unitPrice(type, ServiceType.washAndIron),
          greaterThan(PriceCalculator.unitPrice(type, ServiceType.washOnly)),
        );
      }
    });
  });

  group('PriceCalculator - الإجماليات', () {
    const OrderItem shirts = OrderItem(
      type: LaundryItemType.shirt,
      service: ServiceType.washAndIron,
      quantity: 3,
      unitPrice: 600,
    );
    const OrderItem pants = OrderItem(
      type: LaundryItemType.pants,
      service: ServiceType.washOnly,
      quantity: 2,
      unitPrice: 500,
    );

    test('إجمالي القطع والقطع الكلي', () {
      expect(PriceCalculator.total(const <OrderItem>[shirts, pants]), 2800);
      expect(PriceCalculator.piecesCount(const <OrderItem>[shirts, pants]), 5);
      expect(PriceCalculator.total(const <OrderItem>[]), 0);
      expect(PriceCalculator.piecesCount(const <OrderItem>[]), 0);
    });

    test('تعديل جدول الأسعار لا يغيّر إجمالي طلب محفوظ', () {
      // السعر محفوظ داخل القطعة نفسها، ويُحسب الإجمالي منه لا من الجدول.
      const OrderItem legacyItem = OrderItem(
        type: LaundryItemType.shirt,
        service: ServiceType.washAndIron,
        quantity: 2,
        unitPrice: 100,
      );
      expect(PriceCalculator.total(const <OrderItem>[legacyItem]), 200);
      expect(
        PriceCalculator.unitPrice(LaundryItemType.shirt, ServiceType.washAndIron),
        isNot(100),
      );
    });

    test('الإيرادات تُحتسب من الطلبات المسلّمة فقط', () {
      final LaundryOrder delivered = LaundryOrder.create(
        number: 1,
        customerName: 'عميل',
        customerPhone: '771234567',
        receivedAt: DateTime(2025, 1, 1),
        dueAt: DateTime(2025, 1, 3),
        items: const <OrderItem>[shirts],
        status: OrderStatus.delivered,
        deliveredAt: DateTime(2025, 1, 3),
      );
      final LaundryOrder cancelled = LaundryOrder.create(
        number: 2,
        customerName: 'عميل',
        customerPhone: '771234567',
        receivedAt: DateTime(2025, 1, 1),
        dueAt: DateTime(2025, 1, 3),
        items: const <OrderItem>[pants],
        status: OrderStatus.cancelled,
        cancelledAt: DateTime(2025, 1, 1),
      );
      final LaundryOrder active = LaundryOrder.create(
        number: 3,
        customerName: 'عميل',
        customerPhone: '771234567',
        receivedAt: DateTime(2025, 1, 1),
        dueAt: DateTime(2025, 1, 3),
        items: const <OrderItem>[pants],
      );

      expect(
        PriceCalculator.deliveredRevenue(
          <LaundryOrder>[delivered, cancelled, active],
        ),
        1800,
      );
    });
  });

  test('عملة التطبيق هي ر.ي', () {
    expect(AppConstants.currencySymbol, 'ر.ي');
  });
}
