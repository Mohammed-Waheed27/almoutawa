import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_density.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/desktop_ui_tokens.dart';
import '../layout/almoutawa_adaptive_sheet.dart';

class AlmoutawaFilterOption<T> {
  const AlmoutawaFilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Compact inline filter control — type + value in one chip, no external label.
///
/// On expanded, prefer [fullWidth] so sidebar filters stretch and open a dialog
/// (via [AlmoutawaAdaptiveSheet]) instead of a phone bottom sheet.
class AlmoutawaFilterDropdown<T> extends StatelessWidget {
  const AlmoutawaFilterDropdown({
    super.key,
    required this.typeLabel,
    required this.value,
    required this.options,
    required this.onChanged,
    this.compact = true,
    this.fullWidth = false,
  });

  /// Shown inside the chip, e.g. "المرحلة".
  final String typeLabel;
  final T value;
  final List<AlmoutawaFilterOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool compact;

  /// Stretch to parent width (desktop filter sidebars).
  final bool fullWidth;

  String get _selectedLabel {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return options.isEmpty ? '—' : options.first.label;
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final isDefault = options.isNotEmpty && options.first.value == value;
    final radius = dense && fullWidth
        ? BorderRadius.circular(DesktopUiTokens.radiusMd)
        : BorderRadius.circular(AppRadius.full);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => _openMenu(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: fullWidth ? double.infinity : null,
            constraints: dense && fullWidth
                ? const BoxConstraints(
                    minHeight: DesktopUiTokens.inputHeight,
                  )
                : null,
            padding: EdgeInsetsDirectional.only(
              start: dense ? DesktopUiTokens.gapMd : AppSpacing.sm,
              end: dense ? DesktopUiTokens.gapSm : AppSpacing.xs,
              top: dense && fullWidth ? DesktopUiTokens.gapSm : 6,
              bottom: dense && fullWidth ? DesktopUiTokens.gapSm : 6,
            ),
            decoration: BoxDecoration(
              color: isDefault
                  ? AppColors.surfaceContainerLow
                  : AppColors.secondaryFixed,
              borderRadius: radius,
              border: Border.all(
                color: isDefault
                    ? AppColors.outlineVariant.withValues(alpha: 0.7)
                    : AppColors.primaryFixedDim.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (fullWidth)
                  Expanded(
                    child: Text(
                      '$typeLabel: $_selectedLabel',
                      style: AppTypography.labelOf(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDefault
                            ? AppColors.onPrimaryFixedVariant
                            : AppColors.onPrimaryFixed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(
                    '$typeLabel: $_selectedLabel',
                    style: AppTypography.labelOf(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDefault
                          ? AppColors.onPrimaryFixedVariant
                          : AppColors.onPrimaryFixed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: dense ? DesktopUiTokens.iconSize : 16,
                  color: isDefault
                      ? AppColors.onSurfaceVariant
                      : AppColors.onPrimaryFixed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final selected = await AlmoutawaAdaptiveSheet.show<T>(
      context: context,
      title: typeLabel,
      builder: (sheetContext) {
        final dense = sheetContext.density.isExpanded;
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
            dense ? DesktopUiTokens.gapSm : AppSpacing.containerPadding,
            dense ? 0 : AppSpacing.xs,
            dense ? DesktopUiTokens.gapSm : AppSpacing.containerPadding,
            AppSpacing.md,
          ),
          children: [
            if (!dense) ...[
              Text(
                typeLabel,
                style: AppTypography.titleOf(sheetContext),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            for (final option in options)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
                selected: option.value == value,
                selectedTileColor: AppColors.secondaryFixed.withValues(
                  alpha: 0.55,
                ),
                title: Text(
                  option.label,
                  textAlign: TextAlign.right,
                  style: AppTypography.bodyOf(sheetContext).copyWith(
                    fontWeight: option.value == value
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: option.value == value
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.onPrimaryFixedVariant,
                        size: dense ? DesktopUiTokens.iconSize : 20,
                      )
                    : null,
                onTap: () => Navigator.pop(sheetContext, option.value),
              ),
          ],
        );
      },
    );
    if (selected == null || selected == value) return;
    onChanged(selected);
  }
}
