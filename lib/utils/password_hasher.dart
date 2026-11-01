import 'dart:convert';
import 'dart:math';

/// تجزئة كلمة المرور محليًا (Salted hash) دون أي حزم خارجية.
///
/// كلمة المرور **لا تُحفظ كنص صريح**؛ يُحفظ ملح عشوائي مع بصمة مشتقة من
/// كلمة المرور والملح، ولا يمكن استرجاع كلمة المرور من البصمة.
///
/// ملاحظة تعليمية: هذا الحساب محلي بالكامل داخل الجهاز ويهدف إلى إخفاء
/// كلمة المرور عن التخزين المباشر، وليس بديلًا عن نظام مصادقة خادم حقيقي.
class PasswordHasher {
  const PasswordHasher._();

  /// عدد دورات الخلط — يجعل حساب البصمة مكلفًا نسبيًا.
  static const int _rounds = 1200;
  static const int _mask32 = 0xFFFFFFFF;
  static const int _saltBytes = 16;

  /// ملح عشوائي بطول 32 حرفًا hex (16 بايت).
  static String createSalt() {
    final Random random = Random.secure();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < _saltBytes; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// بصمة على الشكل: `v1$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
  static String hashPassword({
    required String password,
    required String salt,
  }) {
    final List<int> bytes = utf8.encode('$salt:$password');
    int h1 = 0x811C9DC5;
    int h2 = 0x01000193;
    int h3 = 0x9E3779B9;
    int h4 = 0x85EBCA6B;
    for (int round = 0; round < _rounds; round++) {
      for (final int byte in bytes) {
        final int mixed = (byte ^ (round & 0xFF)) & 0xFF;
        h1 = _mix(h1, mixed);
        h2 = _mix(h2, h1);
        h3 = _mix(h3, h2 ^ round);
        h4 = _mix(h4, h3 + mixed);
      }
    }
    return 'v1\$${_hex(h1)}${_hex(h2)}${_hex(h3)}${_hex(h4)}';
  }

  /// مقارنة كلمة المرور المُدخلة مع البصمة المحفوظة.
  static bool verifyPassword({
    required String password,
    required String salt,
    required String storedHash,
  }) {
    final String candidate = hashPassword(password: password, salt: salt);
    return _constantTimeEquals(candidate, storedHash);
  }

  // ---------------------------------------------------------------------------
  // أدوات داخلية
  // ---------------------------------------------------------------------------

  static int _mix(int state, int value) {
    int next = (state ^ value) & _mask32;
    next = _multiply32(next, 0x01000193);
    return ((next << 13) | (next >> 19)) & _mask32;
  }

  /// ضرب 32-بت آمن (يتجنب فقدان الدقة على المنصات الأخرى).
  static int _multiply32(int a, int b) {
    final int low = a & 0xFFFF;
    final int high = (a >> 16) & 0xFFFF;
    final int middle = ((high * b) + (low * (b >> 16))) & 0xFFFF;
    return ((low * (b & 0xFFFF)) + (middle << 16)) & _mask32;
  }

  static String _hex(int value) =>
      (value & _mask32).toRadixString(16).padLeft(8, '0');

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    int difference = 0;
    for (int i = 0; i < a.length; i++) {
      difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return difference == 0;
  }
}
