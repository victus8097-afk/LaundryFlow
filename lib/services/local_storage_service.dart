import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/laundry_order.dart';
import '../utils/app_constants.dart';

/// تخزين محلي دائم باستخدام `shared_preferences`.
///
/// الطلبات تُحفظ كقائمة JSON نصية، بالإضافة إلى عدّاد رقم الطلب الأخير
/// وعلامة «تم تحميل البيانات التجريبية» حتى لا تتكرر عند كل تشغيل.
class LocalStorageService {
  const LocalStorageService();

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<List<LaundryOrder>> loadOrders() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(AppConstants.storageOrdersKey);
    if (raw == null || raw.isEmpty) {
      return <LaundryOrder>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <LaundryOrder>[];
      }
      final List<LaundryOrder> orders = <LaundryOrder>[];
      for (final Object? entry in decoded) {
        if (entry is Map<String, dynamic>) {
          orders.add(LaundryOrder.fromJson(entry));
        } else if (entry is Map) {
          orders.add(LaundryOrder.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
      orders.sort((LaundryOrder a, LaundryOrder b) => a.number.compareTo(b.number));
      return orders;
    } catch (_) {
      // بيانات تالفة أو غير متوافقة: نبدأ بقائمة فارغة بدل إسقاط التطبيق.
      return <LaundryOrder>[];
    }
  }

  Future<void> saveOrders(List<LaundryOrder> orders) async {
    final SharedPreferences prefs = await _prefs();
    final String raw = jsonEncode(
      orders.map((LaundryOrder order) => order.toJson()).toList(),
    );
    await prefs.setString(AppConstants.storageOrdersKey, raw);
  }

  Future<int> loadLastOrderNumber() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getInt(AppConstants.storageCounterKey) ?? 0;
  }

  Future<void> saveLastOrderNumber(int value) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setInt(AppConstants.storageCounterKey, value);
  }

  Future<bool> hasSeededSampleData() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getBool(AppConstants.storageSeededKey) ?? false;
  }

  Future<void> markSampleDataSeeded() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setBool(AppConstants.storageSeededKey, true);
  }
}
