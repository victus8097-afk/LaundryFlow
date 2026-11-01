import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

/// قائمة التنقل الجانبية (Drawer) الموحّدة لكل أقسام التطبيق.
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.currentTab,
    required this.onSelectTab,
    required this.onAddOrder,
  });

  final int currentTab;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onAddOrder;

  void _selectTab(BuildContext context, int index) {
    // إغلاق القائمة ثم الانتقال للقسم المطلوب.
    Navigator.of(context).pop();
    onSelectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(26)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DrawerHeader(provider: provider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _DrawerItem(
                      icon: Icons.dashboard_rounded,
                      label: 'لوحة التحكم',
                      selected: currentTab == 0,
                      onTap: () => _selectTab(context, 0),
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'الطلبات النشطة',
                      badge: provider.activeOrdersCount,
                      selected: currentTab == 1,
                      onTap: () => _selectTab(context, 1),
                    ),
                    _DrawerItem(
                      icon: Icons.history_rounded,
                      label: 'سجل الطلبات',
                      badge: provider.historyOrders.length,
                      selected: currentTab == 2,
                      onTap: () => _selectTab(context, 2),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, thickness: 1, color: AppColors.border),
                    ),
                    _DrawerItem(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'إضافة طلب جديد',
                      selected: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        onAddOrder();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline_rounded,
                      label: 'حول التطبيق',
                      selected: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAboutApp(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: <Widget>[
                  Divider(height: 1, thickness: 1, color: AppColors.border),
                  SizedBox(height: 12),
                  Text(
                    'LaundryFlow • الإصدار ${AppConstants.appVersion}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.provider});

  final OrdersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(AppConstants.logoAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppConstants.appName,
                      style: AppTheme.text(
                        size: 17,
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
                        color: const Color(0xD9FFFFFF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              _HeaderChip(
                icon: Icons.local_laundry_service_rounded,
                label: '${provider.activeOrdersCount} طلب نشط',
              ),
              _HeaderChip(
                icon: Icons.check_circle_rounded,
                label: '${provider.readyCount} جاهز',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTheme.text(
              size: 10.5,
              weight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.primaryDark : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppColors.primaryTint : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.text(
                      size: 13.5,
                      weight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badge',
                      style: AppTheme.text(
                        size: 10.5,
                        weight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// نافذة «حول التطبيق».
void _showAboutApp(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                AppConstants.logoAsset,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.appName,
              style: AppTheme.text(size: 17, weight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'الإصدار ${AppConstants.appVersion}',
              style: AppTheme.text(size: 10.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: AppTheme.text(
                size: 12,
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'تطبيق محلي لمغسلة واحدة: يعمل دون إنترنت أو سيرفر أو حسابات '
                'مستخدمين، وجميع البيانات محفوظة على الجهاز.',
                textAlign: TextAlign.center,
                style: AppTheme.text(
                  size: 11,
                  color: AppColors.textMuted,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      );
    },
  );
}
