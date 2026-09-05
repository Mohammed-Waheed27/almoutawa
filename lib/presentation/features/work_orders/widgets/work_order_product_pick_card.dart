import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_catalog_card.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../domain/entities/product.dart';

/// Catalog row for quote product picking — image + اختيار / تفاصيل (no edit).
class WorkOrderProductPickCard extends StatelessWidget {
  const WorkOrderProductPickCard({
    super.key,
    required this.product,
    required this.onSelect,
    required this.onViewDetails,
  });

  final Product product;
  final VoidCallback onSelect;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final colorCount = product.colors.length;
    final imageCount = product.images.length;

    return DecorativeCatalogCard(
      tone: DecorativeCardTone.warm,
      title: product.name,
      subtitle: product.description?.trim().isNotEmpty == true
          ? product.description!.trim()
          : null,
      detail: [
        product.priceLabel,
        if (imageCount > 0) '$imageCount ${imageCount == 1 ? 'صورة' : 'صور'}',
        if (colorCount > 0) '$colorCount ${colorCount == 1 ? 'لون' : 'ألوان'}',
      ].join(' · '),
      leading: _CoverImage(product: product),
      badges: [
        DecorativeCatalogBadge(
          label: product.pricingUnit.shortLabel,
          tone: DecorativeCardTone.blue,
        ),
      ],
      footerInfo: 'اضغط البطاقة للاختيار في بند العرض',
      actions: [
        DecorativeCatalogAction(
          label: 'اختيار',
          icon: Icons.check_circle_outline_rounded,
          onPressed: onSelect,
        ),
        DecorativeCatalogAction(
          label: 'تفاصيل',
          icon: Icons.visibility_outlined,
          onPressed: onViewDetails,
        ),
      ],
      onTap: onSelect,
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final url = product.coverImageUrl;
    if (url == null) {
      return HubIconWell(
        icon: Icons.door_sliding_outlined,
        color: AppColors.warning,
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => HubIconWell(
          icon: Icons.door_sliding_outlined,
          color: AppColors.warning,
        ),
      ),
    );
  }
}
