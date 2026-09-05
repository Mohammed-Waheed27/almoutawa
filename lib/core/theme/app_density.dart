import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import 'desktop_ui_tokens.dart';

/// Viewport density — compact (phone) vs expanded (laptop / Windows / web ≥1024).
@immutable
class AppDensity {
  const AppDensity({
    required this.width,
    required this.isExpanded,
  });

  factory AppDensity.fromWidth(double width) {
    return AppDensity(
      width: width,
      isExpanded: AppBreakpoints.isExpanded(width),
    );
  }

  final double width;
  final bool isExpanded;

  bool get isCompact => !isExpanded;

  double get bodyFontSize =>
      isExpanded ? DesktopUiTokens.body : 16;
  double get labelFontSize =>
      isExpanded ? DesktopUiTokens.label : 12;
  double get pageTitleFontSize =>
      isExpanded ? DesktopUiTokens.pageTitle : 20;

  double get buttonHeight =>
      isExpanded ? DesktopUiTokens.buttonHeight : 48;
  double get inputHeight =>
      isExpanded ? DesktopUiTokens.inputHeight : 52;
  double get iconSize =>
      isExpanded ? DesktopUiTokens.iconSize : 22;

  double get pagePadding =>
      isExpanded ? DesktopUiTokens.pagePadding : 16;
  double get gapSm => isExpanded ? DesktopUiTokens.gapSm : 8;
  double get gapMd => isExpanded ? DesktopUiTokens.gapMd : 12;
  double get gapLg => isExpanded ? DesktopUiTokens.gapLg : 16;

  double get radiusMd =>
      isExpanded ? DesktopUiTokens.radiusMd : 12;
  double get radiusLg =>
      isExpanded ? DesktopUiTokens.radiusLg : 16;

  double get formMaxWidth => DesktopUiTokens.formMaxWidth;
  double get detailMaxWidth => DesktopUiTokens.detailMaxWidth;
  double get hubMaxWidth => DesktopUiTokens.hubMaxWidth;
  double get sidebarWidth => DesktopUiTokens.masterSidebarWidth;
}

/// Provides [AppDensity] to descendants. Prefer [context.density] over raw width.
class AppDensityScope extends InheritedWidget {
  const AppDensityScope({
    super.key,
    required this.density,
    required super.child,
  });

  final AppDensity density;

  static AppDensity of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDensityScope>();
    assert(scope != null, 'AppDensityScope not found in widget tree');
    return scope!.density;
  }

  static AppDensity? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppDensityScope>()?.density;
  }

  @override
  bool updateShouldNotify(AppDensityScope oldWidget) =>
      oldWidget.density.width != density.width ||
      oldWidget.density.isExpanded != density.isExpanded;
}

/// Wraps [child] with [AppDensityScope] from current [MediaQuery] width.
class AppDensityScopeHost extends StatelessWidget {
  const AppDensityScopeHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AppDensityScope(
      density: AppDensity.fromWidth(width),
      child: child,
    );
  }
}

extension AppDensityContext on BuildContext {
  AppDensity get density =>
      AppDensityScope.maybeOf(this) ??
      AppDensity.fromWidth(MediaQuery.sizeOf(this).width);
}
