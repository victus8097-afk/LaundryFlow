import 'package:flutter/services.dart';

/// أدوات للتعامل مع الأرقام العربية-الهندية (٠١٢٣) التي تنتجها لوحات
/// المفاتيح العربية، حتى يقبل التطبيق رقم الهاتف بأي شكل يكتبه المستخدم.
class ArabicDigits {
  const ArabicDigits._();

  static const String _eastern = '٠١٢٣٤٥٦٧٨٩';
  static const String _persian = '۰۱۲۳۴۵۶۷۸۹';

  /// تحويل أي رقم عربي-هندي إلى الرقم اللاتيني المقابل: ٧٧١٢ ← 7712
  static String toWestern(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final int code in value.codeUnits) {
      final int easternIndex = _eastern.codeUnits.indexOf(code);
      if (easternIndex >= 0) {
        buffer.write(easternIndex);
        continue;
      }
      final int persianIndex = _persian.codeUnits.indexOf(code);
      if (persianIndex >= 0) {
        buffer.write(persianIndex);
        continue;
      }
      buffer.writeCharCode(code);
    }
    return buffer.toString();
  }

  /// الاحتفاظ بالأرقام فقط بعد تحويلها إلى الشكل اللاتيني.
  static String onlyDigits(String value) =>
      toWestern(value).replaceAll(RegExp('[^0-9]'), '');
}

/// مُنسِّق إدخال يحوّل الأرقام العربية-الهندية إلى لاتينية «أثناء الكتابة»،
/// ويسمح بالأرقام فقط — يُستخدم في حقول الهاتف.
class ArabicDigitsInputFormatter extends TextInputFormatter {
  const ArabicDigitsInputFormatter({this.maxLength});

  /// أقصى عدد أرقام مسموح (اختياري).
  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = ArabicDigits.onlyDigits(newValue.text);
    if (maxLength != null && text.length > maxLength!) {
      text = text.substring(0, maxLength);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
