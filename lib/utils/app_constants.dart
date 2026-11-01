import '../models/order_enums.dart';

/// ثوابت التطبيق: الهوية، مفاتيح التخزين، قواعد التحقق وجدول الأسعار.
///
/// جدول أسعار الملابس موجود هنا فقط، وأي تعديل عليه ينعكس على الطلبات
/// الجديدة دون أن يغيّر فواتير الطلبات القديمة (لأن سعر الوحدة يُحفظ داخل الطلب).
class AppConstants {
  const AppConstants._();

  // ---------------------------------------------------------------------------
  // الهوية
  // ---------------------------------------------------------------------------
  static const String appName = 'LaundryFlow';
  static const String appTagline = 'إدارة مغسلتك بكل سهولة';
  static const String appDescription =
      'نظام ذكي لتسجيل طلبات الغسيل، متابعة حالتها خطوة بخطوة، وحساب الفاتورة تلقائيًا.';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = 'ر.ي';
  static const String ownerRoleLabel = 'صاحب المغسلة';

  // ---------------------------------------------------------------------------
  // الأصول (الصور)
  // ---------------------------------------------------------------------------
  static const String logoAsset = 'assets/images/app_logo.png';
  static const String welcomeIllustrationAsset =
      'assets/images/welcome_illustration.png';
  static const String dashboardBannerAsset = 'assets/images/dashboard_banner.png';

  // ---------------------------------------------------------------------------
  // التخزين المحلي (shared_preferences)
  // ---------------------------------------------------------------------------
  static const String storageOrdersKey = 'laundryflow.orders.v1';
  static const String storageSeededKey = 'laundryflow.seeded.v1';
  static const String storageCounterKey = 'laundryflow.lastOrderNumber.v1';
  static const String storageOwnerAccountKey = 'laundryflow.ownerAccount.v1';
  static const String storageOwnerSessionKey = 'laundryflow.ownerSession.v1';

  // ---------------------------------------------------------------------------
  // حساب صاحب المغسلة (تسجيل الدخول / إنشاء الحساب)
  // ---------------------------------------------------------------------------
  static const int minShopNameLength = 2;
  static const int minOwnerNameLength = 2;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;
  static const int phoneDigits = 9;
  static const String phonePrefix = '7';

  /// المدن المتاحة عند إنشاء الحساب.
  static const List<String> cities = <String>[
    'عدن',
    'صنعاء',
    'تعز',
    'الحديدة',
    'حضرموت',
    'إب',
    'حجة',
    'المهرة',
  ];

  /// حساب تجريبي جاهز (يُنشأ عند أول تشغيل فقط) لتسهيل تجربة التطبيق.
  static const String demoShopName = 'مغسلة النور';
  static const String demoOwnerName = 'أحمد الحداد';
  static const String demoOwnerPhone = '771234567';
  static const String demoOwnerEmail = 'owner@laundryflow.app';
  static const String demoOwnerCity = 'عدن';
  static const String demoOwnerPassword = '123456';

  // ---------------------------------------------------------------------------
  // قواعد العمل
  // ---------------------------------------------------------------------------
  static const String orderNumberPrefix = 'ORD';
  static const int orderNumberPadding = 4;
  static const int defaultDeliveryDays = 2;
  static const int minCustomerNameLength = 2;
  static const int maxCustomerPhoneDigits = 9;
  static const int maxItemQuantity = 99;
  static const int recentOrdersLimit = 3;

  /// صياغة رقم الطلب المعروض: ORD-0001
  static String orderCode(int number) =>
      '$orderNumberPrefix-${number.toString().padLeft(orderNumberPadding, '0')}';

  // ---------------------------------------------------------------------------
  // جدول الأسعار التجريبي (سعر القطعة الواحدة بالريال اليمني)
  // ---------------------------------------------------------------------------
  static const Map<LaundryItemType, Map<ServiceType, int>> priceTable =
      <LaundryItemType, Map<ServiceType, int>>{
    LaundryItemType.shirt: <ServiceType, int>{
      ServiceType.washOnly: 400,
      ServiceType.ironOnly: 300,
      ServiceType.washAndIron: 600,
    },
    LaundryItemType.pants: <ServiceType, int>{
      ServiceType.washOnly: 500,
      ServiceType.ironOnly: 350,
      ServiceType.washAndIron: 700,
    },
    LaundryItemType.thobe: <ServiceType, int>{
      ServiceType.washOnly: 700,
      ServiceType.ironOnly: 500,
      ServiceType.washAndIron: 1000,
    },
    LaundryItemType.dress: <ServiceType, int>{
      ServiceType.washOnly: 800,
      ServiceType.ironOnly: 600,
      ServiceType.washAndIron: 1200,
    },
    LaundryItemType.jacket: <ServiceType, int>{
      ServiceType.washOnly: 1000,
      ServiceType.ironOnly: 800,
      ServiceType.washAndIron: 1500,
    },
    LaundryItemType.blanket: <ServiceType, int>{
      ServiceType.washOnly: 1500,
      ServiceType.ironOnly: 1000,
      ServiceType.washAndIron: 2000,
    },
  };
}
