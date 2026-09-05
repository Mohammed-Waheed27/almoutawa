import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_catalog_card.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../domain/entities/product.dart';

class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorCount = product.colors.length;
    final imageCount = product.images.length;
    final propertyCount = product.propertyCount;

    final badges = <DecorativeCatalogBadge>[
      DecorativeCatalogBadge(
        label: product.pricingUnit.shortLabel,
        tone: DecorativeCardTone.blue,
      ),
      if (colorCount > 0)
        DecorativeCatalogBadge(
          label: '$colorCount ${colorCount == 1 ? 'لون' : 'ألوان'}',
          tone: DecorativeCardTone.teal,
        ),
      if (propertyCount > 0)
        DecorativeCatalogBadge(
          label: '$propertyCount ${propertyCount == 1 ? 'خاصية' : 'خصائص'}',
          tone: DecorativeCardTone.green,
        ),
    ];

    final actions = <DecorativeCatalogAction>[
      if (onEdit != null || onTap != null)
        DecorativeCatalogAction(
          label: 'تعديل',
          icon: Icons.edit_outlined,
          onPressed: onEdit ?? onTap,
        ),
      if (onDelete != null)
        DecorativeCatalogAction(
          label: 'حذف',
          icon: Icons.delete_outline_rounded,
          onPressed: onDelete,
          destructive: true,
        ),
    ];

    final footerParts = <String>[
      product.priceLabel,
      if (imageCount > 0) '$imageCount ${imageCount == 1 ? 'صورة' : 'صور'}',
    ];

    return DecorativeCatalogCard(
      tone: DecorativeCardTone.warm,
      title: product.name,
      subtitle: product.description?.trim().isNotEmpty == true
          ? product.description!.trim()
          : null,
      detail: footerParts.join(' · '),
      leading: _CoverImage(product: product),
      badges: badges,
      footerInfo: 'تعريف المنتج — يُستخدم في عروض الأسعار وأوامر التصنيع',
      actions: actions,
      onTap: onTap,
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
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => HubIconWell(
          icon: Icons.door_sliding_outlined,
          color: AppColors.warning,
        ),
      ),
    );
  }
}
