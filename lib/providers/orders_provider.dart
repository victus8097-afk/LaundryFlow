import 'package:flutter/foundation.dart';

import '../models/laundry_order.dart';
import '../models/order_enums.dart';
import '../models/order_item.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data.dart';
import '../utils/app_constants.dart';

/// حالة التطبيق المركزية: مصدر واحد للطلبات والإحصائيات.
///
/// كل الشاشات تقرأ من هنا وتُحدِّث عبره، لذلك تبقى البيانات متسقة
/// وتتحدث لوحة التحكم تلقائيًا بعد أي عملية.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider({LocalStorageService? storage})
      : _storage = storage ?? const LocalStorageService();

  final LocalStorageService _storage;
  final List<LaundryOrder> _orders = <LaundryOrder>[];

  bool _isLoading = true;
  int _lastOrderNumber = 0;

  bool get isLoading => _isLoading;
  List<LaundryOrder> get orders => List<LaundryOrder>.unmodifiable(_orders);
  int get lastOrderNumber => _lastOrderNumber;

  // ---------------------------------------------------------------------------
  // قراءة البيانات وتحميلها
  // ---------------------------------------------------------------------------

  /// تحميل الطلبات من التخزين المحلي، مع إضافة البيانات التجريبية أول مرة فقط.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<LaundryOrder> storedOrders = await _storage.loadOrders();
      final bool hasSeeded = await _storage.hasSeededSampleData();
      _orders.clear();

      if (!hasSeeded && storedOrders.isEmpty) {
        final List<LaundryOrder> samples = SampleData.build();
        _orders.addAll(samples);
        _lastOrderNumber = _maxOrderNumber(samples);
        await _storage.saveOrders(_orders);
        await _storage.saveLastOrderNumber(_lastOrderNumber);
        await _storage.markSampleDataSeeded();
      } else {
        _orders.addAll(storedOrders);
        final int storedCounter = await _storage.loadLastOrderNumber();
        final int highestNumber = _maxOrderNumber(storedOrders);
        _lastOrderNumber =
            storedCounter > highestNumber ? storedCounter : highestNumber;
        if (!hasSeeded) {
          // المستخدم بدأ بقائمة فارغة سابقًا — لا نضيف بيانات تجريبية.
          await _storage.markSampleDataSeeded();
        }
      }
    } catch (_) {
      _orders.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static int _maxOrderNumber(Iterable<LaundryOrder> orders) {
    int max = 0;
    for (final LaundryOrder order in orders) {
      if (order.number > max) {
        max = order.number;
      }
    }
    return max;
  }

  // ---------------------------------------------------------------------------
  // قوائم وإحصائيات محسوبة من البيانات الحقيقية
  // ---------------------------------------------------------------------------

  /// الطلبات النشطة مرتبة من الأحدث إلى الأقدم.
  List<LaundryOrder> get activeOrders {
    final List<LaundryOrder> list =
        _orders.where((LaundryOrder order) => order.status.isActive).toList();
    list.sort(_compareNewestFirst);
    return List<LaundryOrder>.unmodifiable(list);
  }

  /// سجل الطلبات (المسلّمة والملغاة) مرتبًا حسب آخر تحديث.
  List<LaundryOrder> get historyOrders {
    final List<LaundryOrder> list =
        _orders.where((LaundryOrder order) => order.status.isFinished).toList();
    list.sort((LaundryOrder a, LaundryOrder b) {
      final int byActivity = b.lastActivityAt.compareTo(a.lastActivityAt);
      return byActivity != 0 ? byActivity : b.number.compareTo(a.number);
    });
    return List<LaundryOrder>.unmodifiable(list);
  }

  /// أحدث الطلبات النشطة لعرضها في لوحة التحكم.
  List<LaundryOrder> get recentOrders =>
      activeOrders.take(AppConstants.recentOrdersLimit).toList(growable: false);

  int get totalOrdersCount => _orders.length;

  int get activeOrdersCount =>
      _orders.where((LaundryOrder order) => order.status.isActive).length;

  int get inProgressCount => _orders
      .where((LaundryOrder order) =>
          order.status == OrderStatus.washing ||
          order.status == OrderStatus.preparing)
      .length;

  int get readyCount =>
      _orders.where((LaundryOrder order) => order.status == OrderStatus.ready).length;

  int get deliveredCount => _orders
      .where((LaundryOrder order) => order.status == OrderStatus.delivered)
      .length;

  int get cancelledCount => _orders
      .where((LaundryOrder order) => order.status == OrderStatus.cancelled)
      .length;

  /// إجمالي قيمة الطلبات المسلّمة فقط (الملغاة لا تُحتسب).
  int get deliveredRevenue {
    int total = 0;
    for (final LaundryOrder order in _orders) {
      if (order.status == OrderStatus.delivered) {
        total += order.total;
      }
    }
    return total;
  }

  /// قيمة الطلبات النشطة (قيد التنفيذ) — معلومات مساعدة في لوحة التحكم.
  int get activeValue {
    int total = 0;
    for (final LaundryOrder order in _orders) {
      if (order.status.isActive) {
        total += order.total;
      }
    }
    return total;
  }

  /// عدد قطع الملابس داخل المغسلة حاليًا.
  int get activePieces {
    int total = 0;
    for (final LaundryOrder order in _orders) {
      if (order.status.isActive) {
        total += order.totalPieces;
      }
    }
    return total;
  }

  LaundryOrder? orderByNumber(int number) {
    for (final LaundryOrder order in _orders) {
      if (order.number == number) {
        return order;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // عمليات على الطلبات
  // ---------------------------------------------------------------------------

  /// إنشاء طلب جديد برقم فريد وحالة «تم الاستلام».
  Future<LaundryOrder> createOrder({
    required String customerName,
    required String customerPhone,
    required DateTime receivedAt,
    required DateTime dueAt,
    required List<OrderItem> items,
    String notes = '',
  }) async {
    final int number = _lastOrderNumber + 1;
    final LaundryOrder order = LaundryOrder.create(
      number: number,
      customerName: customerName,
      customerPhone: customerPhone,
      receivedAt: receivedAt,
      dueAt: dueAt,
      items: items,
      notes: notes,
      status: OrderStatus.received,
      createdAt: DateTime.now(),
    );
    _lastOrderNumber = number;
    _orders.add(order);
    notifyListeners();
    await _persist();
    return order;
  }

  /// تحديث طلب موجود (يُرفض إذا كان الطلب منتهيًا).
  Future<bool> updateOrder(LaundryOrder updated) async {
    final int index =
        _orders.indexWhere((LaundryOrder order) => order.number == updated.number);
    if (index < 0 || !_orders[index].isEditable) {
      return false;
    }
    _orders[index] = updated;
    notifyListeners();
    await _persist();
    return true;
  }

  /// الانتقال إلى الحالة التالية فقط (بدون تخطي المراحل).
  ///
  /// المرحلة الأخيرة («تم التسليم») لا تُنفَّذ من هنا، بل عبر
  /// [confirmDelivery] حتى تكون هناك خطوة صريحة لتأكيد استلام العميل.
  Future<OrderStatus?> advanceStatus(LaundryOrder order) async {
    final LaundryOrder? current = orderByNumber(order.number);
    if (current == null || current.status == OrderStatus.ready) {
      return null;
    }
    final OrderStatus? next = current.status.next;
    if (next == null) {
      return null;
    }
    return _applyStatus(current, next);
  }

  /// تأكيد تسليم الطلب — متاح فقط عندما يكون الطلب «جاهز للاستلام».
  Future<bool> confirmDelivery(LaundryOrder order) async {
    final LaundryOrder? current = orderByNumber(order.number);
    if (current == null || current.status != OrderStatus.ready) {
      return false;
    }
    final OrderStatus? result = await _applyStatus(current, OrderStatus.delivered);
    return result == OrderStatus.delivered;
  }

  /// إلغاء الطلب — متاح للطلبات النشطة فقط.
  Future<bool> cancelOrder(LaundryOrder order) async {
    final LaundryOrder? current = orderByNumber(order.number);
    if (current == null || !current.status.isActive) {
      return false;
    }
    final OrderStatus? result = await _applyStatus(current, OrderStatus.cancelled);
    return result == OrderStatus.cancelled;
  }

  Future<OrderStatus?> _applyStatus(
    LaundryOrder order,
    OrderStatus target,
  ) async {
    if (!order.status.canMoveTo(target)) {
      return null;
    }
    final int index =
        _orders.indexWhere((LaundryOrder item) => item.number == order.number);
    if (index < 0) {
      return null;
    }
    final DateTime now = DateTime.now();
    final LaundryOrder updated = order.copyWith(
      status: target,
      deliveredAt: target == OrderStatus.delivered ? now : null,
      cancelledAt: target == OrderStatus.cancelled ? now : null,
    );
    _orders[index] = updated;
    notifyListeners();
    await _persist();
    return target;
  }

  Future<void> _persist() async {
    try {
      await _storage.saveOrders(_orders);
      await _storage.saveLastOrderNumber(_lastOrderNumber);
    } catch (_) {
      // فشل الحفظ لا يمنع استخدام التطبيق في الجلسة الحالية.
    }
  }

  static int _compareNewestFirst(LaundryOrder a, LaundryOrder b) {
    final int byCreated = b.createdAt.compareTo(a.createdAt);
    return byCreated != 0 ? byCreated : b.number.compareTo(a.number);
  }
}
