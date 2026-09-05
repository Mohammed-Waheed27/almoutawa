import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';

/// Branded text field — rounded soft shell ([AppRadius.input]), RTL-first.
class AlmoutawaTextField extends StatelessWidget {
  const AlmoutawaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.obscureText = false,
    this.dense = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  /// RTL-start line icon (shown on the right in Arabic layouts).
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final bool obscureText;

  /// Compact padding / type for dense operational forms (quotes, lines).
  final bool dense;

  Widget? _resolvePrefixIcon({
    required bool desktop,
    required double iconSize,
  }) {
    if (prefixIcon != null) return prefixIcon;
    if (icon == null) return null;
    return Icon(
      icon,
      size: iconSize,
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.density.isExpanded;
    final useDense = dense || desktop;
    final borderColor = AppColors.outlineVariant.withValues(alpha: 0.65);
    final labelStyle = useDense
        ? AppTypography.labelMd().copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: desktop ? DesktopUiTokens.label : null,
          )
        : AppTypography.labelBold().copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          );
    final fieldStyle = AppTypography.bodyMd().copyWith(
      fontSize: desktop ? DesktopUiTokens.body : null,
    );
    final verticalPad = useDense
        ? (maxLines > 1
              ? (desktop ? DesktopUiTokens.gapSm : AppSpacing.sm)
              : (desktop ? 6.0 : AppSpacing.xs + 2.h))
        : (maxLines > 1 ? AppSpacing.md : AppSpacing.sm + 4.h);
    final horizontalPad = useDense
        ? (desktop ? DesktopUiTokens.gapSm : AppSpacing.sm)
        : AppSpacing.md;
    final iconSize = desktop ? DesktopUiTokens.iconSize : 22.sp;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: labelStyle),
          SizedBox(height: useDense ? (desktop ? 2.0 : 2.h) : AppSpacing.xs),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            readOnly: readOnly,
            obscureText: obscureText,
            style: fieldStyle,
            decoration: InputDecoration(
              hintText: hint,
              isDense: useDense,
              prefixIcon: _resolvePrefixIcon(
                desktop: desktop,
                iconSize: iconSize,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: verticalPad,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.55),
                  width: desktop ? 1.5 : 1.5.w,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: desktop ? 1.5 : 1.5.w,
                ),
              ),
              hintStyle: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                height: 1.35,
                fontSize: useDense
                    ? (desktop ? DesktopUiTokens.body : 13.sp)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
