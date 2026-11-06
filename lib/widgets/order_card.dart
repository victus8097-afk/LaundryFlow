import 'package:flutter/material.dart';
import '../models/laundry_order.dart';

class OrderCard extends StatelessWidget {
  final LaundryOrder order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(order.isReady ? Icons.check : Icons.local_laundry_service)),
        title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('طلب #${order.number} • ${order.service}\n${order.quantity} قطع • ${order.status}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
