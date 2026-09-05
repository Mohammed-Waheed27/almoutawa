import 'package:flutter/material.dart';

import '../theme/desktop_ui_tokens.dart';

/// Centered form column for add/edit routes on expanded layouts.
class DesktopFormPageShell extends StatelessWidget {
  const DesktopFormPageShell({
    super.key,
    required this.child,
    this.maxWidth = DesktopUiTokens.formMaxWidth,
    this.padding = const EdgeInsets.all(DesktopUiTokens.pagePadding),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Two related fields side-by-side on desktop forms.
class DesktopFormFieldRow extends StatelessWidget {
  const DesktopFormFieldRow({
    super.key,
    required this.first,
    required this.second,
    this.gap = DesktopUiTokens.gapMd,
  });

  final Widget first;
  final Widget second;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          SizedBox(width: gap),
          Expanded(child: second),
        ],
      ),
    );
  }
}
