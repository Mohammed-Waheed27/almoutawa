import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/manufacturing_card.dart';

String manufacturingCardSlotSubtitle(dynamic line, ManufacturingCard? card) {
  final parts = <String>[];
  final w = card?.widthCm ?? line.widthCm;
  final h = card?.heightCm ?? line.heightCm;
  if (w != null && h != null && w > 0 && h > 0) {
    parts.add('${w.toStringAsFixed(0)} × ${h.toStringAsFixed(0)} سم');
  }
  if (card?.colorNameAr != null && card!.colorNameAr!.isNotEmpty) {
    parts.add(card.colorNameAr!);
  }
  if (parts.isEmpty) parts.add('لم تُنشأ بعد — اضغط للتعبئة');
  return parts.join(' · ');
}

class ManufacturingCardSlotsSection extends StatelessWidget {
  const ManufacturingCardSlotsSection({
    super.key,
    required this.slots,
    required this.onSlotTap,
    this.onPdfTap,
  });

  final List<ManufacturingCardSlot> slots;
  final void Function(ManufacturingCardSlot slot) onSlotTap;
  final void Function(ManufacturingCardSlot slot)? onPdfTap;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            dense ? DesktopUiTokens.gapXl : AppSpacing.xl,
          ),
          child: Text(
            'لا توجد بنود في الاتفاقية',
            style: AppTypography.bodyLg().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: dense ? DesktopUiTokens.body : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (dense) {
      return ListView.separated(
        padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
        itemCount: slots.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: DesktopUiTokens.gapSm),
        itemBuilder: (_, index) {
          final slot = slots[index];
          final isComplete = slot.isComplete;
          return DesktopActionRow(
            title: slot.titleAr,
            subtitle: manufacturingCardSlotSubtitle(
              slot.agreementLine,
              slot.existingCard,
            ),
            leadingIcon: isComplete
                ? Icons.check_circle_rounded
                : Icons.construction_rounded,
            statusColor: isComplete
                ? AppColors.success
                : AppColors.onSurfaceVariant,
            onTap: () => onSlotTap(slot),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isComplete && onPdfTap != null)
                  AlmoutawaButton(
                    label: 'PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    variant: AlmoutawaButtonVariant.tertiaryText,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: () => onPdfTap!(slot),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesktopUiTokens.gapSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isComplete
                                ? AppColors.success
                                : AppColors.onSurfaceVariant)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      DesktopUiTokens.radiusSm,
                    ),
                  ),
                  child: Text(
                    isComplete ? 'مكتملة' : 'لم تُنشأ بعد',
                    style: AppTypography.captionBold().copyWith(
                      fontSize: DesktopUiTokens.label,
                      color: isComplete
                          ? AppColors.success
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.containerPadding),
      itemCount: slots.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, index) => _ManufacturingCardSlotTile(
        slot: slots[index],
        onTap: onSlotTap,
        onPdfTap: onPdfTap,
      ),
    );
  }
}

class _ManufacturingCardSlotTile extends StatelessWidget {
  const _ManufacturingCardSlotTile({
    required this.slot,
    required this.onTap,
    this.onPdfTap,
  });

  final ManufacturingCardSlot slot;
  final void Function(ManufacturingCardSlot) onTap;
  final void Function(ManufacturingCardSlot)? onPdfTap;

  @override
  Widget build(BuildContext context) {
    final card = slot.existingCard;
    final isComplete = slot.isComplete;
    final accent = isComplete ? AppColors.success : AppColors.onSurfaceVariant;
    final line = slot.agreementLine;

    return AlmoutawaCard(
      onTap: () => onTap(slot),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(
                isComplete
                    ? Icons.check_circle_rounded
                    : Icons.construction_rounded,
                color: accent,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.titleAr,
                    style: AppTypography.labelBold().copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 2),
                  Text(
                    manufacturingCardSlotSubtitle(line, card),
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            if (isComplete && onPdfTap != null) ...[
              IconButton(
                tooltip: 'PDF',
                visualDensity: VisualDensity.compact,
                onPressed: () => onPdfTap!(slot),
                icon: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.onPrimaryFixedVariant,
                  size: 20,
                ),
              ),
            ],
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                isComplete ? 'مكتملة' : 'لم تُنشأ بعد',
                style: AppTypography.captionBold().copyWith(color: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
