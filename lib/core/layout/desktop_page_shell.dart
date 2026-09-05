import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/desktop_ui_tokens.dart';

/// Single-column desktop page — settings / simple hubs with max content width.
class DesktopPageShell extends StatelessWidget {
  const DesktopPageShell({
    super.key,
    required this.child,
    this.maxWidth = DesktopUiTokens.hubMaxWidth,
    this.padding = const EdgeInsets.all(DesktopUiTokens.pagePadding),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(maxWidth, constraints.maxWidth);
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: width.isFinite ? width : constraints.maxWidth,
            height: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : null,
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}

/// Dense toolbar strip for embedded desktop panes (48px).
class DesktopToolbarStrip extends StatelessWidget {
  const DesktopToolbarStrip({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DesktopUiTokens.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: DesktopUiTokens.gapMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: DesktopUiTokens.gapSm),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: DesktopUiTokens.pageTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
