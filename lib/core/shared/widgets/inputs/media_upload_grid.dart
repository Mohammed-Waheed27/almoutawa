import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../../domain/entities/form_media_item.dart';
import 'media_preview_sheet.dart';

typedef OnPickMedia = Future<void> Function();
typedef OnRemoveMedia = void Function(String localId);
typedef OnReplaceMedia = Future<void> Function(String localId);

class MediaUploadGrid extends StatelessWidget {
  const MediaUploadGrid({
    super.key,
    required this.title,
    required this.items,
    required this.maxItems,
    required this.onPick,
    required this.onRemove,
    this.onReplace,
    this.enabled = true,
    this.expandedEmptyTile = false,
  });

  final String title;
  final List<FormMediaItem> items;
  final int maxItems;
  final OnPickMedia onPick;
  final OnRemoveMedia onRemove;
  final OnReplaceMedia? onReplace;
  final bool enabled;
  final bool expandedEmptyTile;

  @override
  Widget build(BuildContext context) {
    final canAdd = enabled && items.length < maxItems;

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
                  title,
                  style: AppTypography.labelBold().copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${items.length}/$maxItems',
                style: AppTypography.labelMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (items.isEmpty && expandedEmptyTile && canAdd)
            _ExpandedAddTile(onTap: onPick)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              textDirection: TextDirection.rtl,
              children: [
                ...items.map(
                  (item) => _MediaThumb(
                    item: item,
                    enabled: enabled,
                    onTap: () => MediaPreviewSheet.show(
                      context,
                      item: item,
                      enabled: enabled,
                      onDelete: () => onRemove(item.key),
                      onReplace: onReplace == null
                          ? null
                          : () => onReplace!(item.key),
                    ),
                    onRemove: enabled ? () => onRemove(item.key) : null,
                  ),
                ),
                if (canAdd) _AddTile(onTap: onPick),
              ],
            ),
        ],
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({
    required this.item,
    required this.enabled,
    required this.onTap,
    this.onRemove,
  });

  final FormMediaItem item;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: _MediaPreview(item: item),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: -6,
            left: -6,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
                minimumSize: const Size(24, 24),
                padding: EdgeInsets.zero,
              ),
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 16),
            ),
          ),
      ],
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item});

  final FormMediaItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isLocal) {
      return Image.memory(
        item.previewBytes!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      item.previewUrl!,
      width: 88,
      height: 88,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 88,
        height: 88,
        color: AppColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Ink(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.secondaryContainer,
        ),
      ),
    );
  }
}

class _ExpandedAddTile extends StatelessWidget {
  const _ExpandedAddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Ink(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.secondaryContainer,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'اضغط لرفع صورة',
              style: AppTypography.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
