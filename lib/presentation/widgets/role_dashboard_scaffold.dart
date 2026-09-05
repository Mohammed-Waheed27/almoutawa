import 'package:flutter/material.dart';

import '../../core/layout/adaptive_scope.dart';
import '../../core/layout/desktop_page_shell.dart';
import '../../core/shared/widgets/backgrounds/mesh_gradient_background.dart';
import '../../core/shared/widgets/navigation/almoutawa_app_bar.dart';
import '../../core/shared/widgets/navigation/glass_app_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_density.dart';
import '../../core/theme/desktop_ui_tokens.dart';

/// Shared shell for pushed sub-pages — mesh background + secondary app bar.
class RoleDashboardScaffold extends StatelessWidget {
  const RoleDashboardScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.body,
    this.accentColor,
    this.showBackButton = true,
    this.onBack,
    this.appBarMode,
    this.appBarLeading,
    this.appBarActions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.header,
    this.contentMaxWidth,
  });

  final String? title;
  final String? subtitle;
  final Widget body;
  final Color? accentColor;
  final bool showBackButton;

  /// When set, overrides default [Navigator.maybePop] on the back control.
  final VoidCallback? onBack;
  final AlmoutawaAppBarMode? appBarMode;
  final Widget? appBarLeading;
  final List<Widget> appBarActions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? header;

  /// Optional override for expanded content width (default detail 720).
  final double? contentMaxWidth;

  AlmoutawaAppBarMode _resolveAppBarMode() {
    if (appBarMode != null) return appBarMode!;
    if (!showBackButton && title == null) return AlmoutawaAppBarMode.none;
    if (!showBackButton && subtitle != null && title == null) {
      return AlmoutawaAppBarMode.none;
    }
    return AlmoutawaAppBarMode.subpage;
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = title ?? subtitle;
    final mode = _resolveAppBarMode();
    final hasAppBar = mode != AlmoutawaAppBarMode.none;
    final dense = context.density.isExpanded;

    return Scaffold(
      backgroundColor: AppColors.transparent,
      extendBody: bottomNavigationBar != null,
      appBar: hasAppBar
          ? AlmoutawaAppBar.secondary(
              title: pageTitle,
              showBackButton: showBackButton,
              onBack: onBack,
              leading: appBarLeading,
              actions: appBarActions,
            )
          : null,
      floatingActionButton: dense ? null : floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: MeshGradientBackground(
        child: SafeArea(
          top: !hasAppBar,
          bottom: bottomNavigationBar == null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              Expanded(
                child: AdaptiveScopeHost(
                  child: dense
                      ? DesktopPageShell(
                          maxWidth:
                              contentMaxWidth ?? DesktopUiTokens.detailMaxWidth,
                          padding: EdgeInsets.zero,
                          child: body,
                        )
                      : body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
