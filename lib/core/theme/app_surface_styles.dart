import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';

/// Reusable surface decorations — cards, panels, inputs.
abstract final class AppSurfaceStyles {
  static BoxDecoration elevatedCard({BorderRadius? borderRadius}) =>
      BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? AppRadius.lgAll,
        boxShadow: AppShadows.card,
      );

  static BoxDecoration outlinedCard({BorderRadius? borderRadius}) =>
      BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: borderRadius ?? AppRadius.lgAll,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15)),
      );

  static BoxDecoration dashboardPanel({BorderRadius? borderRadius}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainer],
        ),
        borderRadius: borderRadius ?? AppRadius.lgAll,
        boxShadow: AppShadows.card,
      );

  static BoxDecoration glassPanel({BorderRadius? borderRadius}) =>
      BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: borderRadius ?? AppRadius.lgAll,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: AppShadows.primaryGlow,
      );

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: 14.h,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: AppColors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: AppColors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: AppColors.secondary, width: 1.5.w),
    ),
    labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
    hintStyle: TextStyle(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
    ),
  );
}
