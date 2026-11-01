import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/utils/arabic_digits.dart';
import 'package:laundry_flow/utils/validators.dart';

void main() {
  group('AppValidators - رقم الهاتف', () {
    test('يقبل رقمًا يمنيًا صحيحًا من 9 أرقام', () {
      expect(AppValidators.phone('771234567'), isNull);
    });

    test('يقبل الأرقام العربية-الهندية', () {
      expect(AppValidators.phone('٧٧١٢٣٤٥٦٧'), isNull);
    });

    test('يرفض الحقل الفارغ', () {
      expect(AppValidators.phone(''), 'رقم الهاتف مطلوب');
    });

    test('يرفض رقمًا أقل من 9 أرقام', () {
      expect(
        AppValidators.phone('77123'),
        'رقم الهاتف يجب أن يتكون من 9 أرقام',
      );
    });

    test('يرفض رقمًا لا يبدأ بـ 7', () {
      expect(AppValidators.phone('123456789'), contains('يبدأ'));
    });
  });

  group('AppValidators - البريد الإلكتروني', () {
    test('يقبل بريدًا صحيحًا', () {
      expect(AppValidators.email('owner@laundryflow.app'), isNull);
    });

    test('يرفض البريد الفارغ', () {
      expect(AppValidators.email(''), 'البريد الإلكتروني مطلوب');
    });

    test('يرفض الصيغ غير الصحيحة', () {
      expect(AppValidators.email('owner@'), isNotNull);
      expect(AppValidators.email('owner.laundryflow.app'), isNotNull);
      expect(AppValidators.email('owner@mail'), isNotNull);
    });
  });

  group('AppValidators - كلمة المرور', () {
    test('يقبل كلمة مرور من 6 أحرف', () {
      expect(AppValidators.password('123456'), isNull);
    });

    test('يرفض كلمة مرور قصيرة', () {
      expect(AppValidators.password('123'), contains('6'));
    });

    test('يرفض الحقل الفارغ', () {
      expect(AppValidators.password(''), 'كلمة المرور مطلوبة');
    });

    test('تأكيد كلمة المرور يجب أن يطابق الأصل', () {
      expect(AppValidators.confirmPassword('123456', '123456'), isNull);
      expect(
        AppValidators.confirmPassword('654321', '123456'),
        'كلمتا المرور غير متطابقتين',
      );
      expect(
        AppValidators.confirmPassword('', '123456'),
        'تأكيد كلمة المرور مطلوب',
      );
    });
  });

  group('AppValidators - بيانات المغسلة والشروط', () {
    test('اسم المغسلة مطلوب وحرفان على الأقل', () {
      expect(AppValidators.shopName('مغسلة النور'), isNull);
      expect(AppValidators.shopName(' '), 'اسم المغسلة مطلوب');
      expect(AppValidators.shopName('م'), isNotNull);
    });

    test('اسم صاحب المغسلة مطلوب', () {
      expect(AppValidators.ownerName('أحمد'), isNull);
      expect(AppValidators.ownerName(''), 'اسم صاحب المغسلة مطلوب');
    });

    test('المدينة مطلوبة', () {
      expect(AppValidators.city('عدن'), isNull);
      expect(AppValidators.city(null), 'اختر المدينة');
    });

    test('الموافقة على الشروط مطلوبة', () {
      expect(AppValidators.terms(true), isNull);
      expect(AppValidators.terms(false), isNotNull);
      expect(AppValidators.terms(null), isNotNull);
    });
  });

  group('ArabicDigits', () {
    test('يحول الأرقام العربية-الهندية إلى لاتينية', () {
      expect(ArabicDigits.toWestern('٧٧١٢٣٤٥٦٧'), '771234567');
      expect(ArabicDigits.toWestern('۱۲۳'), '123');
    });

    test('يحتفظ بالأرقام فقط', () {
      expect(ArabicDigits.onlyDigits('77-123 4567'), '771234567');
    });

    test('تنظيف الهاتف قبل المقارنة', () {
      expect(AppValidators.normalizePhone(' 771 234 567 '), '771234567');
    });
  });
}
