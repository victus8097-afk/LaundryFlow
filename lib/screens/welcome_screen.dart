import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          //عشان نقدر نعمل سكرول لو كانت الشاشة صغيرة
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.local_laundry_service, size: 44, color: Color(0xFF087F8C)),
                const SizedBox(height: 12),
                const Text('LaundryFlow', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const Text('مغسلتك مرتّبة، بخطوات بسيطة'),
                const SizedBox(height: 24),
                // عشان نسوي حواف ناعمة للصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/images/welcome_illustration.png', height: 240, fit: BoxFit.contain),
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('أهلًا بك في مغسلتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('أضف طلبات العملاء وتابع تجهيز ملابسهم من مكان واحد.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // زر بتصميم ممتلئ بداخله ايقونة
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('ابدأ إدارة الطلبات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
