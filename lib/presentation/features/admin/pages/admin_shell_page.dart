import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_tab_body_animator.dart';
import '../../../../core/shared/widgets/backgrounds/mesh_gradient_background.dart';
import '../../../../core/shared/widgets/navigation/role_desktop_shell.dart';
import '../../../../core/theme/app_density.dart';
import '../widgets/admin_bottom_nav_bar.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentTab = adminTabForLocation(location);
    final dense = context.density.isExpanded;
    final tabIndex = currentTab.navIndex;

    void onTabSelected(AdminShellTab tab) {
      navigationShell.goBranch(
        tab.navIndex,
        initialLocation: tab.navIndex == navigationShell.currentIndex,
      );
    }

    final shellBody = SafeArea(
      top: false,
      bottom: false,
      child: dense
          ? DesktopTabBodyAnimator(tabIndex: tabIndex, child: navigationShell)
          : navigationShell,
    );

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: !dense,
        body: dense
            ? RoleDesktopShell(
                items: AdminBottomNavBar.items,
                selectedIndex: tabIndex,
                centerIndex: AdminBottomNavBar.centerTabIndex,
                onSelected: (index) {
                  final tab = AdminShellTab.values[index];
                  if (tab == currentTab) return;
                  onTabSelected(tab);
                },
                body: shellBody,
              )
            : shellBody,
        bottomNavigationBar: dense
            ? null
            : AdminBottomNavBar(
                current: currentTab,
                onTabSelected: onTabSelected,
              ),
      ),
    );
  }
}
