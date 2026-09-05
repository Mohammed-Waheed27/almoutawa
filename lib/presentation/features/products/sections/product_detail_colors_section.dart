import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_shell.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';

class ProductDetailColorsSection extends StatelessWidget {
  const ProductDetailColorsSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.colors.isEmpty) {
      return const EmptyStateWidget(
        message: 'لا توجد ألوان مضافة لهذا المنتج',
        icon: Icons.palette_outlined,
      );
    }

    final dense = context.density.isExpanded;
    final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.stackGap;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          for (final color in product.colors) ...[
            _ColorCard(color: color, dense: dense),
            SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  const _ColorCard({required this.color, required this.dense});

  final ProductColor color;
  final bool dense;

  Color? get _swatchColor {
    final hex = color.hexCode;
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    final swatch = _swatchColor;
    final coverUrl = color.images.isNotEmpty
        ? color.images.first.publicUrl
        : color.colorImageUrl;
    final thumb = dense ? 36.0 : 48.0;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coverUrl != null)
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: Image.network(
                  coverUrl,
                  width: thumb,
                  height: thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _Swatch(swatch: swatch, size: thumb),
                ),
              )
            else
              _Swatch(swatch: swatch, size: thumb),
            SizedBox(width: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    color.name,
                    style: AppTypography.titleOf(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (color.hexCode?.isNotEmpty == true) ...[
                    SizedBox(height: dense ? 2 : AppSpacing.xs),
                    Text(
                      color.hexCode!,
                      style: AppTypography.labelOf(
                        context,
                      ).copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                  if (color.images.isNotEmpty) ...[
                    SizedBox(height: dense ? 2 : AppSpacing.xs),
                    Text(
                      '${color.images.length} ${color.images.length == 1 ? 'صورة' : 'صور'}',
                      style: AppTypography.labelOf(
                        context,
                      ).copyWith(color: AppColors.onPrimaryFixedVariant),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (color.images.length > 1) ...[
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          SizedBox(
            height: dense ? 56 : 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: color.images.length,
              separatorBuilder: (context, index) => SizedBox(
                width: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final image = color.images[index];
                final size = dense ? 56.0 : 72.0;
                return ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: Image.network(
                    image.publicUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: size,
                      height: size,
                      color: AppColors.surfaceContainer,
                      child: HubIconWell(
                        icon: Icons.broken_image_outlined,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                );
              },
            ),
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

    return DecorativeCardShell(tone: DecorativeCardTone.teal, child: body);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({this.swatch, this.size = 48});

  final Color? swatch;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (swatch != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: swatch,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.outlineVariant),
        ),
      );
    }

    return HubIconWell(
      icon: Icons.palette_outlined,
      color: DecorativeCardTone.teal.accent,
    );
  }
}
