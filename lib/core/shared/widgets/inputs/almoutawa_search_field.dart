import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Search field — soft rounded shell aligned with [AppRadius.input].
class AlmoutawaSearchField extends StatelessWidget {
  const AlmoutawaSearchField({
    super.key,
    required this.controller,
    this.hint = 'بحث...',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final desktop = context.density.isExpanded;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.inputAll,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.06),
              blurRadius: desktop ? 6 : 8.r,
              offset: Offset(0, desktop ? 1 : 2.h),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textDirection: TextDirection.rtl,
          style: AppTypography.bodyMd().copyWith(
            fontSize: desktop ? DesktopUiTokens.body : null,
          ),
          decoration: InputDecoration(
            isDense: desktop,
            hintText: hint,
            hintStyle: AppTypography.bodyMd().copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.65),
              fontSize: desktop ? DesktopUiTokens.body : null,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.secondary,
              size: desktop ? DesktopUiTokens.iconSize + 2 : null,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: EdgeInsets.symmetric(
              horizontal: desktop ? DesktopUiTokens.gapMd : AppSpacing.md,
              vertical: desktop ? DesktopUiTokens.gapSm : AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.inputAll,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputAll,
              borderSide: BorderSide(
                color: AppColors.secondary.withValues(alpha: 0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputAll,
              borderSide: BorderSide(
                color: AppColors.secondary,
                width: desktop ? 1.5 : 1.5.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
