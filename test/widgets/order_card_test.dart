import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/models/laundry_order.dart';
import 'package:laundry_flow/models/order_enums.dart';
import 'package:laundry_flow/models/order_item.dart';
import 'package:laundry_flow/utils/app_theme.dart';
import 'package:laundry_flow/widgets/order_card.dart';
import 'package:laundry_flow/widgets/status_badge.dart';

LaundryOrder _buildOrder({OrderStatus status = OrderStatus.received}) {
  return LaundryOrder.create(
    number: 7,
    customerName: 'أحمد عبدالله',
    customerPhone: '771234567',
    receivedAt: DateTime(2025, 3, 1),
    dueAt: DateTime(2025, 3, 3),
    items: const <OrderItem>[
      OrderItem(
        type: LaundryItemType.shirt,
        service: ServiceType.washAndIron,
        quantity: 3,
        unitPrice: 600,
      ),
    ],
    status: status,
  );
}

void main() {
  testWidgets('بطاقة الطلب تعرض الرقم والاسم والقطع والإجمالي', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: OrderCard(order: _buildOrder())),
      ),
    );

    expect(find.text('ORD-0007'), findsOneWidget);
    expect(find.text('أحمد عبدالله'), findsOneWidget);
    expect(find.text('3 قطع'), findsOneWidget);
    expect(find.textContaining('1,800'), findsOneWidget);
    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('تم الاستلام'), findsOneWidget);
  });

  testWidgets('الضغط على البطاقة يستدعي onTap', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OrderCard(
            order: _buildOrder(),
            onTap: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(OrderCard));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('شارة الحالة تتغيّر مع حالة الطلب', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OrderCard(order: _buildOrder(status: OrderStatus.ready)),
        ),
      ),
    );

    expect(find.text('جاهز للاستلام'), findsOneWidget);
    expect(find.text('تم الاستلام'), findsNothing);
  });
}
