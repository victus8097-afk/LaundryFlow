import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

/// خلفية موحّدة لشاشات المصادقة: تدرّج هوية التطبيق + دوائر زخرفية،
/// مع شريط حالة فاتح ومحتوى قابل للتمرير.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: -70,
              left: -50,
              child: _Bubble(size: 190, color: Color(0x0FFFFFFF)),
            ),
            const Positioned(
              top: 120,
              right: -60,
              child: _Bubble(size: 160, color: Color(0x0DFFFFFF)),
            ),
            const Positioned(
              bottom: -80,
              right: -30,
              child: _Bubble(size: 220, color: Color(0x0DFFFFFF)),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

/// ترويسة شاشات المصادقة: شعار التطبيق + الاسم + وصف الشاشة.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: AppShadows.raised,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(AppConstants.logoAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppConstants.appName,
                    style: AppTheme.text(
                      size: 20,
                      weight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    AppConstants.appTagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text(
                      size: 11,
                      color: const Color(0xCCFFFFFF),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.storefront_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppConstants.ownerRoleLabel,
                    style: AppTheme.text(
                      size: 10.5,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            title,
            style: AppTheme.text(
              size: 26,
              weight: FontWeight.w800,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            subtitle,
            style: AppTheme.text(
              size: 12.5,
              color: const Color(0xD9FFFFFF),
              height: 1.85,
            ),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: const Color(0x14FFFFFF), width: 1.2),
        ),
      ),
    );
  }
}
