import 'package:flutter/material.dart';

import '../theme/app_density.dart';
import '../theme/desktop_ui_tokens.dart';
import 'desktop_form_page_shell.dart';
import 'desktop_page_shell.dart';

/// Constrains scroll/form bodies on expanded layouts; passes through on compact.
class AdaptiveContentFrame extends StatelessWidget {
  const AdaptiveContentFrame({
    super.key,
    required this.child,
    this.mode = AdaptiveContentMode.hub,
    this.padding,
  });

  final Widget child;
  final AdaptiveContentMode mode;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (!context.density.isExpanded) return child;

    return switch (mode) {
      AdaptiveContentMode.hub => DesktopPageShell(
        maxWidth: DesktopUiTokens.hubMaxWidth,
        padding: padding ?? const EdgeInsets.all(DesktopUiTokens.pagePadding),
        child: child,
      ),
      AdaptiveContentMode.detail => DesktopPageShell(
        maxWidth: DesktopUiTokens.detailMaxWidth,
        padding: padding ?? const EdgeInsets.all(DesktopUiTokens.pagePadding),
        child: child,
      ),
      AdaptiveContentMode.form => DesktopFormPageShell(
        maxWidth: DesktopUiTokens.formMaxWidth,
        padding: padding ?? const EdgeInsets.all(DesktopUiTokens.pagePadding),
        child: child,
      ),
      AdaptiveContentMode.auth => DesktopFormPageShell(
        maxWidth: DesktopUiTokens.authFormMaxWidth,
        padding: padding ?? const EdgeInsets.all(DesktopUiTokens.pagePadding),
        child: child,
      ),
    };
  }
}

enum AdaptiveContentMode { hub, detail, form, auth }
