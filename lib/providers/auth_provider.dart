import 'package:flutter/foundation.dart';

import '../models/auth_result.dart';
import '../models/owner_account.dart';
import '../services/auth_storage_service.dart';
import '../utils/app_constants.dart';
import '../utils/password_hasher.dart';
import '../utils/validators.dart';

/// حالة المصادقة في التطبيق.
enum AuthStatus {
  /// جارٍ قراءة الحساب المحفوظ من الجهاز.
  checking,

  /// لا توجد جلسة نشطة — يجب تسجيل الدخول.
  signedOut,

  /// صاحب المغسلة مسجل الدخول.
  signedIn,
}

/// إدارة حساب صاحب المغسلة: التحميل، إنشاء الحساب، تسجيل الدخول،
/// استعادة كلمة المرور، وتسجيل الخروج.
///
/// الحساب واحد فقط لكل جهاز (مغسلة واحدة)، ويُحفظ محليًا دون سيرفر.
/// الحقول تُتحقق هنا أيضًا وبنفس رسائل الواجهة ([AppValidators]) حتى لا
/// يُحفظ حساب ببيانات غير صحيحة.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthStorageService? storage})
      : _storage = storage ?? const AuthStorageService();

  final AuthStorageService _storage;

  AuthStatus _status = AuthStatus.checking;
  OwnerAccount? _account;
  bool _isBusy = false;
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // قراءة الحالة
  // ---------------------------------------------------------------------------

  AuthStatus get status => _status;
  bool get isChecking => _status == AuthStatus.checking;
  bool get isSignedIn => _status == AuthStatus.signedIn;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  OwnerAccount? get account => _account;
  bool get hasAccount => _account != null;

  /// هل الحساب الحالي هو الحساب التجريبي الجاهز؟
  bool get hasDemoAccount => _account?.isDemo ?? false;

  String get shopName => _account?.shopName ?? AppConstants.appName;
  String get ownerName => _account?.ownerName ?? '';
  String get city => _account?.city ?? '';

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // التحميل الأول
  // ---------------------------------------------------------------------------

  /// قراءة الحساب المحفوظ. إن لم يوجد حساب على الجهاز نُنشئ الحساب التجريبي
  /// الجاهز (أول تشغيل فقط) ليكون التطبيق قابلًا للتجربة فورًا.
  Future<void> load() async {
    _status = AuthStatus.checking;
    notifyListeners();
    try {
      OwnerAccount? stored = await _storage.loadAccount();
      if (stored == null) {
        stored = _buildDemoAccount();
        await _storage.saveAccount(stored);
        await _storage.saveRememberedSession(false);
      }
      _account = stored;
      final bool remembered = await _storage.loadRememberedSession();
      _status = remembered ? AuthStatus.signedIn : AuthStatus.signedOut;
    } catch (_) {
      // فشل التخزين لا يمنع استخدام التطبيق: نطلب تسجيل الدخول.
      _account = null;
      _status = AuthStatus.signedOut;
    }
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // إنشاء حساب جديد
  // ---------------------------------------------------------------------------

  Future<AuthResult> register({
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String city,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    if (_isBusy) {
      return const AuthResult.failure('جارٍ تنفيذ عملية أخرى، انتظر لحظة');
    }

    final String? validationError = AppValidators.shopName(shopName) ??
        AppValidators.ownerName(ownerName) ??
        AppValidators.phone(phone) ??
        AppValidators.email(email) ??
        AppValidators.city(city) ??
        AppValidators.password(password) ??
        AppValidators.confirmPassword(confirmPassword, password) ??
        AppValidators.terms(acceptedTerms);

    if (validationError != null) {
      return _fail(validationError);
    }

    _setBusy(true);
    try {
      final String salt = PasswordHasher.createSalt();
      final OwnerAccount account = OwnerAccount(
        shopName: shopName.trim(),
        ownerName: ownerName.trim(),
        phone: AppValidators.normalizePhone(phone),
        email: AppValidators.normalizeEmail(email),
        city: city.trim(),
        passwordHash: PasswordHasher.hashPassword(password: password, salt: salt),
        salt: salt,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isDemo: false,
      );

      await _storage.saveAccount(account);
      try {
        await _storage.saveRememberedSession(true);
      } catch (_) {
        // فشل حفظ الجلسة لا يُبطل إنشاء الحساب نفسه.
      }
      _account = account;
      _status = AuthStatus.signedIn;
      _errorMessage = null;
      return AuthResult.success('تم إنشاء حساب «${account.shopName}» بنجاح');
    } catch (_) {
      return _fail('تعذّر حفظ الحساب على الجهاز، حاول مرة أخرى');
    } finally {
      _setBusy(false);
    }
  }

  // ---------------------------------------------------------------------------
  // تسجيل الدخول
  // ---------------------------------------------------------------------------

  Future<AuthResult> login({
    required String phone,
    required String password,
    bool rememberMe = true,
  }) async {
    if (_isBusy) {
      return const AuthResult.failure('جارٍ تنفيذ عملية أخرى، انتظر لحظة');
    }

    final String? phoneError = AppValidators.phone(phone);
    if (phoneError != null) {
      return _fail(phoneError);
    }
    if (password.trim().isEmpty) {
      return _fail('كلمة المرور مطلوبة');
    }

    final OwnerAccount? account = _account ?? await _storage.loadAccount();
    if (account == null) {
      return _fail('لا يوجد حساب على هذا الجهاز — أنشئ حسابًا جديدًا أولًا');
    }

    _setBusy(true);
    try {
      final String normalizedPhone = AppValidators.normalizePhone(phone);
      if (account.phone != normalizedPhone ||
          !account.matchesPassword(password)) {
        return _fail('رقم الهاتف أو كلمة المرور غير صحيحة');
      }

      OwnerAccount current = account;
      try {
        current = account.copyWith(lastLoginAt: DateTime.now());
        await _storage.saveAccount(current);
        await _storage.saveRememberedSession(rememberMe);
      } catch (_) {
        // فشل الحفظ لا يمنع الدخول في الجلسة الحالية.
      }
      _account = current;
      _status = AuthStatus.signedIn;
      _errorMessage = null;
      return AuthResult.success('أهلًا بك مجددًا، ${current.ownerName}');
    } catch (_) {
      return _fail('تعذّر إكمال تسجيل الدخول، حاول مرة أخرى');
    } finally {
      _setBusy(false);
    }
  }

  // ---------------------------------------------------------------------------
  // استعادة كلمة المرور
  // ---------------------------------------------------------------------------

  /// استعادة كلمة المرور داخل الجهاز: يتم التأكد من رقم الهاتف واسم المغسلة
  /// (بيانات يعرفها صاحب المغسلة فقط) ثم تُحفظ كلمة مرور جديدة.
  Future<AuthResult> resetPassword({
    required String phone,
    required String shopName,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isBusy) {
      return const AuthResult.failure('جارٍ تنفيذ عملية أخرى، انتظر لحظة');
    }

    final String? validationError = AppValidators.phone(phone) ??
        AppValidators.shopName(shopName) ??
        AppValidators.password(newPassword) ??
        AppValidators.confirmPassword(confirmPassword, newPassword);
    if (validationError != null) {
      return _fail(validationError);
    }

    final OwnerAccount? account = _account ?? await _storage.loadAccount();
    if (account == null) {
      return _fail('لا يوجد حساب على هذا الجهاز — أنشئ حسابًا جديدًا أولًا');
    }

    _setBusy(true);
    try {
      final bool samePhone =
          account.phone == AppValidators.normalizePhone(phone);
      final bool sameShop = _sameShopName(account.shopName, shopName);
      if (!samePhone || !sameShop) {
        return _fail('بيانات الحساب غير مطابقة (رقم الهاتف أو اسم المغسلة)');
      }

      final String salt = PasswordHasher.createSalt();
      final OwnerAccount updated = account.copyWith(
        passwordHash:
            PasswordHasher.hashPassword(password: newPassword, salt: salt),
        salt: salt,
      );
      await _storage.saveAccount(updated);
      await _storage.clearRememberedSession();
      _account = updated;
      _status = AuthStatus.signedOut;
      _errorMessage = null;
      return const AuthResult.success(
        'تم تحديث كلمة المرور بنجاح — سجّل الدخول بكلمة المرور الجديدة',
      );
    } catch (_) {
      return _fail('تعذّر تحديث كلمة المرور، حاول مرة أخرى');
    } finally {
      _setBusy(false);
    }
  }

  // ---------------------------------------------------------------------------
  // تسجيل الخروج
  // ---------------------------------------------------------------------------

  /// إنهاء الجلسة الحالية مع الاحتفاظ بالحساب والبيانات على الجهاز.
  Future<void> logout() async {
    try {
      await _storage.clearRememberedSession();
    } catch (_) {
      // حتى لو فشل الحفظ نُكمل الخروج في الجلسة الحالية.
    }
    _status = AuthStatus.signedOut;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // أدوات داخلية
  // ---------------------------------------------------------------------------

  AuthResult _fail(String message) {
    _errorMessage = message;
    notifyListeners();
    return AuthResult.failure(message);
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  static bool _sameShopName(String stored, String input) {
    String normalize(String value) => value
        .trim()
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
    return normalize(stored) == normalize(input);
  }

  static OwnerAccount _buildDemoAccount() {
    final String salt = PasswordHasher.createSalt();
    return OwnerAccount(
      shopName: AppConstants.demoShopName,
      ownerName: AppConstants.demoOwnerName,
      phone: AppConstants.demoOwnerPhone,
      email: AppConstants.demoOwnerEmail,
      city: AppConstants.demoOwnerCity,
      passwordHash: PasswordHasher.hashPassword(
        password: AppConstants.demoOwnerPassword,
        salt: salt,
      ),
      salt: salt,
      createdAt: DateTime.now(),
      isDemo: true,
    );
  }
}
