/// نتيجة عملية مصادقة (تسجيل دخول، إنشاء حساب، استعادة كلمة المرور).
///
/// تُرجعها `AuthProvider` لتتمكن الشاشات من عرض رسالة نجاح أو خطأ واضحة.
class AuthResult {
  const AuthResult._({required this.success, required this.message});

  /// عملية ناجحة مع رسالة تظهر للمستخدم.
  const AuthResult.success(this.message) : success = true;

  /// عملية فاشلة مع سبب الفشل.
  const AuthResult.failure(this.message) : success = false;

  final bool success;
  final String message;

  @override
  String toString() => 'AuthResult(success: $success, message: $message)';
}
