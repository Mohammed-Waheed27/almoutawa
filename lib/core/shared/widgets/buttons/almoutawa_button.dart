import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_layout.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../surfaces/liquid_glass_surface.dart';

enum AlmoutawaButtonVariant {
  primaryGradient,
  secondaryGlass,
  tertiaryText,
  destructive,
}

enum AlmoutawaButtonSize { sm, md, lg }

/// Unified button — gradient primary, glass secondary, text tertiary.
class AlmoutawaButton extends StatelessWidget {
  const AlmoutawaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AlmoutawaButtonVariant.primaryGradient,
    this.size = AlmoutawaButtonSize.md,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AlmoutawaButtonVariant variant;
  final AlmoutawaButtonSize size;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final height = switch (size) {
      AlmoutawaButtonSize.sm => dense ? 32.0 : 40.h,
      AlmoutawaButtonSize.md =>
        dense ? DesktopUiTokens.buttonHeight : AppLayout.buttonHeight,
      AlmoutawaButtonSize.lg => dense ? 40.0 : 52.h,
    };
    final padding = switch (size) {
      AlmoutawaButtonSize.sm => EdgeInsets.symmetric(
        horizontal: dense ? 12.0 : 14.w,
        vertical: dense ? 6.0 : 8.h,
      ),
      AlmoutawaButtonSize.md => EdgeInsets.symmetric(
        horizontal: dense ? 16.0 : 20.w,
        vertical: dense ? 8.0 : 12.h,
      ),
      AlmoutawaButtonSize.lg => EdgeInsets.symmetric(
        horizontal: dense ? 18.0 : 24.w,
        vertical: dense ? 10.0 : 14.h,
      ),
    };
    final enabled = onPressed != null;
    final labelStyle = AppTypography.labelBold().copyWith(
      color: switch (variant) {
        AlmoutawaButtonVariant.primaryGradient => AppColors.onSecondary,
        AlmoutawaButtonVariant.secondaryGlass => AppColors.secondary,
        AlmoutawaButtonVariant.tertiaryText => AppColors.secondary,
        AlmoutawaButtonVariant.destructive => AppColors.onError,
      },
      fontSize: dense
          ? DesktopUiTokens.label + 1
          : (size == AlmoutawaButtonSize.sm ? 12 : 12),
    );
    final iconSize = dense
        ? DesktopUiTokens.iconSize
        : (size == AlmoutawaButtonSize.sm ? 16.sp : 20.sp);

    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.rtl,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: labelStyle.color),
          SizedBox(width: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
        ],
        Text(label, style: labelStyle),
      ],
    );

    Widget button = switch (variant) {
      AlmoutawaButtonVariant.primaryGradient => DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? AppGradients.action : null,
          color: enabled ? null : AppColors.outlineVariant,
          borderRadius: AppRadius.smAll,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.28),
                    blurRadius: dense ? 8 : 10.r,
                    offset: Offset(0, dense ? 2 : 3.h),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.smAll,
            child: Padding(padding: padding, child: content),
          ),
        ),
      ),
      AlmoutawaButtonVariant.secondaryGlass => LiquidGlassSurface(
        borderRadius: AppRadius.smAll,
        blurSigma: 8,
        tintOpacity: 0.75,
        padding: padding,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.smAll,
            child: content,
          ),
        ),
      ),
      AlmoutawaButtonVariant.tertiaryText => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: Size(expanded ? double.infinity : 0, height),
        ),
        child: content,
      ),
      AlmoutawaButtonVariant.destructive => DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? AppColors.error : AppColors.outlineVariant,
          borderRadius: AppRadius.smAll,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.smAll,
            child: Padding(padding: padding, child: content),
          ),
        ),
      ),
    };

    if (expanded && variant != AlmoutawaButtonVariant.tertiaryText) {
      button = SizedBox(width: double.infinity, height: height, child: button);
    }

    return button;
  }
}
