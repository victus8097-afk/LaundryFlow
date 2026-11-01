import '../utils/password_hasher.dart';

/// حساب صاحب المغسلة — الحساب الوحيد الذي يدير التطبيق.
///
/// يُحفظ محليًا على الجهاز، وكلمة المرور تُخزَّن كبصمة (hash) مع ملح عشوائي
/// وليست نصًا صريحًا.
class OwnerAccount {
  const OwnerAccount({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.city,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
    this.lastLoginAt,
    this.isDemo = false,
  });

  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String city;

  /// بصمة كلمة المرور (انظر [PasswordHasher]).
  final String passwordHash;

  /// الملح العشوائي المستخدم مع البصمة.
  final String salt;

  final DateTime createdAt;
  final DateTime? lastLoginAt;

  /// هل هذا الحساب التجريبي الجاهز (يُنشأ عند أول تشغيل)؟
  final bool isDemo;

  /// أول حرف من اسم صاحب المغسلة — يُستخدم في الصورة الرمزية.
  String get ownerInitial {
    final String name = ownerName.trim();
    return name.isEmpty ? '؟' : name.substring(0, 1);
  }

  /// أول حرف من اسم المغسلة.
  String get shopInitial {
    final String shop = shopName.trim();
    return shop.isEmpty ? '؟' : shop.substring(0, 1);
  }

  /// 712345678 ← 712 345 678
  String get formattedPhone {
    if (phone.length != 9) {
      return phone;
    }
    return '${phone.substring(0, 3)} ${phone.substring(3, 6)} '
        '${phone.substring(6)}';
  }

  /// هل كلمة المرور المُدخلة تطابق البصمة المحفوظة؟
  bool matchesPassword(String password) => PasswordHasher.verifyPassword(
        password: password,
        salt: salt,
        storedHash: passwordHash,
      );

  OwnerAccount copyWith({
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? city,
    String? passwordHash,
    String? salt,
    DateTime? lastLoginAt,
    bool? isDemo,
  }) {
    return OwnerAccount(
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'city': city,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isDemo': isDemo,
    };
  }

  factory OwnerAccount.fromJson(Map<String, dynamic> json) {
    final DateTime fallback = DateTime.now();
    return OwnerAccount(
      shopName: json['shopName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      salt: json['salt'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? fallback,
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'OwnerAccount($shopName, $ownerName, $phone)';
}
