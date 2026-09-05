import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/media/media_picker_helper.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/inputs/hex_color_field.dart';
import '../../../../core/shared/widgets/inputs/media_upload_grid.dart';
import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/storage_quota.dart';
import '../bloc/product_form_bloc.dart';

class ProductImagesSection extends StatelessWidget {
  const ProductImagesSection({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormBloc, ProductFormState>(
      builder: (context, state) {
        final quota = state.storageQuota;
        final bloc = context.read<ProductFormBloc>();

        return MediaUploadGrid(
          title: 'صور المنتج',
          items: state.productImages,
          maxItems: quota?.maxProductImages ?? 8,
          enabled: enabled,
          expandedEmptyTile: true,
          onPick: () => _pickProductImages(context, bloc),
          onRemove: (localId) =>
              bloc.add(ProductFormProductImageRemoved(localId)),
          onReplace: enabled
              ? (localId) => _replaceProductImage(context, bloc, localId)
              : null,
        );
      },
    );
  }

  Future<void> _pickProductImages(
    BuildContext context,
    ProductFormBloc bloc,
  ) async {
    final picks = await MediaPickerHelper.pickImages(
      source: ImageSource.gallery,
    );
    if (picks.isEmpty || !context.mounted) return;
    bloc.add(ProductFormProductImagesAdded(picks));
  }

  Future<void> _replaceProductImage(
    BuildContext context,
    ProductFormBloc bloc,
    String localId,
  ) async {
    bloc.add(ProductFormProductImageRemoved(localId));
    await _pickProductImages(context, bloc);
  }
}

class ProductColorsSection extends StatefulWidget {
  const ProductColorsSection({super.key, required this.enabled});

  final bool enabled;

  @override
  State<ProductColorsSection> createState() => _ProductColorsSectionState();
}

class _ProductColorsSectionState extends State<ProductColorsSection> {
  final _nameController = TextEditingController();
  final _hexController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _addColor() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AlmoutawaSnackbar.show(context, 'اسم اللون مطلوب');
      return;
    }
    context.read<ProductFormBloc>().add(
      ProductFormColorAdded(
        name: _nameController.text,
        hexCode: _hexController.text,
      ),
    );
    _nameController.clear();
    _hexController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormBloc, ProductFormState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ألوان المنتج',
                style: AppTypography.headlineSm().copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              AlmoutawaTextField(
                controller: _nameController,
                label: 'اسم اللون',
                hint: 'مثال: أبيض ثلجي',
                icon: Icons.palette_outlined,
                readOnly: !widget.enabled,
              ),
              SizedBox(height: AppSpacing.sm),
              HexColorField(
                controller: _hexController,
                readOnly: !widget.enabled,
              ),
              SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AlmoutawaButton(
                  label: 'إضافة اللون',
                  icon: Icons.add_rounded,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  size: AlmoutawaButtonSize.sm,
                  expanded: false,
                  onPressed: widget.enabled ? _addColor : null,
                ),
              ),
              if (state.colors.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                ...state.colors.map(
                  (color) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ColorDraftCard(
                      entry: color,
                      enabled: widget.enabled,
                      quota: state.storageQuota,
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
}

class _ColorDraftCard extends StatefulWidget {
  const _ColorDraftCard({
    required this.entry,
    required this.enabled,
    required this.quota,
  });

  final ProductColorDraftEntry entry;
  final bool enabled;
  final StorageQuota? quota;

  @override
  State<_ColorDraftCard> createState() => _ColorDraftCardState();
}

class _ColorDraftCardState extends State<_ColorDraftCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _hexController = TextEditingController(text: widget.entry.hexCode ?? '');
  }

  @override
  void didUpdateWidget(covariant _ColorDraftCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.name != widget.entry.name) {
      _nameController.text = widget.entry.name;
    }
    if (oldWidget.entry.hexCode != widget.entry.hexCode) {
      _hexController.text = widget.entry.hexCode ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _syncColor() {
    context.read<ProductFormBloc>().add(
      ProductFormColorUpdated(
        localId: widget.entry.localId,
        name: _nameController.text,
        hexCode: _hexController.text,
      ),
    );
  }

  Future<void> _pickColorImages(ProductFormBloc bloc) async {
    final picks = await MediaPickerHelper.pickImages(
      source: ImageSource.gallery,
    );
    if (picks.isEmpty || !mounted) return;
    bloc.add(
      ProductFormColorImagesAdded(
        colorLocalId: widget.entry.localId,
        picks: picks,
      ),
    );
  }

  Future<void> _replaceColorImage(
    ProductFormBloc bloc,
    String imageLocalId,
  ) async {
    bloc.add(
      ProductFormColorImageRemoved(
        colorLocalId: widget.entry.localId,
        imageLocalId: imageLocalId,
      ),
    );
    await _pickColorImages(bloc);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductFormBloc>();

    return AlmoutawaCard(
      variant: AlmoutawaCardVariant.solid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  widget.entry.name,
                  style: AppTypography.bodyLg().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AlmoutawaButton(
                label: 'حذف',
                icon: Icons.delete_outline_rounded,
                variant: AlmoutawaButtonVariant.destructive,
                size: AlmoutawaButtonSize.sm,
                expanded: false,
                onPressed: widget.enabled
                    ? () => bloc.add(
                        ProductFormColorRemoved(widget.entry.localId),
                      )
                    : null,
              ),
            ],
          ),
          AlmoutawaTextField(
            controller: _nameController,
            label: 'اسم اللون',
            icon: Icons.palette_outlined,
            readOnly: !widget.enabled,
            onFieldSubmitted: (_) => _syncColor(),
          ),
          SizedBox(height: AppSpacing.sm),
          HexColorField(
            controller: _hexController,
            readOnly: !widget.enabled,
            onChanged: (_) => _syncColor(),
          ),
          SizedBox(height: AppSpacing.sm),
          MediaUploadGrid(
            title: 'صور اللون',
            items: widget.entry.images,
            maxItems: widget.quota?.maxColorImages ?? 6,
            enabled: widget.enabled,
            onPick: () => _pickColorImages(bloc),
            onRemove: (localId) => bloc.add(
              ProductFormColorImageRemoved(
                colorLocalId: widget.entry.localId,
                imageLocalId: localId,
              ),
            ),
            onReplace: widget.enabled
                ? (localId) => _replaceColorImage(bloc, localId)
                : null,
          ),
        ],
      ),
    );
  }
}
