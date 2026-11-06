import 'package:flutter/material.dart';
import '../models/laundry_order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final LaundryOrder order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب #${order.number}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(order.isReady ? Icons.check_circle_outline : Icons.local_laundry_service, size: 72, color: const Color(0xFF087F8C)),
          const SizedBox(height: 16),
          Text(order.status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.person_outline), title: const Text('العميل'), subtitle: Text(order.customerName)),
                ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('الهاتف'), subtitle: Text(order.phone)),
                ListTile(leading: const Icon(Icons.local_laundry_service_outlined), title: const Text('الخدمة'), subtitle: Text(order.service)),
                ListTile(leading: const Icon(Icons.checkroom), title: const Text('عدد القطع'), subtitle: Text('${order.quantity}')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!order.isReady)
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check),
              label: const Text('تحديد كجاهز للاستلام'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('الرجوع للطلبات')),
        ],
      ),
    );
  }
}
