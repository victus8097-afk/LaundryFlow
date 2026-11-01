import 'app_constants.dart';
import 'arabic_digits.dart';

/// قواعد التحقق المشتركة بين شاشات المصادقة و`AuthProvider` — مصدر واحد
/// للرسائل حتى تتطابق رسائل الواجهة مع ما يتحقق منه منطق الحفظ.
class AppValidators {
  const AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$',
  );

  /// حقل نصي مطلوب مع حد أدنى للطول.
  static String? requiredText(
    String? value, {
    required String fieldLabel,
    int minLength = 1,
    int? maxLength,
  }) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return '$fieldLabel مطلوب';
    }
    if (text.length < minLength) {
      return '$fieldLabel يجب ألا يقل عن $minLength حرف';
    }
    if (maxLength != null && text.length > maxLength) {
      return '$fieldLabel يجب ألا يزيد عن $maxLength حرف';
    }
    return null;
  }

  static String? shopName(String? value) => requiredText(
        value,
        fieldLabel: 'اسم المغسلة',
        minLength: AppConstants.minShopNameLength,
        maxLength: 60,
      );

  static String? ownerName(String? value) => requiredText(
        value,
        fieldLabel: 'اسم صاحب المغسلة',
        minLength: AppConstants.minOwnerNameLength,
        maxLength: 60,
      );

  /// رقم الهاتف: 9 أرقام تبدأ بـ 7 (يقبل الأرقام العربية-المكتوبة).
  static String? phone(String? value) {
    final String text = ArabicDigits.onlyDigits(value ?? '');
    if (text.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (text.length != AppConstants.phoneDigits) {
      return 'رقم الهاتف يجب أن يتكون من ${AppConstants.phoneDigits} أرقام';
    }
    if (!text.startsWith(AppConstants.phonePrefix)) {
      return 'رقم الهاتف يجب أن يبدأ بـ ${AppConstants.phonePrefix}';
    }
    return null;
  }

  static String? email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }
    return null;
  }

  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اختر المدينة';
    }
    return null;
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (text.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب ألا تقل عن ${AppConstants.minPasswordLength} أحرف';
    }
    if (text.length > AppConstants.maxPasswordLength) {
      return 'كلمة المرور يجب ألا تزيد عن ${AppConstants.maxPasswordLength} حرفًا';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (text != original) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  /// الموافقة على الشروط شرط لإنشاء الحساب.
  static String? terms(bool? accepted) =>
      accepted == true ? null : 'يجب الموافقة على الشروط للمتابعة';

  /// تنظيف رقم الهاتف قبل الحفظ أو المقارنة.
  static String normalizePhone(String value) => ArabicDigits.onlyDigits(value);

  /// توحيد بريد إلكتروني (حروف صغيرة بدون مسافات).
  static String normalizeEmail(String value) => value.trim().toLowerCase();
}
