/// أنواع الملابس التي يستقبلها المغسل.
///
/// كل نوع له اسم عربي [label] ونوع خدمة يمكن اختياره لاحقًا.
enum LaundryItemType {
  shirt('قميص'),
  pants('بنطلون'),
  thobe('ثوب'),
  dress('فستان'),
  jacket('جاكيت'),
  blanket('بطانية');

  const LaundryItemType(this.label);

  final String label;

  static LaundryItemType fromName(String? name) {
    for (final LaundryItemType type in LaundryItemType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return LaundryItemType.shirt;
  }
}

/// أنواع الخدمات المتاحة مع وصف قصير لكل خدمة.
enum ServiceType {
  washOnly('غسيل فقط', 'تنظيف بالماء والمنظفات'),
  ironOnly('كي فقط', 'كي وتعطير الملابس'),
  washAndIron('غسيل وكي', 'غسيل كامل ثم كي وتعطير');

  const ServiceType(this.label, this.description);

  final String label;
  final String description;

  static ServiceType fromName(String? name) {
    for (final ServiceType type in ServiceType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return ServiceType.washOnly;
  }
}

/// حالات الطلب بالترتيب المنطقي لدورة العمل.
///
/// المسار الطبيعي: تم الاستلام ← قيد الغسيل ← قيد التجهيز ← جاهز للاستلام ← تم التسليم.
/// «ملغى» حالة نهائية خارج المسار ولا تُحتسب ضمن الإيرادات.
enum OrderStatus {
  received('تم الاستلام'),
  washing('قيد الغسيل'),
  preparing('قيد التجهيز'),
  ready('جاهز للاستلام'),
  delivered('تم التسليم'),
  cancelled('ملغى');

  const OrderStatus(this.label);

  final String label;

  /// خطوات المسار الطبيعي (بدون حالات الإلغاء).
  static const List<OrderStatus> flow = <OrderStatus>[
    OrderStatus.received,
    OrderStatus.washing,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.delivered,
  ];

  static OrderStatus fromName(String? name) {
    for (final OrderStatus status in OrderStatus.values) {
      if (status.name == name) {
        return status;
      }
    }
    return OrderStatus.received;
  }

  /// الطلب ما زال داخل المغسلة (لم يُسلّم ولم يُلغَ).
  bool get isActive => this != OrderStatus.delivered && this != OrderStatus.cancelled;

  /// حالة نهائية: للقراءة فقط ولا يمكن تعديل الطلب بعدها.
  bool get isFinished => !isActive;

  /// موقع الحالة داخل المسار الطبيعي (0 لأول خطوة، -1 للإلغاء).
  int get flowIndex => flow.indexOf(this);

  /// رقم المرحلة المعروض للمستخدم (1..5)، و0 للإلغاء.
  int get stepNumber => flowIndex + 1;

  /// الحالة التالية في المسار، أو null عند نهاية المسار/الإلغاء.
  OrderStatus? get next {
    if (!isActive) {
      return null;
    }
    final int index = flowIndex;
    if (index < 0 || index >= flow.length - 1) {
      return null;
    }
    return flow[index + 1];
  }

  /// هل يمكن الانتقال إلى [target] بخطوة واحدة فقط دون تخطي المراحل؟
  bool canMoveTo(OrderStatus target) {
    if (!isActive) {
      return false;
    }
    if (target == OrderStatus.cancelled) {
      return true;
    }
    return next == target;
  }
}
