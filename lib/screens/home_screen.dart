import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/laundry_order.dart';
import '../providers/orders_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_card.dart';
import '../widgets/section_card.dart';
import '../widgets/summary_card.dart';
import 'add_order_screen.dart';
import 'history_screen.dart';
import 'order_details_screen.dart';
import 'orders_screen.dart';

/// الشاشة الثانية: لوحة التحكم الرئيسية.
///
/// تستضيف ثلاثة أقسام مترابطة (لوحة التحكم، الطلبات، السجل) مع Drawer
/// للتنقل بينها، وزر واضح لإضافة طلب جديد.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  static const List<String> _titles = <String>[
    'لوحة التحكم',
    'الطلبات النشطة',
    'سجل الطلبات',
  ];

  void _selectTab(int index) {
    if (index == _tabIndex) {
      return;
    }
    setState(() => _tabIndex = index);
  }

  Future<void> _openAddOrder() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const AddOrderScreen(),
      ),
    );
  }

  Future<void> _openOrderDetails(int orderNumber) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            OrderDetailsScreen(orderNumber: orderNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppTopBar(
        title: _titles[_tabIndex],
        subtitle: '${provider.activeOrdersCount} طلب نشط داخل المغسلة',
        actions: <Widget>[
          IconButton(
            onPressed: _openAddOrder,
            tooltip: 'إضافة طلب جديد',
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      drawer: CustomDrawer(
        currentTab: _tabIndex,
        onSelectTab: _selectTab,
        onAddOrder: _openAddOrder,
      ),
      floatingActionButton: _tabIndex == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddOrder,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text('طلب جديد'),
            ),
      body: provider.isLoading
          ? const _LoadingView()
          : IndexedStack(
              index: _tabIndex,
              sizing: StackFit.expand,
              children: <Widget>[
                _DashboardView(
                  onOpenOrders: () => _selectTab(1),
                  onOpenHistory: () => _selectTab(2),
                  onAddOrder: _openAddOrder,
                  onOpenOrder: _openOrderDetails,
                ),
                OrdersScreen(
                  onAddOrder: _openAddOrder,
                  onOpenOrder: _openOrderDetails,
                ),
                HistoryScreen(onOpenOrder: _openOrderDetails),
              ],
            ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          Text(
            'جارٍ تحميل طلبات المغسلة...',
            style: AppTheme.text(
              size: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// محتوى لوحة التحكم
// -----------------------------------------------------------------------------

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.onOpenOrders,
    required this.onOpenHistory,
    required this.onAddOrder,
    required this.onOpenOrder,
  });

  final VoidCallback onOpenOrders;
  final VoidCallback onOpenHistory;
  final VoidCallback onAddOrder;
  final ValueChanged<int> onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final OrdersProvider provider = context.watch<OrdersProvider>();
    final List<LaundryOrder> recent = provider.recentOrders;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        4,
        AppSpacing.page,
        120,
      ),
      children: <Widget>[
        _DashboardHero(provider: provider),
        const SizedBox(height: AppSpacing.section),
        const SectionHeader(title: 'نظرة سريعة', icon: Icons.insights_rounded),
        const SizedBox(height: AppSpacing.gap),
        _StatsGrid(provider: provider),
        const SizedBox(height: AppSpacing.gap),
        _RevenueCard(provider: provider),
        const SizedBox(height: AppSpacing.section),
        const SectionHeader(title: 'اختصارات سريعة', icon: Icons.bolt_rounded),
        const SizedBox(height: AppSpacing.gap),
        _QuickActions(
          provider: provider,
          onOpenOrders: onOpenOrders,
          onOpenHistory: onOpenHistory,
        ),
        const SizedBox(height: AppSpacing.section),
        SectionHeader(
          title: 'أحدث الطلبات',
          icon: Icons.receipt_long_rounded,
          action: TextButton(
            onPressed: onOpenOrders,
            child: const Text('عرض الكل'),
          ),
        ),
        const SizedBox(height: AppSpacing.gapSmall),
        if (recent.isEmpty)
          SizedBox(
            height: 300,
            child: EmptyState(
              title: 'لا توجد طلبات نشطة',
              message: 'أضف أول طلب غسيل ليظهر هنا مع إحصائيات المغسلة.',
              icon: Icons.local_laundry_service_rounded,
              actionLabel: 'إضافة طلب جديد',
              onAction: onAddOrder,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: recent.length,
            itemBuilder: (BuildContext context, int index) {
              final LaundryOrder order = recent[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  order: order,
                  onTap: () => onOpenOrder(order.number),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.provider});

  final OrdersProvider provider;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        // passthrough حتى يأخذ المحتوى عرض البطاقة الكامل داخل القوائم
        fit: StackFit.passthrough,
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              AppConstants.dashboardBannerAsset,
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[Color(0xF20B3A48), Color(0xCC0E7C86)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'أهلاً بك 👋',
                  style: AppTheme.text(
                    size: 11.5,
                    color: const Color(0xD9FFFFFF),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppConstants.appTagline,
                  style: AppTheme.text(
                    size: 19,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${AppFormatters.weekday(now)} • ${AppFormatters.date(now)}',
                  style: AppTheme.text(
                    size: 10.5,
                    color: const Color(0xBFFFFFFF),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    _HeroChip(
                      icon: Icons.local_laundry_service_rounded,
                      label: '${provider.activeOrdersCount} طلب نشط',
                    ),
                    _HeroChip(
                      icon: Icons.checkroom_rounded,
                      label: '${provider.activePieces} قطعة',
                    ),
                    _HeroChip(
                      icon: Icons.payments_rounded,
                      label: AppFormatters.currency(provider.activeValue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(30),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.provider});

  final OrdersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SummaryCard(
                  title: 'إجمالي الطلبات',
                  value: '${provider.totalOrdersCount}',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'قيد التنفيذ',
                  value: '${provider.inProgressCount}',
                  icon: Icons.local_laundry_service_rounded,
                  color: AppColors.washing,
                  tint: AppColors.washingTint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SummaryCard(
                  title: 'جاهزة للاستلام',
                  value: '${provider.readyCount}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.ready,
                  tint: AppColors.readyTint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'مكتملة (مسلّمة)',
                  value: '${provider.deliveredCount}',
                  icon: Icons.verified_rounded,
                  color: AppColors.delivered,
                  tint: AppColors.deliveredTint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.provider});

  final OrdersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'إجمالي قيمة الطلبات المكتملة',
                  style: AppTheme.text(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppFormatters.currency(provider.deliveredRevenue),
              style: AppTheme.text(
                size: 26,
                weight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'من ${provider.deliveredCount} طلب مسلَّم • الطلبات الملغاة لا تُحتسب ضمن الإيرادات',
            style: AppTheme.text(
              size: 10,
              color: const Color(0xE6FFFFFF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.provider,
    required this.onOpenOrders,
    required this.onOpenHistory,
  });

  final OrdersProvider provider;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _QuickActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'الطلبات النشطة',
              subtitle: '${provider.activeOrdersCount} طلب',
              color: AppColors.primary,
              tint: AppColors.primaryTint,
              onTap: onOpenOrders,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.history_rounded,
              title: 'سجل الطلبات',
              subtitle: '${provider.historyOrders.length} طلب',
              color: AppColors.secondary,
              tint: AppColors.secondaryTint,
              onTap: onOpenHistory,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(
                    size: 13,
                    weight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.text(
                    size: 10.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
