import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/utils/formatters.dart';

void main() {
  group('AppFormatters - العملة والأرقام', () {
    test('تنسيق الأرقام بفواصل الآلاف', () {
      expect(AppFormatters.number(0), '0');
      expect(AppFormatters.number(600), '600');
      expect(AppFormatters.number(2800), '2,800');
      expect(AppFormatters.number(1234567), '1,234,567');
    });

    test('تنسيق العملة بالريال اليمني', () {
      expect(AppFormatters.currency(2800), '2,800 ر.ي');
    });

    test('صياغة عدد القطع بالعربية', () {
      expect(AppFormatters.pieces(1), 'قطعة واحدة');
      expect(AppFormatters.pieces(2), 'قطعتان');
      expect(AppFormatters.pieces(3), '3 قطع');
      expect(AppFormatters.pieces(12), '12 قطعة');
    });
  });

  group('AppFormatters - التواريخ', () {
    test('التاريخ بالاسم العربي للشهر', () {
      expect(AppFormatters.date(DateTime(2025, 3, 7)), '7 مارس 2025');
      expect(AppFormatters.numericDate(DateTime(2025, 3, 7)), '07/03/2025');
    });

    test('يرفض الوقت ويُبقي اليوم فقط عند الحاجة', () {
      final DateTime withTime = DateTime(2025, 3, 7, 14, 35);
      expect(AppFormatters.dateOnly(withTime), DateTime(2025, 3, 7));
      expect(AppFormatters.isSameDay(withTime, DateTime(2025, 3, 7)), isTrue);
    });

    test('وصف موعد التسليم النسبي', () {
      final DateTime today = AppFormatters.dateOnly(DateTime.now());
      expect(AppFormatters.dueLabel(today), 'اليوم');
      expect(
        AppFormatters.dueLabel(today.add(const Duration(days: 1))),
        'غدًا',
      );
      expect(
        AppFormatters.dueLabel(today.add(const Duration(days: 3))),
        'بعد 3 أيام',
      );
      expect(
        AppFormatters.dueLabel(today.subtract(const Duration(days: 2))),
        'متأخر يومين',
      );
    });

    test('تنسيق رقم الهاتف في مجموعات', () {
      expect(AppFormatters.phone('771234567'), '771 234 567');
    });
  });

  group('AppFormatters - البحث', () {
    test('توحيد شكل الحروف العربية لتسهيل البحث', () {
      expect(
        AppFormatters.normalize('أحمد'),
        AppFormatters.normalize('احمد'),
      );
      expect(
        AppFormatters.normalize('فاطمة'),
        AppFormatters.normalize('فاطمه'),
      );
      expect(AppFormatters.normalize('  علي  '), 'علي');
      expect(AppFormatters.normalize('ORD-0001'), 'ord-0001');
    });
  });
}
