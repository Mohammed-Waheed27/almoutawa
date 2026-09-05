import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/factory_profile.dart';

/// Compact factory tiles — short names, up to 2 lines (no dropdown overflow).
class WorkOrderFactoryPickerSection extends StatelessWidget {
  const WorkOrderFactoryPickerSection({
    super.key,
    required this.factories,
    required this.selectedFactoryId,
    required this.onSelected,
  });

  final List<FactoryProfile> factories;
  final String? selectedFactoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر المصنع',
            style: AppTypography.titleSm(),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: AppSpacing.sm),
          if (factories.isEmpty)
            Text(
              'لا توجد مصانع مفعّلة',
              style: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            )
          else
            Wrap(
              textDirection: TextDirection.rtl,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final factory in factories)
                  _FactoryChip(
                    factory: factory,
                    selected: factory.id == selectedFactoryId,
                    onTap: () => onSelected(factory.id),
                    width: factories.length <= 2
                        ? (MediaQuery.sizeOf(context).width -
                                  AppSpacing.containerPadding * 2 -
                                  AppSpacing.sm) /
                              2
                        : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FactoryChip extends StatelessWidget {
  const _FactoryChip({
    required this.factory,
    required this.selected,
    required this.onTap,
    this.width,
  });

  final FactoryProfile factory;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.secondaryFixed
          : AppColors.surfaceContainerLow,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 64, minWidth: 120),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: selected
                  ? AppColors.onPrimaryFixed.withValues(alpha: 0.35)
                  : AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(
                selected ? Icons.factory_rounded : Icons.factory_outlined,
                size: 20,
                color: selected
                    ? AppColors.onPrimaryFixed
                    : AppColors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factory.displayName,
                      style: AppTypography.labelBold().copyWith(
                        color: selected
                            ? AppColors.onPrimaryFixed
                            : AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    if (factory.isDefault)
                      Text(
                        'افتراضي',
                        style: AppTypography.caption().copyWith(
                          color: selected
                              ? AppColors.onPrimaryFixed.withValues(alpha: 0.8)
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
