import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/media/media_picker_helper.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/manufacturing_card_form_bloc.dart';
import '../widgets/mfg_card_section_header.dart';

class ManufacturingCardImagesSection extends StatelessWidget {
  const ManufacturingCardImagesSection({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManufacturingCardFormBloc, ManufacturingCardFormState>(
      buildWhen: (p, c) =>
          p.linkedProduct != c.linkedProduct ||
          p.pickedProductColor != c.pickedProductColor ||
          p.productImageUrl != c.productImageUrl ||
          p.colorImageUrl != c.colorImageUrl ||
          p.colorNameAr != c.colorNameAr ||
          p.colorCode != c.colorCode,
      builder: (context, state) {
        final productImage =
            state.productImageUrl ??
            state.linkedProduct?.coverImageUrl ??
            state.existingCard?.productImageUrl;
        final colorImage =
            state.colorImageUrl ??
            state.pickedProductColor?.coverImageUrl ??
            state.existingCard?.colorImageUrl;
        final colorName = state.colorNameAr.trim().isEmpty
            ? (state.pickedProductColor?.name ?? '')
            : state.colorNameAr.trim();
        final colorCode = state.colorCode?.trim().isNotEmpty == true
            ? state.colorCode!.trim()
            : (state.pickedProductColor?.hexCode ?? '');

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MfgCardSectionHeader(title: 'صور الباب واللون'),
              SizedBox(height: AppSpacing.sm),
              Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ImageSlot(
                      title: 'صورة الباب',
                      imageUrl: productImage,
                      emptyLabel: 'الباب ليس له صورة',
                      enabled: enabled,
                      onUpload: () => _pickProduct(context),
                      onClear: productImage == null || productImage.isEmpty
                          ? null
                          : () => context.read<ManufacturingCardFormBloc>().add(
                              const ManufacturingCardFormProductImageCleared(),
                            ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ImageSlot(
                      title: colorName.isEmpty ? 'صورة اللون' : colorName,
                      subtitle: colorCode.isEmpty ? null : colorCode,
                      imageUrl: colorImage,
                      emptyLabel: 'الصورة غير متوفرة',
                      enabled: enabled,
                      onUpload: () => _pickColor(context),
                      onClear: colorImage == null || colorImage.isEmpty
                          ? null
                          : () => context.read<ManufacturingCardFormBloc>().add(
                              const ManufacturingCardFormColorImageCleared(),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProduct(BuildContext context) async {
    final picks = await MediaPickerHelper.pickImages(
      source: ImageSource.gallery,
      multiple: false,
    );
    if (picks.isEmpty || !context.mounted) return;
    context.read<ManufacturingCardFormBloc>().add(
      ManufacturingCardFormProductImagePicked(picks.first),
    );
  }

  Future<void> _pickColor(BuildContext context) async {
    final picks = await MediaPickerHelper.pickImages(
      source: ImageSource.gallery,
      multiple: false,
    );
    if (picks.isEmpty || !context.mounted) return;
    context.read<ManufacturingCardFormBloc>().add(
      ManufacturingCardFormColorImagePicked(picks.first),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot({
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.emptyLabel,
    required this.enabled,
    required this.onUpload,
    this.onClear,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String emptyLabel;
  final bool enabled;
  final VoidCallback onUpload;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.labelBold(),
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTypography.caption().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ],
        SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: AspectRatio(
            aspectRatio: 1,
            child: imageUrl == null || imageUrl!.isEmpty
                ? ColoredBox(
                    color: AppColors.surfaceContainerLow,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          emptyLabel,
                          style: AppTypography.caption().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Image.network(imageUrl!, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        AlmoutawaButton(
          label: imageUrl == null || imageUrl!.isEmpty ? 'رفع صورة' : 'تغيير الصورة',
          icon: Icons.add_photo_alternate_outlined,
          variant: AlmoutawaButtonVariant.tertiaryText,
          size: AlmoutawaButtonSize.sm,
          onPressed: enabled ? onUpload : null,
        ),
        if (onClear != null)
          AlmoutawaButton(
            label: 'حذف الصورة',
            icon: Icons.delete_outline_rounded,
            variant: AlmoutawaButtonVariant.destructive,
            size: AlmoutawaButtonSize.sm,
            onPressed: enabled ? onClear : null,
          ),
      ],
    );
  }
}
