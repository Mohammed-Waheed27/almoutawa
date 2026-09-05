import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Icon button for gradient app bars — white icon on frosted well.
class AppBarHeaderIconButton extends StatelessWidget {
  const AppBarHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final size = AppLayout.iconButtonSizeOf(context);
    final iconSize = AppLayout.iconSizeOf(context);

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: AppColors.white, size: iconSize),
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        fixedSize: dense ? Size(size, size) : null,
        tapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : null,
        backgroundColor: AppColors.white.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: dense
              ? BorderRadius.circular(DesktopUiTokens.radiusMd)
              : AppRadius.mdAll,
        ),
      ),
    );
  }
}

/// Back control for secondary app bars — RTL start (right side).
class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.iconButtonSizeOf(context);
    final dense = context.density.isExpanded;

    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      tooltip: 'رجوع',
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: AppLayout.iconSizeOf(context, compactSp: 18),
      ),
      color: AppColors.white,
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        fixedSize: dense ? Size(size, size) : null,
        tapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : null,
      ),
    );
  }
}
