import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/product.dart';
import '../bloc/manufacturing_card_form_bloc.dart';
import '../widgets/mfg_card_section_header.dart';

/// Color entry: choose-from-product first, then full manual control.
class ManufacturingCardColorSection extends StatefulWidget {
  const ManufacturingCardColorSection({
    super.key,
    required this.colorNameArController,
    required this.colorNameEnController,
    required this.colorCodeController,
    required this.enabled,
  });

  final TextEditingController colorNameArController;
  final TextEditingController colorNameEnController;
  final TextEditingController colorCodeController;
  final bool enabled;

  @override
  State<ManufacturingCardColorSection> createState() =>
      _ManufacturingCardColorSectionState();
}

class _ManufacturingCardColorSectionState
    extends State<ManufacturingCardColorSection> {
  /// 0 = اختيار, 1 = يدوي
  var _mode = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManufacturingCardFormBloc, ManufacturingCardFormState>(
      buildWhen: (p, c) =>
          p.linkedProduct != c.linkedProduct ||
          p.pickedProductColor != c.pickedProductColor ||
          p.colorCode != c.colorCode,
      builder: (context, state) {
        final product = state.linkedProduct;
        final catalogColors = product?.colors ?? const <ProductColor>[];
        final hasCatalog = catalogColors.isNotEmpty;
        final mode = hasCatalog ? _mode : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MfgCardSectionHeader(title: 'لون الباب'),
            if (hasCatalog) ...[
              SizedBox(height: AppSpacing.sm),
              SegmentedTabBar(
                tabs: const ['اختيار', 'يدوي'],
                selectedIndex: mode,
                onSelected: widget.enabled
                    ? (i) => setState(() => _mode = i)
                    : (_) {},
              ),
            ],
            SizedBox(height: AppSpacing.sm),
            if (hasCatalog && mode == 0)
              _ColorChipRow(
                colors: catalogColors,
                selected: state.pickedProductColor,
                onPick: (color) {
                  final bloc = context.read<ManufacturingCardFormBloc>();
                  bloc.add(ManufacturingCardFormColorProductPicked(color));
                  widget.colorNameArController.text = color?.name ?? '';
                  widget.colorNameEnController.text = color?.nameEn ?? '';
                  widget.colorCodeController.text = color?.hexCode ?? '';
                },
              )
            else
              _ManualColorFields(
                colorNameArController: widget.colorNameArController,
                colorNameEnController: widget.colorNameEnController,
                colorCodeController: widget.colorCodeController,
                enabled: widget.enabled,
                onChanged: () {
                  context.read<ManufacturingCardFormBloc>().add(
                    ManufacturingCardFormColorManualChanged(
                      colorNameAr: widget.colorNameArController.text,
                      colorNameEn: widget.colorNameEnController.text,
                      colorCode: widget.colorCodeController.text,
                    ),
                  );
                },
              ),
            if (state.colorCode != null &&
                state.colorCode!.trim().startsWith('#')) ...[
              SizedBox(height: AppSpacing.xs),
              _ColorSwatch(hexCode: state.colorCode!),
            ],
          ],
        );
      },
    );
  }
}

class _ManualColorFields extends StatelessWidget {
  const _ManualColorFields({
    required this.colorNameArController,
    required this.colorNameEnController,
    required this.colorCodeController,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController colorNameArController;
  final TextEditingController colorNameEnController;
  final TextEditingController colorCodeController;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: AlmoutawaTextField(
                controller: colorNameArController,
                label: 'اسم اللون (عربي)',
                hint: 'مثال: بني خشبي SAP-87',
                dense: true,
                readOnly: !enabled,
                onChanged: (_) => onChanged(),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AlmoutawaTextField(
                controller: colorNameEnController,
                label: 'Color (EN)',
                hint: 'Brown Wood SAP-87',
                dense: true,
                readOnly: !enabled,
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AlmoutawaTextField(
          controller: colorCodeController,
          label: 'كود اللون (اختياري)',
          hint: 'SAP 87 أو #8B5A2B',
          dense: true,
          readOnly: !enabled,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _ColorChipRow extends StatelessWidget {
  const _ColorChipRow({
    required this.colors,
    required this.selected,
    required this.onPick,
  });

  final List<ProductColor> colors;
  final ProductColor? selected;
  final void Function(ProductColor?) onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: colors.map((color) {
        final isSelected = selected?.id == color.id;
        return FilterChip(
          selected: isSelected,
          label: Text(
            color.name,
            style: AppTypography.caption().copyWith(
              color: isSelected
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          avatar: _swatchDot(color),
          selectedColor: AppColors.secondaryFixed,
          backgroundColor: AppColors.surfaceContainerLow,
          checkmarkColor: AppColors.onPrimaryFixed,
          side: BorderSide(
            color: isSelected
                ? AppColors.onPrimaryFixedVariant.withValues(alpha: 0.35)
                : AppColors.outlineVariant,
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (_) => onPick(isSelected ? null : color),
        );
      }).toList(),
    );
  }

  Widget? _swatchDot(ProductColor color) {
    final code = color.hexCode?.trim();
    if (code == null || !code.startsWith('#') || code.length != 7) {
      return null;
    }
    try {
      final hex = Color(int.parse(code.replaceFirst('#', '0xFF')));
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: hex,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.hexCode});

  final String hexCode;

  @override
  Widget build(BuildContext context) {
    Color? color;
    try {
      color = Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (_) {}
    if (color == null) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: AppColors.outlineVariant),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            hexCode,
            style: AppTypography.caption().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
