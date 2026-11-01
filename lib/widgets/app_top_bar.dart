import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

/// شريط علوي موحّد لكل الشاشات.
///
/// يعرض زر القائمة تلقائيًا عند وجود Drawer، وزر الرجوع عند إمكانية الرجوع
/// (Navigator.pop) دون الحاجة لتعريفه في كل شاشة.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.subtitle,
  });

  final String title;
  final List<Widget>? actions;
  final String? subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      actionsIconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text(
              size: 17,
              weight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.text(
                size: 11,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}
