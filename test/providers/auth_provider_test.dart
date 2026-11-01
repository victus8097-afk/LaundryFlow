import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/models/auth_result.dart';
import 'package:laundry_flow/models/owner_account.dart';
import 'package:laundry_flow/providers/auth_provider.dart';
import 'package:laundry_flow/services/auth_storage_service.dart';
import 'package:laundry_flow/utils/app_constants.dart';

/// تخزين وهمي في الذاكرة بدل shared_preferences لاختبار منطق المصادقة فقط.
class _FakeAuthStorage extends AuthStorageService {
  _FakeAuthStorage({this.account, this.session = false});

  OwnerAccount? account;
  bool session;

  @override
  Future<OwnerAccount?> loadAccount() async => account;

  @override
  Future<void> saveAccount(OwnerAccount value) async => account = value;

  @override
  Future<void> clearAccount() async {
    account = null;
    session = false;
  }

  @override
  Future<bool> loadRememberedSession() async => session;

  @override
  Future<void> saveRememberedSession(bool value) async => session = value;

  @override
  Future<void> clearRememberedSession() async => session = false;
}

Future<AuthProvider> _loadedProvider(_FakeAuthStorage storage) async {
  final AuthProvider provider = AuthProvider(storage: storage);
  await provider.load();
  return provider;
}

void main() {
  group('AuthProvider - التحميل والحساب التجريبي', () {
    test('ينشئ حسابًا تجريبيًا عند أول تشغيل ويبدأ غير مسجل', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider provider = await _loadedProvider(storage);

      expect(provider.status, AuthStatus.signedOut);
      expect(provider.hasAccount, isTrue);
      expect(provider.hasDemoAccount, isTrue);
      expect(storage.account?.phone, AppConstants.demoOwnerPhone);
      expect(storage.account?.shopName, AppConstants.demoShopName);
      expect(storage.session, isFalse);
    });

    test('لا يعيد إنشاء حساب جديد إذا كان محفوظًا مسبقًا', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider first = await _loadedProvider(storage);
      final OwnerAccount? stored = storage.account;

      final AuthProvider second = await _loadedProvider(storage);

      expect(second.hasAccount, isTrue);
      expect(storage.account, same(stored));
      expect(first.hasDemoAccount, isTrue);
    });

    test('يستعيد الجلسة المحفوظة عند إعادة تشغيل التطبيق', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider first = await _loadedProvider(storage);

      final AuthResult result = await first.login(
        phone: AppConstants.demoOwnerPhone,
        password: AppConstants.demoOwnerPassword,
      );
      expect(result.success, isTrue);
      expect(storage.session, isTrue);

      final AuthProvider second = await _loadedProvider(storage);
      expect(second.status, AuthStatus.signedIn);
    });

    test('يبقى غير مسجل إذا اختار المستخدم عدم «تذكرني»', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider first = await _loadedProvider(storage);

      await first.login(
        phone: AppConstants.demoOwnerPhone,
        password: AppConstants.demoOwnerPassword,
        rememberMe: false,
      );
      expect(first.isSignedIn, isTrue);
      expect(storage.session, isFalse);

      final AuthProvider second = await _loadedProvider(storage);
      expect(second.status, AuthStatus.signedOut);
    });
  });

  group('AuthProvider - تسجيل الدخول', () {
    test('يقبل الحساب التجريبي ويسجل الدخول', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: AppConstants.demoOwnerPassword,
      );

      expect(result.success, isTrue);
      expect(provider.isSignedIn, isTrue);
      expect(provider.errorMessage, isNull);
      expect(result.message, contains(AppConstants.demoOwnerName));
    });

    test('يرفض كلمة المرور الخاطئة', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: '000000',
      );

      expect(result.success, isFalse);
      expect(provider.isSignedIn, isFalse);
      expect(provider.errorMessage, 'رقم الهاتف أو كلمة المرور غير صحيحة');
    });

    test('يرفض رقم هاتف غير مسجل', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.login(
        phone: '700000000',
        password: AppConstants.demoOwnerPassword,
      );

      expect(result.success, isFalse);
      expect(provider.isSignedIn, isFalse);
    });

    test('يرفض رقم هاتف غير صالح قبل التحقق من الحساب', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.login(
        phone: '123',
        password: AppConstants.demoOwnerPassword,
      );

      expect(result.success, isFalse);
      expect(provider.errorMessage, contains('9 أرقام'));
    });

    test('يرفض كلمة مرور فارغة', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: '   ',
      );

      expect(result.success, isFalse);
      expect(provider.errorMessage, 'كلمة المرور مطلوبة');
    });
  });

  group('AuthProvider - إنشاء حساب', () {
    test('ينشئ حسابًا جديدًا ويحفظه ويسجل الدخول مباشرة', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider provider = await _loadedProvider(storage);

      final AuthResult result = await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail.com',
        city: 'عدن',
        password: '123456',
        confirmPassword: '123456',
        acceptedTerms: true,
      );

      expect(result.success, isTrue);
      expect(provider.isSignedIn, isTrue);
      expect(provider.hasDemoAccount, isFalse);
      expect(storage.account?.shopName, 'مغسلة السلام');
      expect(storage.account?.phone, '733456789');
      expect(storage.account?.city, 'عدن');
      expect(storage.session, isTrue);
      // كلمة المرور لا تُحفظ كنص صريح، لكن التحقق منها ينجح.
      expect(storage.account?.passwordHash.contains('123456'), isFalse);
      expect(storage.account?.matchesPassword('123456'), isTrue);
    });

    test('يرفض كلمتي مرور غير متطابقتين', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail.com',
        city: 'عدن',
        password: '123456',
        confirmPassword: '654321',
        acceptedTerms: true,
      );

      expect(result.success, isFalse);
      expect(result.message, 'كلمتا المرور غير متطابقتين');
      expect(provider.isSignedIn, isFalse);
    });

    test('يرفض بريدًا إلكترونيًا غير صحيح', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail',
        city: 'عدن',
        password: '123456',
        confirmPassword: '123456',
        acceptedTerms: true,
      );

      expect(result.success, isFalse);
      expect(result.message, contains('بريد'));
    });

    test('يرفض عدم الموافقة على الشروط', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail.com',
        city: 'عدن',
        password: '123456',
        confirmPassword: '123456',
        acceptedTerms: false,
      );

      expect(result.success, isFalse);
      expect(result.message, contains('الشروط'));
    });

    test('يرفض كلمة مرور قصيرة', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail.com',
        city: 'عدن',
        password: '123',
        confirmPassword: '123',
        acceptedTerms: true,
      );

      expect(result.success, isFalse);
      expect(result.message, contains('6'));
    });

    test('حساب جديد يستبدل الحساب التجريبي ويُستخدم للدخول', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider provider = await _loadedProvider(storage);

      await provider.register(
        shopName: 'مغسلة السلام',
        ownerName: 'سالم الجابري',
        phone: '733456789',
        email: 'salem@mail.com',
        city: 'تعز',
        password: 'abcdef',
        confirmPassword: 'abcdef',
        acceptedTerms: true,
      );
      await provider.logout();

      final AuthResult demoLogin = await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: AppConstants.demoOwnerPassword,
      );
      expect(demoLogin.success, isFalse);

      final AuthResult newLogin = await provider.login(
        phone: '733456789',
        password: 'abcdef',
      );
      expect(newLogin.success, isTrue);
    });
  });

  group('AuthProvider - استعادة كلمة المرور', () {
    test('تحدّث كلمة المرور بعد تطابق الهاتف واسم المغسلة', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider provider = await _loadedProvider(storage);

      final AuthResult result = await provider.resetPassword(
        phone: AppConstants.demoOwnerPhone,
        shopName: AppConstants.demoShopName,
        newPassword: 'newpass1',
        confirmPassword: 'newpass1',
      );

      expect(result.success, isTrue);
      expect(provider.isSignedIn, isFalse);
      expect(storage.account?.matchesPassword('newpass1'), isTrue);
      expect(storage.account?.matchesPassword('123456'), isFalse);

      final AuthResult login = await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: 'newpass1',
      );
      expect(login.success, isTrue);
    });

    test('يرفض اسم مغسلة غير مطابق', () async {
      final AuthProvider provider =
          await _loadedProvider(_FakeAuthStorage());

      final AuthResult result = await provider.resetPassword(
        phone: AppConstants.demoOwnerPhone,
        shopName: 'مغسلة أخرى',
        newPassword: 'newpass1',
        confirmPassword: 'newpass1',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('غير مطابقة'));
    });
  });

  group('AuthProvider - تسجيل الخروج', () {
    test('ينهي الجلسة ويحتفظ بالحساب والبيانات', () async {
      final _FakeAuthStorage storage = _FakeAuthStorage();
      final AuthProvider provider = await _loadedProvider(storage);
      await provider.login(
        phone: AppConstants.demoOwnerPhone,
        password: AppConstants.demoOwnerPassword,
      );

      await provider.logout();

      expect(provider.status, AuthStatus.signedOut);
      expect(provider.hasAccount, isTrue);
      expect(storage.account, isNotNull);
      expect(storage.session, isFalse);
    });
  });
}
