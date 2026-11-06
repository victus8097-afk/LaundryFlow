import 'package:flutter/material.dart';
import '../models/laundry_order.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/order_card.dart';
import 'add_order_screen.dart';
import 'order_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // لست من الطلبات عشان تنعرض في الواجهة
  final List<LaundryOrder> _orders = [];


  // دالة إضافة طلب جديد
  Future<void> _addOrder() async {
    // يفتح واجهة الاضافة مع زيادة رقم الطلب بواحد من اخر طلب
    final order = await Navigator.push<LaundryOrder>(
      context,
      MaterialPageRoute(builder: (_) => AddOrderScreen(orderNumber: _orders.length + 1)),
    );
    // اذا كانت الصفحة مش موجودة أو الطلب ما كان فاضي ينهي الدالة
    if (!mounted || order == null) return;
    // اذا ما نفذ الشرط الي فوقه فينضاف ويتحدث القائمة حق الطلبات
    setState(() => _orders.add(order));
  }

  // دالة فتح تفاصيل الطلب 
  Future<void> _openDetails(LaundryOrder order) async {
    // يفتح واجهة التفاصيل 
    final isReady = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
    );
    // اذا رجع بدون ما يسوي شي او الصفحة ماكانت موجودة لأي سبب تنتهي الدالة
    if (!mounted || isReady != true) return;
    //اذا غير حالة الطلب الى جاهز تتحدث حالة العنصر وتتحدث القائمة
    setState(() => order.isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    // عدد الطلبات الي حالتها جاهزة
    final readyCount = _orders.where((order) => order.isReady).length;
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات المغسلة')),
      // هذا ودجت احنا بنيناه وعدلنا خصائصه
      drawer: CustomDrawer(onAddOrder: _addOrder),
      // زر عائم ممتد عشان نحط ايقونة ونص
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addOrder,
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
      // عشان نعرض قائمة الطلبات بشكل ديناميكي
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        // عدد العناصر
        itemCount: _orders.length + 1,
        // يبدأ ببناء العناصر من خلال الاندكس
        itemBuilder: (context, index) {
          // خلينا المعلومات الثابتة يكون الاندكس حقها صفر
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/dashboard_banner.png', height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                const Text('كل طلب، في مكانه', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('أضف الطلب وافتح تفاصيله عند الانتهاء من تجهيزه.'),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('إجمالي الطلبات: ${_orders.length}'),
                    subtitle: Text('جاهز للاستلام: $readyCount'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('قائمة الطلبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // لو كان مافي طلبات
                if (_orders.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48),
                          SizedBox(height: 12),
                          Text('لا توجد طلبات بعد', textAlign: TextAlign.center),
                          Text('اضغط «طلب جديد» لإضافة أول طلب.', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
          // هنا يعرض الطلبات ونبدأ من اندكس ناقص واحد، لانه الاندكس صفر خليناه للثابت، واللست تبدأ من الصفر
          final order = _orders[index - 1];
          //هاذي ودجت سويناها مخصصه
          return OrderCard(order: order, onTap: () => _openDetails(order));
        },
      ),
    );
  }
}
