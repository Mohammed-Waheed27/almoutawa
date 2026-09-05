import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_catalog_card.dart';
import '../../../../domain/entities/product_property.dart';

class PropertyDefinitionListCard extends StatelessWidget {
  const PropertyDefinitionListCard({
    super.key,
    required this.definition,
    required this.onTap,
  });

  final ProductPropertyDefinition definition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final valueCount = definition.values.length;

    return DecorativeCatalogCard(
      tone: DecorativeCardTone.blue,
      icon: definition.icon,
      title: definition.nameAr,
      subtitle: definition.nameEn,
      detail: '$valueCount ${valueCount == 1 ? 'قيمة' : 'قيم'}',
      badges: const [
        DecorativeCatalogBadge(label: 'مواصفة', tone: DecorativeCardTone.teal),
      ],
      onTap: onTap,
    );
  }
}
