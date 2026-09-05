import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_catalog_card.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/product_form_bloc.dart';
import '../widgets/product_properties_section_skeleton.dart';
import '../widgets/product_property_assignment_card.dart';

class ProductPropertiesSection extends StatelessWidget {
  const ProductPropertiesSection({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormBloc, ProductFormState>(
      builder: (context, state) {
        final isCatalogLoading = state.isLoadingPropertyDefinitions;
        final canAddProperty =
            enabled && !isCatalogLoading && state.hasLoadedPropertyDefinitions;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      'مواصفات الباب',
                      style: AppTypography.headlineSm().copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AlmoutawaButton(
                    label: 'إضافة خاصية',
                    icon: Icons.add_rounded,
                    variant: AlmoutawaButtonVariant.tertiaryText,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: canAddProperty
                        ? () => _showAddPropertySheet(context, state)
                        : null,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              if (isCatalogLoading)
                const ProductPropertiesSectionSkeleton()
              else ...[
                if (state.properties.isEmpty)
                  const SizedBox.shrink()
                else
                  ...state.properties.map(
                    (property) => Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSpacing.stackGap,
                      ),
                      child: ProductPropertyAssignmentCard(
                        property: property,
                        catalogDefinition: property.definitionId == null
                            ? null
                            : state.propertyDefinitions
                                  .where(
                                    (item) => item.id == property.definitionId,
                                  )
                                  .firstOrNull,
                        enabled: enabled,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddPropertySheet(
    BuildContext context,
    ProductFormState state,
  ) async {
    final bloc = context.read<ProductFormBloc>();
    final addedIds = state.properties
        .map((item) => item.definitionId)
        .whereType<String>()
        .toSet();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
        final maxSheetHeight =
            MediaQuery.sizeOf(sheetContext).height * 0.85 - viewInsets.bottom;
        final availableDefinitions = state.propertyDefinitions
            .where((item) => !addedIds.contains(item.id))
            .toList(growable: false);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.containerPadding,
              AppSpacing.sm,
              AppSpacing.containerPadding,
              viewInsets.bottom + AppSpacing.sectionMargin,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اختر خاصية من القائمة',
                      style: AppTypography.headlineSm(),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    if (availableDefinitions.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          'جميع الخصائص المعرفة مضافة — أضف خاصية مخصصة أدناه.',
                          style: AppTypography.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...availableDefinitions.map(
                        (definition) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSpacing.stackGap,
                          ),
                          child: DecorativeCatalogCard(
                            tone: DecorativeCardTone.blue,
                            icon: definition.icon,
                            title: definition.nameAr,
                            subtitle: definition.nameEn,
                            badges: const [
                              DecorativeCatalogBadge(
                                label: 'إضافة',
                                tone: DecorativeCardTone.teal,
                              ),
                            ],
                            onTap: () {
                              bloc.add(
                                ProductFormPropertyAddedFromCatalog(definition),
                              );
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ),
                      ),
                    const Divider(),
                    _CustomPropertyForm(
                      onAdd: (nameAr, nameEn) {
                        bloc.add(
                          ProductFormCustomPropertyAdded(
                            nameAr: nameAr,
                            nameEn: nameEn,
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomPropertyForm extends StatefulWidget {
  const _CustomPropertyForm({required this.onAdd});

  final void Function(String nameAr, String nameEn) onAdd;

  @override
  State<_CustomPropertyForm> createState() => _CustomPropertyFormState();
}

class _CustomPropertyFormState extends State<_CustomPropertyForm> {
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('خاصية جديدة', style: AppTypography.headlineSm()),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaTextField(
          controller: _nameArController,
          label: 'اسم الخاصية (عربي)',
        ),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaTextField(
          controller: _nameEnController,
          label: 'Property name (English)',
        ),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaButton(
          label: 'إضافة خاصية مخصصة',
          icon: Icons.add_rounded,
          variant: AlmoutawaButtonVariant.primaryGradient,
          onPressed: () =>
              widget.onAdd(_nameArController.text, _nameEnController.text),
        ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
