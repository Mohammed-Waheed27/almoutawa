import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_property.dart';

class ProductDetailPropertiesSection extends StatelessWidget {
  const ProductDetailPropertiesSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.properties.isEmpty) {
      return const EmptyStateWidget(
        message: 'لا توجد مواصفات مرتبطة بهذا المنتج',
        icon: Icons.tune_outlined,
      );
    }

    final dense = context.density.isExpanded;
    final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.stackGap;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          for (final assignment in product.properties) ...[
            ProductDetailPropertyCard(assignment: assignment, dense: dense),
            SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}

class ProductDetailPropertyCard extends StatelessWidget {
  const ProductDetailPropertyCard({
    super.key,
    required this.assignment,
    this.dense = false,
  });

  final ProductPropertyAssignment assignment;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final icon = productPropertyIconFromKey(assignment.definition.iconKey);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dense)
              Icon(
                icon,
                size: DesktopUiTokens.iconSize,
                color: DecorativeCardTone.blue.accent,
              )
            else
              HubIconWell(icon: icon, color: DecorativeCardTone.blue.accent),
            SizedBox(width: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.definition.nameAr,
                    style: AppTypography.titleOf(context).copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: dense ? 2 : AppSpacing.xs),
                  Text(
                    assignment.definition.nameEn,
                    style: AppTypography.bodyOf(
                      context,
                    ).copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (assignment.values.isEmpty) ...[
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          Text(
            'لا توجد قيم محددة',
            style: AppTypography.bodyOf(
              context,
            ).copyWith(color: AppColors.onSurfaceVariant),
          ),
        ] else ...[
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          Wrap(
            spacing: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
            runSpacing: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
            textDirection: TextDirection.rtl,
            children: assignment.values.map((value) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: dense ? DesktopUiTokens.gapSm : AppSpacing.md,
                  vertical: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.secondaryFixed.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  dense ? value.valueAr : '${value.valueAr} · ${value.valueEn}',
                  style: AppTypography.labelOf(context).copyWith(
                    color: AppColors.onPrimaryFixed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );

    if (dense) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesktopUiTokens.gapSm),
          child: body,
        ),
      );
    }

    return DecorativeCardShell(tone: DecorativeCardTone.blue, child: body);
  }
}
