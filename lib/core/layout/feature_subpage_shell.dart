import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/desktop_ui_tokens.dart';
import 'desktop_page_shell.dart';

/// Secondary full-page desktop layout — fixed toolbar + constrained scroll body.
class FeatureSubpageShell extends StatelessWidget {
  const FeatureSubpageShell({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.leading,
    this.maxWidth = DesktopUiTokens.detailMaxWidth,
    this.footer,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;
  final double maxWidth;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopToolbarStrip(
          title: title,
          leading: leading,
          actions: actions,
        ),
        Expanded(
          child: DesktopPageShell(
            maxWidth: maxWidth,
            child: body,
          ),
        ),
        if (footer != null)
          Material(
            color: AppColors.surfaceContainerLowest,
            elevation: 2,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
                child: footer,
              ),
            ),
          ),
      ],
    );
  }
}
