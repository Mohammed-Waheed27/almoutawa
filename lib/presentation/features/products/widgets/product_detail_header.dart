import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../domain/entities/product.dart';

class ProductDetailHeader extends StatelessWidget {
  const ProductDetailHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorCount = product.colors.length;
    final imageCount = product.images.length;
    final propertyCount = product.propertyCount;
    final subtitle = product.description?.trim().isNotEmpty == true
        ? product.description!.trim()
        : 'لا يوجد وصف للمنتج';

    if (context.density.isExpanded) {
      return DesktopEntityHeaderStrip(
        title: product.name,
        subtitle: subtitle,
        badge: product.pricingUnit.shortLabel,
        icon: Icons.door_sliding_outlined,
        metrics: [
          DesktopEntityMetric(label: 'السعر', value: product.priceLabel),
          DesktopEntityMetric(
            label: 'الألوان',
            value: colorCount == 0 ? '—' : '$colorCount',
          ),
          DesktopEntityMetric(
            label: 'الصور',
            value: imageCount == 0 ? '—' : '$imageCount',
          ),
          DesktopEntityMetric(
            label: 'المواصفات',
            value: propertyCount == 0 ? '—' : '$propertyCount',
          ),
        ],
      );
    }

    return DecorativeSummaryCard(
      tone: DecorativeCardTone.warm,
      title: product.name,
      subtitle: subtitle,
      icon: Icons.door_sliding_outlined,
      badge: product.pricingUnit.shortLabel,
      metrics: [
        DecorativeSummaryMetric(
          label: 'السعر',
          value: product.priceLabel,
          valueColor: product.unitPrice > 0
              ? AppColors.onPrimaryFixedVariant
              : AppColors.onSurfaceVariant,
        ),
        DecorativeSummaryMetric(
          label: 'الألوان',
          value: colorCount == 0 ? '—' : '$colorCount',
        ),
        DecorativeSummaryMetric(
          label: 'الصور',
          value: imageCount == 0 ? '—' : '$imageCount',
        ),
        DecorativeSummaryMetric(
          label: 'المواصفات',
          value: propertyCount == 0 ? '—' : '$propertyCount',
        ),
      ],
    );
  }
}
