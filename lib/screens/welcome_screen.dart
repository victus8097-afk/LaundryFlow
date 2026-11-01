import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

/// الشاشة الأولى: واجهة ترحيبية تعكس هوية التطبيق.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _start(BuildContext context) {
    // ننتقل إلى لوحة التحكم ونستبدل شاشة الترحيب حتى لا يعود إليها زر الرجوع.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: <Widget>[
              const _BackgroundBubbles(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const _BrandHeader(),
                                  const SizedBox(height: 26),
                                  const _IllustrationCard(),
                                  const SizedBox(height: 26),
                                  Text(
                                    'نظام إدارة مغسلة ملابس ذكي',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.text(
                                      size: 21,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'سجّل طلبات العملاء، تابع مراحل الغسيل، '
                                    'واحسب الفاتورة تلقائيًا — كل ذلك من مكان واحد.',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.text(
                                      size: 12.5,
                                      color: const Color(0xD9FFFFFF),
                                      height: 1.9,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const _FeatureChips(),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const SizedBox(height: 26),
                                  SizedBox(
                                    height: 56,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.secondary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      onPressed: () => _start(context),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'ابدأ الآن',
                                            style: AppTheme.text(
                                              size: 16,
                                              weight: FontWeight.w800,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 20,
                                            color: AppColors.secondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'الإصدار ${AppConstants.appVersion} • يعمل دون إنترنت',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.text(
                                      size: 10.5,
                                      color: const Color(0x99FFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.raised,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
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
                  size: 22,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              Text(
                AppConstants.appTagline,
                style: AppTheme.text(
                  size: 11.5,
                  color: const Color(0xCCFFFFFF),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          AppConstants.welcomeIllustrationAsset,
          width: double.infinity,
          height: 216,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips();

  static const List<({IconData icon, String label})> _features =
      <({IconData icon, String label})>[
    (icon: Icons.receipt_long_rounded, label: 'تسجيل الطلبات'),
    (icon: Icons.timeline_rounded, label: 'متابعة الحالات'),
    (icon: Icons.calculate_rounded, label: 'فواتير تلقائية'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final ({IconData icon, String label}) feature in _features)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(feature.icon, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  feature.label,
                  style: AppTheme.text(
                    size: 11,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// دوائر شفافة في الخلفية لإضافة عمق بصري.
class _BackgroundBubbles extends StatelessWidget {
  const _BackgroundBubbles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -60,
          left: -40,
          child: _bubble(size: 180, opacity: 0x14),
        ),
        Positioned(
          top: 120,
          right: -50,
          child: _bubble(size: 140, opacity: 0x10),
        ),
        Positioned(
          bottom: -70,
          right: 30,
          child: _bubble(size: 200, opacity: 0x10),
        ),
      ],
    );
  }

  Widget _bubble({required double size, required int opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(opacity << 24 | 0xFFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}
