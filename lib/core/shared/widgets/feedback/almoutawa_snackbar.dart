import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Shared transient feedback — use instead of raw SnackBar in features.
///
/// Desktop: denser type, tighter margin, capped width so it does not stretch
/// across ultrawide windows.
abstract final class AlmoutawaSnackbar {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final dense = context.density.isExpanded;
    final width = MediaQuery.sizeOf(context).width;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        elevation: dense ? 2 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: dense
              ? BorderRadius.circular(DesktopUiTokens.radiusMd)
              : AppRadius.mdAll,
        ),
        // width XOR margin — Flutter forbids both on floating SnackBars.
        width: dense
            ? (width < 560 ? width - 32 : DesktopUiTokens.formMaxWidth)
            : null,
        margin: dense ? null : EdgeInsets.all(AppSpacing.containerPadding),
        padding: EdgeInsets.symmetric(
          horizontal: dense ? DesktopUiTokens.gapMd : AppSpacing.md,
          vertical: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: AppTypography.bodyOf(context).copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
