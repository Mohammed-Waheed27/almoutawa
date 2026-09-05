import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_tab_body_animator.dart';
import '../../../../core/shared/widgets/backgrounds/mesh_gradient_background.dart';
import '../../../../core/shared/widgets/layout/almoutawa_settings_sheet.dart';
import '../../../../core/shared/widgets/navigation/role_desktop_shell.dart';
import '../../../../core/theme/app_density.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widgets/delivery_bottom_nav_bar.dart';

/// Delivery worker shell — bottom nav on compact, side rail on expanded.
class DeliveryShellPage extends StatelessWidget {
  const DeliveryShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _openSettings(BuildContext context) {
    AlmoutawaSettingsSheet.show(
      context,
      onSignOut: () =>
          context.read<AuthBloc>().add(const AuthSignOutRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentTab = deliveryTabForLocation(location);
    final dense = context.density.isExpanded;
    final tabIndex = currentTab.navIndex;

    void onTabSelected(DeliveryShellTab tab) {
      if (tab == DeliveryShellTab.settings) {
        _openSettings(context);
        return;
      }
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
                items: DeliveryBottomNavBar.items,
                selectedIndex: tabIndex,
                onSelected: (index) {
                  final tab = DeliveryShellTab.values[index];
                  onTabSelected(tab);
                },
                body: shellBody,
              )
            : shellBody,
        bottomNavigationBar: dense
            ? null
            : DeliveryBottomNavBar(
                current: currentTab,
                onSettingsTap: () => _openSettings(context),
                onTabSelected: onTabSelected,
              ),
      ),
    );
  }
}
