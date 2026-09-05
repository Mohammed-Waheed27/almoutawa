import 'package:flutter/material.dart';

import '../theme/app_density.dart';
import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/desktop_ui_tokens.dart';

/// Scroll clearance for tab bodies inside shells with [Scaffold.extendBody].
abstract final class ShellScrollInsets {
  /// Total bottom clearance: nav bar + device inset + breathing room.
  /// On expanded (desktop rail), no bottom-nav inset.
  static double bottom(BuildContext context) {
    if (context.density.isExpanded) {
      return DesktopUiTokens.gapLg + MediaQuery.paddingOf(context).bottom;
    }
    return AppLayout.bottomNavHeight +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.md;
  }

  /// Standard [ListView] / [CustomScrollView] padding for shell tab roots.
  static EdgeInsets tabListPadding(BuildContext context) {
    final d = context.density;
    final pad = d.isExpanded
        ? DesktopUiTokens.pagePadding
        : AppSpacing.containerPadding;
    final top = d.isExpanded ? DesktopUiTokens.gapSm : AppSpacing.sm;
    return EdgeInsets.fromLTRB(pad, top, pad, bottom(context));
  }

  /// Same as [tabListPadding] but without top inset (search/filter sits flush).
  static EdgeInsets tabListPaddingNoTop(BuildContext context) {
    final pad = context.density.isExpanded
        ? DesktopUiTokens.pagePadding
        : AppSpacing.containerPadding;
    return EdgeInsets.fromLTRB(pad, 0, pad, bottom(context));
  }
}
