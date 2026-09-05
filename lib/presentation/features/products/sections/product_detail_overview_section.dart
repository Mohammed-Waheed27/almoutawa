import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/shared/widgets/layout/info_panel_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';

class ProductDetailOverviewSection extends StatelessWidget {
  const ProductDetailOverviewSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.images.isNotEmpty) ...[
            _ProductImagesGallery(images: product.images),
            SizedBox(height: AppSpacing.md),
          ],
          InfoPanelSection(
            title: 'البيانات الأساسية',
            rows: [
              InfoPanelRow(
                label: 'السعر',
                value: product.priceLabel,
                valueColor: product.unitPrice > 0
                    ? AppColors.onPrimaryFixedVariant
                    : AppColors.onSurfaceVariant,
                highlight: product.unitPrice > 0,
              ),
              InfoPanelRow(
                label: 'وحدة التسعير',
                value: product.pricingUnit.arabicLabel,
              ),
              InfoPanelRow(
                label: 'عدد الألوان',
                value: product.colors.isEmpty
                    ? 'لا توجد ألوان'
                    : '${product.colors.length}',
              ),
              InfoPanelRow(
                label: 'عدد الصور',
                value: product.images.isEmpty
                    ? 'لا توجد صور'
                    : '${product.images.length}',
              ),
              InfoPanelRow(
                label: 'عدد المواصفات',
                value: product.properties.isEmpty
                    ? 'لا توجد مواصفات'
                    : '${product.properties.length}',
              ),
              InfoPanelRow(
                label: 'تاريخ الإضافة',
                value: DateFormat('yyyy/MM/dd', 'ar').format(product.createdAt),
              ),
              InfoPanelRow(
                label: 'آخر تحديث',
                value: DateFormat('yyyy/MM/dd', 'ar').format(product.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImagesGallery extends StatelessWidget {
  const _ProductImagesGallery({required this.images});

  final List<ProductMediaAsset> images;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final thumb = dense ? 72.0 : 96.0;

    return AlmoutawaCard(
      variant: AlmoutawaCardVariant.solid,
      padding: EdgeInsets.all(dense ? DesktopUiTokens.gapSm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'صور المنتج',
            style: AppTypography.titleOf(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.md),
          SizedBox(
            height: thumb,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => SizedBox(
                width: dense ? DesktopUiTokens.gapXs : AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final image = images[index];
                return ClipRRect(
                  borderRadius: AppRadius.mdAll,
                  child: Image.network(
                    image.publicUrl,
                    width: thumb,
                    height: thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: thumb,
                      height: thumb,
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
      ),
    );
  }
}
