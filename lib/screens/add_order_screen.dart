import 'package:flutter/material.dart';
import '../models/laundry_order.dart';

class AddOrderScreen extends StatefulWidget {
  final int orderNumber;
  const AddOrderScreen({super.key, required this.orderNumber});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  // مفاتيح الفورم وكنترولر لكل حقل
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _service = 'غسيل وكي';

  // السماح بالأرقام العربية والإنجليزية.
  String _normalizeDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < arabic.length; i++) {
      value = value.replaceAll(arabic[i], '$i');
    }
    return value.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // دالة حفظ الطلب بعد التحقق من صحة البيانات 
  void _saveOrder() {
    if (!_formKey.currentState!.validate()) return;
    final order = LaundryOrder(
      number: widget.orderNumber,
      customerName: _nameController.text.trim(),
      phone: _normalizeDigits(_phoneController.text),
      service: _service,
      quantity: int.parse(_normalizeDigits(_quantityController.text)),
    );
    // إرجاع الطلب إلى الرئيسية لإضافته إلى القائمة.
    Navigator.pop(context, order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة طلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_laundry_service, size: 56, color: Color(0xFF087F8C)),
              const SizedBox(height: 12),
              const Text('بيانات الطلب الجديد', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العميل', prefixIcon: Icon(Icons.person_outline)),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'أدخل اسمًا من حرفين على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'رقم الهاتف', helperText: 'من 9 إلى 15 رقمًا', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (value) {
                  if (!RegExp(r'^[0-9]{9,15}$').hasMatch(_normalizeDigits(value ?? ''))) {
                    return 'أدخل رقم هاتف صحيحًا من 9 إلى 15 رقمًا';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _service,
                decoration: const InputDecoration(labelText: 'الخدمة', prefixIcon: Icon(Icons.local_laundry_service_outlined)),
                items: const [
                  DropdownMenuItem(value: 'غسيل وكي', child: Text('غسيل وكي')),
                  DropdownMenuItem(value: 'غسيل فقط', child: Text('غسيل فقط')),
                  DropdownMenuItem(value: 'كي فقط', child: Text('كي فقط')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _service = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'عدد القطع', prefixIcon: Icon(Icons.checkroom)),
                validator: (value) {
                  final quantity = int.tryParse(_normalizeDigits(value ?? ''));
                  if (quantity == null || quantity < 1 || quantity > 100) {
                    return 'أدخل عددًا صحيحًا من 1 إلى 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveOrder,
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
