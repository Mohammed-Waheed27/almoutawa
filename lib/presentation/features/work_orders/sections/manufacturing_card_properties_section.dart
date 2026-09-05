import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/media/media_picker_helper.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/manufacturing_card.dart';
import '../../../../domain/entities/product_property.dart';
import '../bloc/manufacturing_card_form_bloc.dart';
import '../widgets/mfg_card_section_header.dart';

/// Specs editor: catalog/value pick first, then full manual control.
class ManufacturingCardPropertiesSection extends StatefulWidget {
  const ManufacturingCardPropertiesSection({super.key, required this.enabled});

  final bool enabled;

  @override
  State<ManufacturingCardPropertiesSection> createState() =>
      _ManufacturingCardPropertiesSectionState();
}

class _ManufacturingCardPropertiesSectionState
    extends State<ManufacturingCardPropertiesSection> {
  /// 0 = اختيار من الكتالوج, 1 = إدخال يدوي
  var _addMode = 0;
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _valueArController = TextEditingController();
  final _valueEnController = TextEditingController();

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _valueArController.dispose();
    _valueEnController.dispose();
    super.dispose();
  }

  void _addManual(BuildContext context) {
    final nameAr = _nameArController.text.trim();
    final valueAr = _valueArController.text.trim();
    if (nameAr.isEmpty || valueAr.isEmpty) return;

    final bloc = context.read<ManufacturingCardFormBloc>();
    bloc.add(
      ManufacturingCardFormPropertyAdded(
        ManufacturingCardPropertyDraft(
          nameAr: nameAr,
          nameEn: _nameEnController.text.trim().isEmpty
              ? null
              : _nameEnController.text.trim(),
          valueAr: valueAr,
          valueEn: _valueEnController.text.trim().isEmpty
              ? null
              : _valueEnController.text.trim(),
          sortOrder: bloc.state.properties.length,
        ),
      ),
    );

    _nameArController.clear();
    _nameEnController.clear();
    _valueArController.clear();
    _valueEnController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManufacturingCardFormBloc, ManufacturingCardFormState>(
      buildWhen: (p, c) =>
          p.properties != c.properties ||
          p.propertyDefinitions != c.propertyDefinitions ||
          p.linkedProduct != c.linkedProduct,
      builder: (context, state) {
        final available = state.propertyDefinitions
            .where((d) => !state.properties.any((p) => p.definitionId == d.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MfgCardSectionHeader(
              title: 'مواصفات الباب',
              trailing: Text(
                '${state.properties.length}',
                style: AppTypography.captionBold().copyWith(
                  color: AppColors.onPrimaryFixedVariant,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            if (state.properties.isNotEmpty)
              ...state.properties.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _PropertyDenseRow(
                    index: entry.key,
                    property: entry.value,
                    definitions: state.propertyDefinitions,
                    enabled: widget.enabled,
                  ),
                ),
              ),
            SizedBox(height: AppSpacing.sm),
            SegmentedTabBar(
              tabs: const ['اختيار', 'يدوي'],
              selectedIndex: _addMode,
              onSelected: widget.enabled
                  ? (i) => setState(() => _addMode = i)
                  : (_) {},
            ),
            SizedBox(height: AppSpacing.sm),
            if (_addMode == 0)
              _CatalogPicker(definitions: available, enabled: widget.enabled)
            else
              _ManualPropertyForm(
                nameArController: _nameArController,
                nameEnController: _nameEnController,
                valueArController: _valueArController,
                valueEnController: _valueEnController,
                enabled: widget.enabled,
                onAdd: () => _addManual(context),
              ),
          ],
        );
      },
    );
  }
}

class _PropertyDenseRow extends StatefulWidget {
  const _PropertyDenseRow({
    required this.index,
    required this.property,
    required this.definitions,
    required this.enabled,
  });

  final int index;
  final ManufacturingCardPropertyDraft property;
  final List<ProductPropertyDefinition> definitions;
  final bool enabled;

  @override
  State<_PropertyDenseRow> createState() => _PropertyDenseRowState();
}

class _PropertyDenseRowState extends State<_PropertyDenseRow> {
  /// 0 = اختيار قيمة, 1 = يدوي
  var _valueMode = 0;
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _valueAr;
  late final TextEditingController _valueEn;

  ProductPropertyDefinition? get _definition {
    final id = widget.property.definitionId;
    if (id == null) return null;
    for (final d in widget.definitions) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _nameAr = TextEditingController(text: widget.property.nameAr);
    _nameEn = TextEditingController(text: widget.property.nameEn ?? '');
    _valueAr = TextEditingController(text: widget.property.valueAr);
    _valueEn = TextEditingController(text: widget.property.valueEn ?? '');
    final def = _definition;
    final hasCatalogValues = def != null && def.values.isNotEmpty;
    final matchesCatalog =
        hasCatalogValues &&
        def.values.any((v) => v.valueAr == widget.property.valueAr);
    _valueMode = matchesCatalog || widget.property.valueId != null ? 0 : 1;
    if (!hasCatalogValues) _valueMode = 1;
  }

  @override
  void didUpdateWidget(covariant _PropertyDenseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property == widget.property) return;
    if (_nameAr.text != widget.property.nameAr) {
      _nameAr.text = widget.property.nameAr;
    }
    if (_valueAr.text != widget.property.valueAr) {
      _valueAr.text = widget.property.valueAr;
    }
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _valueAr.dispose();
    _valueEn.dispose();
    super.dispose();
  }

  void _emit(BuildContext context, ManufacturingCardPropertyDraft draft) {
    context.read<ManufacturingCardFormBloc>().add(
      ManufacturingCardFormPropertyUpdated(widget.index, draft),
    );
  }

  void _pickValue(ProductPropertyValue value) {
    _valueAr.text = value.valueAr;
    _valueEn.text = value.valueEn;
    _emit(
      context,
      ManufacturingCardPropertyDraft(
        definitionId: widget.property.definitionId,
        valueId: value.id,
        nameAr: widget.property.nameAr,
        nameEn: widget.property.nameEn,
        valueAr: value.valueAr,
        valueEn: value.valueEn.isEmpty ? null : value.valueEn,
        iconKey: widget.property.iconKey,
        imageUrl: value.imageUrl ?? widget.property.imageUrl,
        sortOrder: widget.index,
      ),
    );
  }

  void _syncManual() {
    _emit(
      context,
      ManufacturingCardPropertyDraft(
        definitionId: widget.property.definitionId,
        valueId: null,
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim().isEmpty ? null : _nameEn.text.trim(),
        valueAr: _valueAr.text.trim(),
        valueEn: _valueEn.text.trim().isEmpty ? null : _valueEn.text.trim(),
        iconKey: widget.property.iconKey,
        imageUrl: widget.property.imageUrl,
        sortOrder: widget.index,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picks = await MediaPickerHelper.pickImages(
      source: ImageSource.gallery,
      multiple: false,
    );
    if (picks.isEmpty || !mounted) return;
    context.read<ManufacturingCardFormBloc>().add(
      ManufacturingCardFormPropertyImagePicked(widget.index, picks.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    final def = _definition;
    final catalogValues = def?.values ?? const <ProductPropertyValue>[];
    final hasCatalog = catalogValues.isNotEmpty;
    final icon = productPropertyIconFromKey(widget.property.iconKey);

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(icon, size: 16, color: AppColors.onPrimaryFixedVariant),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.property.nameAr,
                    style: AppTypography.captionBold().copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                if (widget.enabled)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: () =>
                        context.read<ManufacturingCardFormBloc>().add(
                          ManufacturingCardFormPropertyRemoved(widget.index),
                        ),
                  ),
              ],
            ),
          ),
          if (hasCatalog) ...[
            SizedBox(height: AppSpacing.xs),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  _ModeChip(
                    label: 'اختيار',
                    selected: _valueMode == 0,
                    onTap: widget.enabled
                        ? () => setState(() => _valueMode = 0)
                        : null,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  _ModeChip(
                    label: 'يدوي',
                    selected: _valueMode == 1,
                    onTap: widget.enabled
                        ? () => setState(() => _valueMode = 1)
                        : null,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xs),
          if (hasCatalog && _valueMode == 0)
            Wrap(
              textDirection: TextDirection.rtl,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: catalogValues.map((value) {
                final selected =
                    widget.property.valueId == value.id ||
                    widget.property.valueAr == value.valueAr;
                return FilterChip(
                  selected: selected,
                  label: Text(
                    value.valueAr,
                    style: AppTypography.caption().copyWith(
                      color: selected
                          ? AppColors.onPrimaryFixed
                          : AppColors.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selectedColor: AppColors.secondaryFixed,
                  backgroundColor: AppColors.white,
                  checkmarkColor: AppColors.onPrimaryFixed,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: selected
                        ? AppColors.onPrimaryFixedVariant.withValues(
                            alpha: 0.35,
                          )
                        : AppColors.outlineVariant,
                  ),
                  onSelected: widget.enabled ? (_) => _pickValue(value) : null,
                  avatar: value.imageUrl == null || value.imageUrl!.isEmpty
                      ? null
                      : CircleAvatar(
                          backgroundImage: NetworkImage(value.imageUrl!),
                        ),
                );
              }).toList(),
            )
          else
            Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: AlmoutawaTextField(
                        controller: _nameAr,
                        label: 'الاسم (عربي)',
                        hint: 'مثال: نوع الكالون',
                        dense: true,
                        readOnly: !widget.enabled,
                        onChanged: (_) => _syncManual(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AlmoutawaTextField(
                        controller: _nameEn,
                        label: 'Name (EN)',
                        hint: 'Lock Type',
                        dense: true,
                        readOnly: !widget.enabled,
                        onChanged: (_) => _syncManual(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: AlmoutawaTextField(
                        controller: _valueAr,
                        label: 'القيمة (عربي)',
                        hint: 'مثال: عادي',
                        dense: true,
                        readOnly: !widget.enabled,
                        onChanged: (_) => _syncManual(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AlmoutawaTextField(
                        controller: _valueEn,
                        label: 'Value (EN)',
                        hint: 'Normal',
                        dense: true,
                        readOnly: !widget.enabled,
                        onChanged: (_) => _syncManual(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          SizedBox(height: AppSpacing.xs),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                if (widget.property.imageUrl != null &&
                    widget.property.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: AppRadius.smAll,
                    child: Image.network(
                      widget.property.imageUrl!,
                      width: 44,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget.property.imageUrl != null &&
                    widget.property.imageUrl!.isNotEmpty)
                  SizedBox(width: AppSpacing.xs),
                AlmoutawaButton(
                  label: widget.property.imageUrl == null ||
                          widget.property.imageUrl!.isEmpty
                      ? 'صورة القيمة'
                      : 'تغيير الصورة',
                  icon: Icons.add_photo_alternate_outlined,
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: widget.enabled ? _pickImage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryFixed
                : AppColors.surfaceContainerLow,
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: selected
                  ? AppColors.onPrimaryFixedVariant.withValues(alpha: 0.35)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption().copyWith(
              color: selected
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogPicker extends StatelessWidget {
  const _CatalogPicker({required this.definitions, required this.enabled});

  final List<ProductPropertyDefinition> definitions;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (definitions.isEmpty) {
      return Text(
        'كل مواصفات الكتالوج مضافة — استخدم الوضع اليدوي لإضافة المزيد',
        style: AppTypography.caption().copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
    }

    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: definitions.map((def) {
        return ActionChip(
          label: Text(def.nameAr, style: AppTypography.caption()),
          avatar: Icon(
            productPropertyIconFromKey(def.iconKey),
            size: 14,
            color: AppColors.onPrimaryFixedVariant,
          ),
          backgroundColor: AppColors.surfaceContainerLow,
          side: BorderSide(color: AppColors.outlineVariant),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: enabled
              ? () => context.read<ManufacturingCardFormBloc>().add(
                  ManufacturingCardFormPropertyAddedFromCatalog(def),
                )
              : null,
        );
      }).toList(),
    );
  }
}

class _ManualPropertyForm extends StatelessWidget {
  const _ManualPropertyForm({
    required this.nameArController,
    required this.nameEnController,
    required this.valueArController,
    required this.valueEnController,
    required this.enabled,
    required this.onAdd,
  });

  final TextEditingController nameArController;
  final TextEditingController nameEnController;
  final TextEditingController valueArController;
  final TextEditingController valueEnController;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: AlmoutawaTextField(
                controller: nameArController,
                label: 'الاسم (عربي)',
                hint: 'مثال: اتجاه الفتح',
                dense: true,
                readOnly: !enabled,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AlmoutawaTextField(
                controller: nameEnController,
                label: 'Name (EN)',
                hint: 'Opening Direction',
                dense: true,
                readOnly: !enabled,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: AlmoutawaTextField(
                controller: valueArController,
                label: 'القيمة (عربي)',
                hint: 'مثال: للداخل يمين',
                dense: true,
                readOnly: !enabled,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AlmoutawaTextField(
                controller: valueEnController,
                label: 'Value (EN)',
                hint: 'Inwards Right',
                dense: true,
                readOnly: !enabled,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaButton(
          label: 'إضافة المواصفة',
          icon: Icons.add_rounded,
          size: AlmoutawaButtonSize.sm,
          onPressed: enabled ? onAdd : null,
        ),
      ],
    );
  }
}
