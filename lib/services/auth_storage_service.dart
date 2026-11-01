import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_account.dart';
import '../utils/app_constants.dart';

/// حفظ حساب صاحب المغسلة وجلسة الدخول على الجهاز باستخدام
/// `shared_preferences` (بنفس أسلوب [LocalStorageService] الخاص بالطلبات).
class AuthStorageService {
  const AuthStorageService();

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<OwnerAccount?> loadAccount() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(AppConstants.storageOwnerAccountKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return OwnerAccount.fromJson(decoded);
      }
      if (decoded is Map) {
        return OwnerAccount.fromJson(Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (_) {
      // بيانات تالفة: نتعامل معها كأنه لا يوجد حساب بدل إسقاط التطبيق.
      return null;
    }
  }

  Future<void> saveAccount(OwnerAccount account) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(
      AppConstants.storageOwnerAccountKey,
      jsonEncode(account.toJson()),
    );
  }

  Future<void> clearAccount() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(AppConstants.storageOwnerAccountKey);
    await prefs.remove(AppConstants.storageOwnerSessionKey);
  }

  /// هل طلب المستخدم البقاء مسجلًا للدخول بعد إغلاق التطبيق؟
  Future<bool> loadRememberedSession() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getBool(AppConstants.storageOwnerSessionKey) ?? false;
  }

  Future<void> saveRememberedSession(bool value) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setBool(AppConstants.storageOwnerSessionKey, value);
  }

  Future<void> clearRememberedSession() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(AppConstants.storageOwnerSessionKey);
  }
}
