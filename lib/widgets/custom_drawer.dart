import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onAddOrder;
  const CustomDrawer({super.key, required this.onAddOrder});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF087F8C)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_laundry_service, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text('LaundryFlow', style: TextStyle(color: Colors.white, fontSize: 24)),
                Text('إدارة طلبات المغسلة', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('الرئيسية والطلبات'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('إضافة طلب'),
            onTap: () {
              Navigator.pop(context);
              onAddOrder();
            },
          ),
        ],
      ),
    );
  }
}
