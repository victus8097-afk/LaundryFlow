import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const LaundryFlowApp());
}

/// نقطة انطلاق تطبيق LaundryFlow.
///
/// التطبيق عربي بالكامل (RTL)، يعمل محليًا دون سيرفر، ويستخدم:
/// - [AuthProvider]: حساب صاحب المغسلة (تسجيل الدخول / إنشاء الحساب).
/// - [OrdersProvider]: مصدر وحيد لبيانات الطلبات.
class LaundryFlowApp extends StatelessWidget {
  const LaundryFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (BuildContext context) => AuthProvider()..load(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (BuildContext context) => OrdersProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (BuildContext context, Widget? child) {
          // فرض اتجاه RTL على كامل التطبيق.
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const WelcomeScreen(),
      ),
    );
  }
}
