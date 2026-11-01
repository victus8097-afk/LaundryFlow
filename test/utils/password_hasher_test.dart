import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/utils/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('الملح عشوائي بطول 32 حرفًا hex', () {
      final String first = PasswordHasher.createSalt();
      final String second = PasswordHasher.createSalt();

      expect(first.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(first), isTrue);
      expect(first, isNot(second));
    });

    test('نفس كلمة المرور والملح تعطيان نفس البصمة', () {
      const String salt = '0123456789abcdef0123456789abcdef';
      final String first =
          PasswordHasher.hashPassword(password: '123456', salt: salt);
      final String second =
          PasswordHasher.hashPassword(password: '123456', salt: salt);

      expect(first, second);
      expect(first, startsWith('v1\$'));
      expect(first.length, 35);
    });

    test('الملح المختلف يعطي بصمة مختلفة لنفس كلمة المرور', () {
      final String first = PasswordHasher.hashPassword(
        password: '123456',
        salt: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );
      final String second = PasswordHasher.hashPassword(
        password: '123456',
        salt: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );

      expect(first, isNot(second));
    });

    test('البصمة لا تحتوي كلمة المرور الأصلية', () {
      final String hash = PasswordHasher.hashPassword(
        password: 'MySecret123',
        salt: PasswordHasher.createSalt(),
      );

      expect(hash.contains('MySecret123'), isFalse);
    });

    test('التحقق ينجح مع كلمة المرور الصحيحة ويفشل مع غيرها', () {
      final String salt = PasswordHasher.createSalt();
      final String hash =
          PasswordHasher.hashPassword(password: '123456', salt: salt);

      expect(
        PasswordHasher.verifyPassword(
          password: '123456',
          salt: salt,
          storedHash: hash,
        ),
        isTrue,
      );
      expect(
        PasswordHasher.verifyPassword(
          password: '654321',
          salt: salt,
          storedHash: hash,
        ),
        isFalse,
      );
    });
  });
}
