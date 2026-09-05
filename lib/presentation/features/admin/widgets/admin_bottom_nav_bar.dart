import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/navigation/almoutawa_bottom_nav.dart';
import '../../../routes/app_routes.dart';

enum AdminShellTab { clients, workers, home, products, settings }

extension AdminShellTabX on AdminShellTab {
  int get navIndex => switch (this) {
    AdminShellTab.clients => 0,
    AdminShellTab.workers => 1,
    AdminShellTab.home => 2,
    AdminShellTab.products => 3,
    AdminShellTab.settings => 4,
  };

  String get route => switch (this) {
    AdminShellTab.clients => AppRoutes.adminCustomers,
    AdminShellTab.workers => AppRoutes.adminWorkers,
    AdminShellTab.home => AppRoutes.adminHome,
    AdminShellTab.products => AppRoutes.adminDashboard,
    AdminShellTab.settings => AppRoutes.adminSettings,
  };
}

AdminShellTab adminTabForLocation(String location) {
  if (location.startsWith(AppRoutes.adminSettings)) {
    return AdminShellTab.settings;
  }
  if (location.startsWith(AppRoutes.adminHome)) {
    return AdminShellTab.home;
  }
  if (location.startsWith(AppRoutes.adminWorkers)) {
    return AdminShellTab.workers;
  }
  if (location.startsWith(AppRoutes.adminCustomers)) {
    return AdminShellTab.clients;
  }
  return AdminShellTab.products;
}

class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    super.key,
    required this.current,
    this.onTabSelected,
  });

  final AdminShellTab current;
  final ValueChanged<AdminShellTab>? onTabSelected;

  static const centerTabIndex = 2;

  static final items = [
    AlmoutawaNavItem(
      label: 'العملاء',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    AlmoutawaNavItem(
      label: 'الموظفون',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge_rounded,
    ),
    AlmoutawaNavItem(
      label: 'الرئيسية',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    AlmoutawaNavItem(
      label: 'المنتجات',
      icon: Icons.door_sliding_outlined,
      selectedIcon: Icons.door_sliding_rounded,
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
      centerIndex: centerTabIndex,
      onSelected: (index) {
        final tab = AdminShellTab.values[index];
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
