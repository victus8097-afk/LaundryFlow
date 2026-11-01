import 'app_constants.dart';

/// تنسيق الأرقام والتواريخ والعملة بالعربية دون الاعتماد على حزم خارجية.
class AppFormatters {
  const AppFormatters._();

  static const List<String> _months = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<String> _weekdays = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  /// 1234567 ← 1,234,567
  static String number(num value) {
    final bool isNegative = value < 0;
    final String digits = value.abs().truncate().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return isNegative ? '-$buffer' : buffer.toString();
  }

  /// 1800 ← 1,800 ر.ي
  static String currency(num value) =>
      '${number(value)} ${AppConstants.currencySymbol}';

  static String monthName(int month) =>
      (month >= 1 && month <= 12) ? _months[month - 1] : '';

  /// 2025-03-07 ← 7 مارس 2025
  static String date(DateTime value) =>
      '${value.day} ${monthName(value.month)} ${value.year}';

  /// 2025-03-07 ← 7 مارس
  static String dayAndMonth(DateTime value) =>
      '${value.day} ${monthName(value.month)}';

  /// 2025-03-07 ← 07/03/2025
  static String numericDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  /// 2025-03-07 ← الجمعة
  static String weekday(DateTime value) =>
      (value.weekday >= 1 && value.weekday <= 7) ? _weekdays[value.weekday - 1] : '';

  /// الجمعة 7 مارس 2025
  static String fullDate(DateTime value) =>
      '${weekday(value)} ${date(value)}';

  static String time(DateTime value) {
    final int hour24 = value.hour;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String period = hour24 < 12 ? 'ص' : 'م';
    return '$hour12:$minute $period';
  }

  /// إزالة الوقت من التاريخ للعمل بتواريخ الأيام فقط.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// وصف مختصر لموعد التسليم: «اليوم»، «غدًا»، «بعد 3 أيام»، «متأخر يومين».
  static String dueLabel(DateTime due) {
    final DateTime today = dateOnly(DateTime.now());
    final int difference = dateOnly(due).difference(today).inDays;
    if (difference == 0) {
      return 'اليوم';
    }
    if (difference == 1) {
      return 'غدًا';
    }
    if (difference > 1) {
      return 'بعد $difference أيام';
    }
    final int late = difference.abs();
    if (late == 1) {
      return 'متأخر يوم';
    }
    if (late == 2) {
      return 'متأخر يومين';
    }
    return 'متأخر $late أيام';
  }

  /// تنسيق رقم الهاتف: 712345678 ← 712 345 678
  static String phone(String value) {
    final String digits = value.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length != AppConstants.maxCustomerPhoneDigits) {
      return value;
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  /// 3 ← «3 قطع»، 1 ← «قطعة واحدة»
  static String pieces(int count) {
    if (count == 1) {
      return 'قطعة واحدة';
    }
    if (count == 2) {
      return 'قطعتان';
    }
    if (count >= 3 && count <= 10) {
      return '$count قطع';
    }
    return '$count قطعة';
  }

  /// توحيد شكل النص العربي لتسهيل البحث:
  /// (أ إ آ ← ا)، (ة ← ه)، (ى ← ي)، وحذف التشكيل والمسافات الزائدة.
  static String normalize(String value) {
    String text = value.trim().toLowerCase();
    text = text.replaceAll(RegExp('[أإآٱ]'), 'ا');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ؤ', 'و');
    text = text.replaceAll('ئ', 'ي');
    text = text.replaceAll(RegExp('[\u064B-\u0652\u0670]'), '');
    return text;
  }

  /// 2 ← «عنصران»، 5 ← «5 عناصر»
  static String items(int count) {
    if (count == 1) {
      return 'عنصر واحد';
    }
    if (count == 2) {
      return 'عنصران';
    }
    return '$count عناصر';
  }
}
