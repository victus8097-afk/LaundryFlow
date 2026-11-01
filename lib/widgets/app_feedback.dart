import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// عرض رسالة SnackBar موحّدة (نجاح / خطأ / معلومة).
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
}) {
  showAppSnackBarOn(
    ScaffoldMessenger.of(context),
    message,
    isError: isError,
    isSuccess: isSuccess,
  );
}

/// نسخة تعمل على [ScaffoldMessengerState] مباشرة — تُستخدم بعد العمليات
/// غير المتزامنة لتجنّب استخدام BuildContext بعد await.
void showAppSnackBarOn(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
  bool isSuccess = false,
}) {
  final IconData icon = isError
      ? Icons.error_outline_rounded
      : isSuccess
          ? Icons.check_circle_outline_rounded
          : Icons.info_outline_rounded;
  final Color background = isError
      ? AppColors.cancelled
      : isSuccess
          ? AppColors.delivered
          : AppColors.secondary;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: background,
      duration: const Duration(seconds: 3),
      content: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTheme.text(
                size: 13,
                weight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// نافذة تأكيد (تُستخدم لإلغاء الطلب وللعمليات الحساسة).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  String cancelLabel = 'تراجع',
  IconData icon = Icons.help_outline_rounded,
  bool isDestructive = false,
}) async {
  final Color accent = isDestructive ? AppColors.cancelled : AppColors.primary;
  final Color tint = isDestructive ? AppColors.cancelledTint : AppColors.primaryTint;

  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 26),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.text(
            size: 16.5,
            weight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTheme.text(
            size: 13,
            color: AppColors.textSecondary,
            height: 1.8,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
