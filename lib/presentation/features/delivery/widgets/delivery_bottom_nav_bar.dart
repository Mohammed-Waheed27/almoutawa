import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/navigation/almoutawa_bottom_nav.dart';
import '../../../routes/app_routes.dart';

enum DeliveryShellTab { home, clients, orders, settings }

extension DeliveryShellTabX on DeliveryShellTab {
  int get navIndex => switch (this) {
    DeliveryShellTab.home => 0,
    DeliveryShellTab.clients => 1,
    DeliveryShellTab.orders => 2,
    DeliveryShellTab.settings => 3,
  };

  String get route => switch (this) {
    DeliveryShellTab.home => AppRoutes.deliveryDashboard,
    DeliveryShellTab.clients => AppRoutes.deliveryCustomers,
    DeliveryShellTab.orders => AppRoutes.deliveryOrders,
    DeliveryShellTab.settings => AppRoutes.deliveryDashboard,
  };
}

DeliveryShellTab deliveryTabForLocation(String location) {
  if (location.startsWith(AppRoutes.deliveryCustomers)) {
    return DeliveryShellTab.clients;
  }
  if (location.startsWith(AppRoutes.deliveryOrders)) {
    return DeliveryShellTab.orders;
  }
  return DeliveryShellTab.home;
}

class DeliveryBottomNavBar extends StatelessWidget {
  const DeliveryBottomNavBar({
    super.key,
    required this.current,
    this.onSettingsTap,
    this.onTabSelected,
  });

  final DeliveryShellTab current;
  final VoidCallback? onSettingsTap;
  final ValueChanged<DeliveryShellTab>? onTabSelected;

  static final items = [
    AlmoutawaNavItem(
      label: 'الرئيسية',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    AlmoutawaNavItem(
      label: 'العملاء',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
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
        final tab = DeliveryShellTab.values[index];
        if (tab == DeliveryShellTab.settings) {
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
