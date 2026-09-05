import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/product_property.dart';
import '../bloc/product_form_bloc.dart';

class ProductPropertyAssignmentCard extends StatefulWidget {
  const ProductPropertyAssignmentCard({
    super.key,
    required this.property,
    required this.catalogDefinition,
    required this.enabled,
  });

  final ProductPropertyDraftEntry property;
  final ProductPropertyDefinition? catalogDefinition;
  final bool enabled;

  @override
  State<ProductPropertyAssignmentCard> createState() =>
      _ProductPropertyAssignmentCardState();
}

class _ProductPropertyAssignmentCardState
    extends State<ProductPropertyAssignmentCard> {
  final _customValueArController = TextEditingController();
  final _customValueEnController = TextEditingController();

  @override
  void dispose() {
    _customValueArController.dispose();
    _customValueEnController.dispose();
    super.dispose();
  }

  bool _isValueSelected(ProductPropertyValue value) {
    return widget.property.values.any(
      (item) =>
          item.valueId == value.id ||
          (item.valueAr == value.valueAr && item.valueEn == value.valueEn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = productPropertyIconFromKey(widget.property.iconKey);
    final catalogValues = widget.catalogDefinition?.values ?? const [];
    final selectedCount = widget.property.values.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimaryFixedVariant.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.nameAr,
                        style: AppTypography.labelBold().copyWith(
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.property.nameEn.trim().isNotEmpty)
                        Text(
                          widget.property.nameEn,
                          style: AppTypography.caption().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (selectedCount > 0)
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs),
                    child: Text(
                      '$selectedCount',
                      style: AppTypography.captionBold().copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                AlmoutawaButton(
                  label: 'إزالة',
                  icon: Icons.close_rounded,
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: widget.enabled
                      ? () => context.read<ProductFormBloc>().add(
                          ProductFormPropertyRemoved(widget.property.localId),
                        )
                      : null,
                ),
              ],
            ),
            if (catalogValues.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                textDirection: TextDirection.rtl,
                children: catalogValues.map((value) {
                  final selected = _isValueSelected(value);
                  return FilterChip(
                    label: Text(
                      value.valueEn.trim().isEmpty
                          ? value.valueAr
                          : '${value.valueAr} · ${value.valueEn}',
                      style: AppTypography.caption().copyWith(
                        color: selected
                            ? AppColors.onPrimaryFixed
                            : AppColors.onSurface,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onSelected: widget.enabled
                        ? (_) => context.read<ProductFormBloc>().add(
                            ProductFormPropertyValueToggled(
                              localId: widget.property.localId,
                              valueId: value.id,
                              valueAr: value.valueAr,
                              valueEn: value.valueEn,
                            ),
                          )
                        : null,
                    selectedColor: AppColors.secondaryFixed,
                    checkmarkColor: AppColors.onPrimaryFixed,
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: selected
                          ? AppColors.onPrimaryFixedVariant.withValues(
                              alpha: 0.35,
                            )
                          : AppColors.outlineVariant,
                    ),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: AppSpacing.sm),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _customValueArController,
                    label: 'قيمة جديدة (عربي)',
                    hint: 'مثال: عادي',
                    dense: true,
                    readOnly: !widget.enabled,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _customValueEnController,
                    label: 'Value (EN)',
                    hint: 'Normal',
                    dense: true,
                    readOnly: !widget.enabled,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: AlmoutawaButton(
                label: 'إضافة القيمة',
                icon: Icons.add_rounded,
                variant: AlmoutawaButtonVariant.tertiaryText,
                size: AlmoutawaButtonSize.sm,
                expanded: false,
                onPressed: widget.enabled
                    ? () {
                        context.read<ProductFormBloc>().add(
                          ProductFormPropertyCustomValueAdded(
                            localId: widget.property.localId,
                            valueAr: _customValueArController.text,
                            valueEn: _customValueEnController.text,
                          ),
                        );
                        _customValueArController.clear();
                        _customValueEnController.clear();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
