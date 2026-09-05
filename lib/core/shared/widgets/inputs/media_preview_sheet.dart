import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../../domain/entities/form_media_item.dart';
import '../buttons/almoutawa_button.dart';

/// Full-screen preview for a form media item with delete / replace / cancel.
class MediaPreviewSheet extends StatelessWidget {
  const MediaPreviewSheet({
    super.key,
    required this.item,
    required this.onDelete,
    this.onReplace,
    this.enabled = true,
  });

  final FormMediaItem item;
  final VoidCallback onDelete;
  final VoidCallback? onReplace;
  final bool enabled;

  static Future<void> show(
    BuildContext context, {
    required FormMediaItem item,
    required VoidCallback onDelete,
    VoidCallback? onReplace,
    bool enabled = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      builder: (_) => MediaPreviewSheet(
        item: item,
        onDelete: onDelete,
        onReplace: onReplace,
        enabled: enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight =
        MediaQuery.sizeOf(context).height * 0.82 - viewInsets.bottom;

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
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'معاينة الصورة',
                style: AppTypography.headlineSm().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.lgAll,
                  child: InteractiveViewer(
                    minScale: 0.75,
                    maxScale: 3,
                    child: item.isLocal
                        ? Image.memory(
                            item.previewBytes!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          )
                        : Image.network(
                            item.previewUrl!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              if (enabled && onReplace != null) ...[
                AlmoutawaButton(
                  label: 'استبدال الصورة',
                  icon: Icons.swap_horiz_rounded,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  onPressed: () {
                    Navigator.pop(context);
                    onReplace!();
                  },
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              if (enabled)
                AlmoutawaButton(
                  label: 'حذف الصورة',
                  icon: Icons.delete_outline_rounded,
                  variant: AlmoutawaButtonVariant.destructive,
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              SizedBox(height: AppSpacing.sm),
              AlmoutawaButton(
                label: 'إلغاء',
                icon: Icons.close_rounded,
                variant: AlmoutawaButtonVariant.tertiaryText,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
