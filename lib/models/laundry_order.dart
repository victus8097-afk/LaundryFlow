class LaundryOrder {
  final int number;
  final String customerName;
  final String phone;
  final String service;
  final int quantity;
  bool isReady;

  LaundryOrder({
    required this.number,
    required this.customerName,
    required this.phone,
    required this.service,
    required this.quantity,
    this.isReady = false,
  });

  String get status => isReady ? 'جاهز للاستلام' : 'قيد التنفيذ';
}
