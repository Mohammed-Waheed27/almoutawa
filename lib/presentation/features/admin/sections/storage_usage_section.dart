import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/storage_quota.dart';

class StorageUsageSection extends StatelessWidget {
  const StorageUsageSection({
    super.key,
    required this.quota,
    this.isLoading = false,
    this.onRefresh,
  });

  final StorageQuota? quota;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: dense
              ? BorderRadius.circular(DesktopUiTokens.radiusMd)
              : AppRadius.lgAll,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            dense ? DesktopUiTokens.gapSm : AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    color: AppColors.secondaryContainer,
                    size: dense ? DesktopUiTokens.iconSize : 24,
                  ),
                  SizedBox(
                    width: dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
                  ),
                  Expanded(
                    child: Text(
                      'مساحة التخزين',
                      style: AppTypography.titleOf(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (onRefresh != null)
                    AlmoutawaButton(
                      label: 'تحديث',
                      icon: Icons.refresh_rounded,
                      variant: AlmoutawaButtonVariant.tertiaryText,
                      size: AlmoutawaButtonSize.sm,
                      expanded: false,
                      onPressed: isLoading ? null : onRefresh,
                    ),
                ],
              ),
              SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
              if (isLoading && quota == null)
                LinearProgressIndicator(minHeight: dense ? 4 : 6)
              else if (quota != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: quota!.usedRatio,
                    minHeight: dense ? 5 : 8,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    color: AppColors.secondaryContainer,
                  ),
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.sm),
                Text(
                  'المستخدم: ${StorageQuota.formatBytes(quota!.usedBytes)}',
                  style: AppTypography.bodyOf(context),
                ),
                Text(
                  'المتبقي: ${StorageQuota.formatBytes(quota!.remainingBytes)} '
                  'من ${StorageQuota.formatBytes(quota!.quotaBytes)}',
                  style: AppTypography.bodyOf(
                    context,
                  ).copyWith(color: AppColors.onSurfaceVariant),
                ),
                SizedBox(height: dense ? 2 : AppSpacing.xs),
                Text(
                  'حد كل صورة: ${StorageQuota.formatBytes(quota!.maxFileBytes)} · '
                  'صور المنتج: ${quota!.maxProductImages} · '
                  'صور اللون: ${quota!.maxColorImages}',
                  style: AppTypography.labelOf(
                    context,
                  ).copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
