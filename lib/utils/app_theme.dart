import 'package:flutter/material.dart';

import '../models/order_enums.dart';

/// ألوان الهوية البصرية لتطبيق LaundryFlow.
class AppColors {
  const AppColors._();

  // الأساسي: أزرق هادئ مائل للتركواز، والثانوي: كحلي داكن.
  static const Color primary = Color(0xFF0E7C86);
  static const Color primaryDark = Color(0xFF0A5B63);
  static const Color primaryLight = Color(0xFF3FA9B2);
  static const Color primaryTint = Color(0xFFE3F2F3);

  static const Color secondary = Color(0xFF102A43);
  static const Color secondaryLight = Color(0xFF274B66);
  static const Color secondaryTint = Color(0xFFE8EEF4);

  static const Color background = Color(0xFFF4F8F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7FAFB);
  static const Color border = Color(0xFFE2EAEE);

  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF5F7688);
  static const Color textMuted = Color(0xFF93A6B4);

  // ألوان حالات الطلب
  static const Color received = Color(0xFF2F74E8);
  static const Color receivedTint = Color(0xFFE7EFFC);
  static const Color washing = Color(0xFFE1813A);
  static const Color washingTint = Color(0xFFFCEFE3);
  static const Color preparing = Color(0xFF7B54D6);
  static const Color preparingTint = Color(0xFFF0EAFB);
  static const Color ready = Color(0xFF2E9E6B);
  static const Color readyTint = Color(0xFFE4F5EC);
  static const Color delivered = Color(0xFF1B6B4A);
  static const Color deliveredTint = Color(0xFFE1F0E8);
  static const Color cancelled = Color(0xFFD0504C);
  static const Color cancelledTint = Color(0xFFFBE9E8);
  static const Color warning = Color(0xFFD79A2B);
  static const Color warningTint = Color(0xFFFDF3DF);

  // ظلال ناعمة
  static const Color shadowSoft = Color(0x12102A43);
  static const Color shadowMedium = Color(0x1F102A43);

  static const LinearGradient heroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFF0C3B4A), Color(0xFF0E7C86)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: <Color>[Color(0xFF0E7C86), Color(0xFF3FA9B2)],
  );
}

/// مسافات موحّدة تُستخدم في كل الشاشات.
class AppSpacing {
  const AppSpacing._();

  static const double page = 18;
  static const double section = 22;
  static const double card = 16;
  static const double gap = 12;
  static const double gapSmall = 8;
  static const double gapLarge = 28;
}

/// أنصاف أقطار الحواف الموحّدة.
class AppRadius {
  const AppRadius._();

  static const double card = 20;
  static const double field = 14;
  static const double button = 16;
  static const double chip = 30;
}

/// ظلال البطاقات.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(color: AppColors.shadowMedium, blurRadius: 26, offset: Offset(0, 12)),
  ];
}

/// ثيم التطبيق (Material 3 + خط Cairo + دعم RTL).
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Cairo';

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryTint,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryTint,
    onSecondaryContainer: AppColors.secondary,
    tertiary: AppColors.primaryLight,
    onTertiary: Colors.white,
    error: AppColors.cancelled,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceMuted,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  static TextStyle text({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1.5,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: text(size: 30, weight: FontWeight.w800, height: 1.25),
      headlineMedium: text(size: 24, weight: FontWeight.w800, height: 1.3),
      headlineSmall: text(size: 20, weight: FontWeight.w700, height: 1.35),
      titleLarge: text(size: 18, weight: FontWeight.w700),
      titleMedium: text(size: 16, weight: FontWeight.w600),
      titleSmall: text(size: 14, weight: FontWeight.w600),
      bodyLarge: text(size: 15, height: 1.6),
      bodyMedium: text(size: 13.5, height: 1.6),
      bodySmall: text(size: 12, height: 1.55, color: AppColors.textSecondary),
      labelLarge: text(size: 15, weight: FontWeight.w700),
      labelMedium: text(size: 12.5, weight: FontWeight.w600),
      labelSmall: text(size: 11, weight: FontWeight.w600),
    );
  }

  static ThemeData get light {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      dividerColor: AppColors.border,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text(size: 15, weight: FontWeight.w700, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text(size: 15, weight: FontWeight.w700, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.border, width: 1.4),
          textStyle: text(size: 14.5, weight: FontWeight.w700, color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: text(size: 14, weight: FontWeight.w700, color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        extendedTextStyle: text(size: 14.5, weight: FontWeight.w700, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondary,
        contentTextStyle: text(size: 13.5, weight: FontWeight.w600, color: Colors.white),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x660F2A43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.textPrimary,
        titleTextStyle: text(size: 14.5, weight: FontWeight.w600),
        subtitleTextStyle: text(size: 12, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      tooltipTheme: TooltipThemeData(
        textStyle: text(size: 12, color: Colors.white),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// تنسيق موحّد لكل حقول الإدخال.
  ///
  /// يُستخدم عبر [InputDecoration] مباشرة بدل `InputDecorationTheme`
  /// لضمان تطابق الشكل على جميع إصدارات Flutter.
  static InputDecoration fieldDecoration({
    String? label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? helper,
  }) {
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: const BorderSide(color: AppColors.border, width: 1.3),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      helperStyle: text(size: 11.5, color: AppColors.textMuted, height: 1.4),
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
      prefixIconColor: AppColors.primary,
      suffixIcon: suffixIcon,
      suffixIconColor: AppColors.textSecondary,
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: text(size: 13.5, color: AppColors.textSecondary),
      floatingLabelStyle: text(
        size: 13,
        weight: FontWeight.w600,
        color: AppColors.primary,
      ),
      hintStyle: text(size: 13.5, color: AppColors.textMuted),
      errorStyle: text(size: 11.5, color: AppColors.cancelled, height: 1.4),
      counterStyle: text(size: 11, color: AppColors.textMuted),
      border: baseBorder,
      enabledBorder: baseBorder,
      disabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.7),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.cancelled, width: 1.3),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.cancelled, width: 1.7),
      ),
    );
  }
}

/// أيقونات أنواع الملابس (Material Icons).
extension LaundryItemTypeStyle on LaundryItemType {
  IconData get icon {
    switch (this) {
      case LaundryItemType.shirt:
        return Icons.checkroom_rounded;
      case LaundryItemType.pants:
        return Icons.dry_cleaning_rounded;
      case LaundryItemType.thobe:
        return Icons.man_rounded;
      case LaundryItemType.dress:
        return Icons.woman_rounded;
      case LaundryItemType.jacket:
        return Icons.checkroom_outlined;
      case LaundryItemType.blanket:
        return Icons.bed_rounded;
    }
  }
}

/// أيقونات أنواع الخدمة.
extension ServiceTypeStyle on ServiceType {
  IconData get icon {
    switch (this) {
      case ServiceType.washOnly:
        return Icons.local_laundry_service_rounded;
      case ServiceType.ironOnly:
        return Icons.iron_rounded;
      case ServiceType.washAndIron:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// ألوان وأيقونات حالات الطلب.
extension OrderStatusStyle on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.received:
        return AppColors.received;
      case OrderStatus.washing:
        return AppColors.washing;
      case OrderStatus.preparing:
        return AppColors.preparing;
      case OrderStatus.ready:
        return AppColors.ready;
      case OrderStatus.delivered:
        return AppColors.delivered;
      case OrderStatus.cancelled:
        return AppColors.cancelled;
    }
  }

  Color get background {
    switch (this) {
      case OrderStatus.received:
        return AppColors.receivedTint;
      case OrderStatus.washing:
        return AppColors.washingTint;
      case OrderStatus.preparing:
        return AppColors.preparingTint;
      case OrderStatus.ready:
        return AppColors.readyTint;
      case OrderStatus.delivered:
        return AppColors.deliveredTint;
      case OrderStatus.cancelled:
        return AppColors.cancelledTint;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.received:
        return Icons.inventory_2_rounded;
      case OrderStatus.washing:
        return Icons.local_laundry_service_rounded;
      case OrderStatus.preparing:
        return Icons.iron_rounded;
      case OrderStatus.ready:
        return Icons.check_circle_rounded;
      case OrderStatus.delivered:
        return Icons.verified_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}
