import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/navigation/almoutawa_bottom_nav.dart';
import '../../../routes/app_routes.dart';

enum ProductionShellTab { home, orders, settings }

extension ProductionShellTabX on ProductionShellTab {
  int get navIndex => switch (this) {
    ProductionShellTab.home => 0,
    ProductionShellTab.orders => 1,
    ProductionShellTab.settings => 2,
  };

  String get route => switch (this) {
    ProductionShellTab.home => AppRoutes.productionDashboard,
    ProductionShellTab.orders => AppRoutes.productionOrders,
    ProductionShellTab.settings => AppRoutes.productionDashboard,
  };
}

ProductionShellTab productionTabForLocation(String location) {
  if (location.startsWith(AppRoutes.productionOrders)) {
    return ProductionShellTab.orders;
  }
  return ProductionShellTab.home;
}

class ProductionBottomNavBar extends StatelessWidget {
  const ProductionBottomNavBar({
    super.key,
    required this.current,
    this.onSettingsTap,
    this.onTabSelected,
  });

  final ProductionShellTab current;
  final VoidCallback? onSettingsTap;
  final ValueChanged<ProductionShellTab>? onTabSelected;

  static final items = [
    AlmoutawaNavItem(
      label: 'الرئيسية',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    AlmoutawaNavItem(
      label: 'الطلبات',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    AlmoutawaNavItem(
      label: 'الإعدادات',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AlmoutawaBottomNav(
      items: items,
      currentIndex: current.navIndex,
      onSelected: (index) {
        final tab = ProductionShellTab.values[index];
        if (tab == ProductionShellTab.settings) {
          onSettingsTap?.call();
          return;
        }
        if (tab == current) return;

        if (onTabSelected != null) {
          onTabSelected!(tab);
          return;
        }

        context.go(tab.route);
      },
    );
  }
}
