import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_flow/utils/app_theme.dart';
import 'package:laundry_flow/widgets/auth_form_card.dart';

void main() {
  testWidgets('زر المصادقة يعرض التحميل ويُعطَّل أثناء تنفيذ العملية', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AuthSubmitButton(
            label: 'تسجيل الدخول',
            loading: false,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AuthSubmitButton(
            label: 'تسجيل الدخول',
            loading: true,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('شريط الخطأ يعرض رسالة المصادقة', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AuthErrorBanner(
            message: 'رقم الهاتف أو كلمة المرور غير صحيحة',
          ),
        ),
      ),
    );

    expect(find.text('رقم الهاتف أو كلمة المرور غير صحيحة'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('بطاقة النموذج تعرض العنوان والوصف والمحتوى', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AuthFormCard(
            icon: Icons.lock_open_rounded,
            title: 'دخول صاحب المغسلة',
            subtitle: 'رقم الهاتف وكلمة المرور',
            child: Text('حقول النموذج'),
          ),
        ),
      ),
    );

    expect(find.text('دخول صاحب المغسلة'), findsOneWidget);
    expect(find.text('رقم الهاتف وكلمة المرور'), findsOneWidget);
    expect(find.text('حقول النموذج'), findsOneWidget);
  });
}
