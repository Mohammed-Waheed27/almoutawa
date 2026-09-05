import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';

/// Document tiles in a 2+1 bento grid (quote | agreement, manufacturing below).
class WorkOrderDocumentsSection extends StatelessWidget {
  const WorkOrderDocumentsSection({
    super.key,
    required this.rolePrefix,
    required this.orderId,
    required this.detail,
    this.manufacturingCardsDone,
  });

  final String rolePrefix;
  final String orderId;
  final CommercialOrderDetail detail;

  /// Number of manufacturing cards saved so far. null = not yet loaded.
  final int? manufacturingCardsDone;

  @override
  Widget build(BuildContext context) {
    final quote = detail.quote;
    final agreement = detail.agreement;

    final quoteTile = _DocumentTileData(
      stepLabel: '1',
      title: 'عرض السعر',
      subtitle: quote == null
          ? 'لم يُنشأ بعد'
          : '#${quote.quoteNumber} · ${quote.status.arabicLabel}',
      accent: AppColors.onPrimaryFixedVariant,
      icon: Icons.request_quote_rounded,
      primaryLabel: quote == null ? 'إنشاء' : 'عرض',
      onPrimary: () {
        if (quote == null) {
          context.push(AppRoutes.workOrderQuotePath(rolePrefix, orderId));
        } else {
          context.push(AppRoutes.workOrderQuoteViewPath(rolePrefix, orderId));
        }
      },
      onEdit: quote == null
          ? null
          : () =>
                context.push(AppRoutes.workOrderQuotePath(rolePrefix, orderId)),
    );

    final agreementTile = _DocumentTileData(
      stepLabel: '2',
      title: 'اتفاقية العمل',
      subtitle: agreement == null
          ? 'لم تُنشأ بعد'
          : '#${agreement.agreementNumber} · ${agreement.status.arabicLabel}',
      accent: AppColors.onTertiaryContainer,
      icon: Icons.handshake_rounded,
      primaryLabel: agreement == null ? 'إنشاء' : 'عرض',
      onPrimary: () {
        if (agreement == null) {
          context.push(AppRoutes.workOrderAgreementPath(rolePrefix, orderId));
        } else {
          context.push(
            AppRoutes.workOrderAgreementViewPath(rolePrefix, orderId),
          );
        }
      },
      onEdit: agreement == null
          ? null
          : () => context.push(
              AppRoutes.workOrderAgreementPath(rolePrefix, orderId),
            ),
    );

    final int cardsTotal =
        agreement?.lines.fold<int>(
          0,
          (sum, l) => sum + ((l.quantity ?? 1).ceil()).clamp(1, 9999),
        ) ??
        0;
    final int cardsDone = manufacturingCardsDone ?? 0;

    final manufacturingSubtitle = agreement == null
        ? 'تتطلب اتفاقية عمل مكتملة'
        : cardsTotal == 0
        ? 'لا توجد بنود في الاتفاقية'
        : manufacturingCardsDone == null
        ? '$cardsTotal بطاقات'
        : '$cardsDone / $cardsTotal بطاقات';

    final manufacturingTile = _DocumentTileData(
      stepLabel: '3',
      title: 'بطاقات التصنيع',
      subtitle: manufacturingSubtitle,
      accent: agreement != null
          ? AppColors.onTertiaryContainer
          : AppColors.onSurfaceVariant,
      icon: Icons.precision_manufacturing_rounded,
      primaryLabel: agreement != null ? 'فتح' : 'مغلق',
      onPrimary: agreement != null
          ? () => context.push(
              AppRoutes.workOrderManufacturingPath(rolePrefix, orderId),
            )
          : null,
      onEdit: null,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: context.density.isExpanded
          ? _DesktopDocumentsColumn(
              quoteTile: quoteTile,
              agreementTile: agreementTile,
              manufacturingTile: manufacturingTile,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'المستندات',
                  style: AppTypography.titleSm().copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DocumentPhaseTile(data: quoteTile, height: 118),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DocumentPhaseTile(
                        data: agreementTile,
                        height: 118,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                _DocumentPhaseTile(
                  data: manufacturingTile,
                  height: 72,
                  wide: true,
                ),
              ],
            ),
    );
  }
}

class _DesktopDocumentsColumn extends StatelessWidget {
  const _DesktopDocumentsColumn({
    required this.quoteTile,
    required this.agreementTile,
    required this.manufacturingTile,
  });

  final _DocumentTileData quoteTile;
  final _DocumentTileData agreementTile;
  final _DocumentTileData manufacturingTile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المستندات',
          style: AppTypography.titleOf(context).copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: DesktopUiTokens.gapSm),
        _DesktopDocRow(data: quoteTile),
        const SizedBox(height: DesktopUiTokens.gapXs),
        _DesktopDocRow(data: agreementTile),
        const SizedBox(height: DesktopUiTokens.gapXs),
        _DesktopDocRow(data: manufacturingTile),
      ],
    );
  }
}

class _DesktopDocRow extends StatelessWidget {
  const _DesktopDocRow({required this.data});

  final _DocumentTileData data;

  @override
  Widget build(BuildContext context) {
    return DesktopActionRow(
      title: '${data.stepLabel}. ${data.title}',
      subtitle: data.subtitle,
      leadingIcon: data.icon,
      statusColor: data.accent,
      onTap: data.onPrimary,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.onEdit != null)
            AlmoutawaButton(
              label: 'تعديل',
              variant: AlmoutawaButtonVariant.tertiaryText,
              size: AlmoutawaButtonSize.sm,
              expanded: false,
              onPressed: data.onEdit,
            ),
          if (data.onPrimary != null)
            AlmoutawaButton(
              label: data.primaryLabel,
              size: AlmoutawaButtonSize.sm,
              expanded: false,
              onPressed: data.onPrimary,
            ),
        ],
      ),
    );
  }
}

class _DocumentTileData {
  const _DocumentTileData({
    required this.stepLabel,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onEdit,
  });

  final String stepLabel;
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onEdit;
}

class _DocumentPhaseTile extends StatelessWidget {
  const _DocumentPhaseTile({
    required this.data,
    required this.height,
    this.wide = false,
  });

  final _DocumentTileData data;
  final double height;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final enabled = data.onPrimary != null;

    return SizedBox(
      height: height,
      child: AlmoutawaCard(
        variant: AlmoutawaCardVariant.tinted,
        padding: EdgeInsets.all(AppSpacing.sm),
        onTap: data.onPrimary,
        child: wide
            ? _WideTileBody(data: data, enabled: enabled)
            : _CompactTileBody(data: data, enabled: enabled),
      ),
    );
  }
}

class _CompactTileBody extends StatelessWidget {
  const _CompactTileBody({required this.data, required this.enabled});

  final _DocumentTileData data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            _StepBadge(stepLabel: data.stepLabel, accent: data.accent),
            SizedBox(width: AppSpacing.xs),
            Icon(data.icon, size: 16, color: data.accent),
            const Spacer(),
            if (data.onEdit != null)
              InkWell(
                onTap: data.onEdit,
                borderRadius: AppRadius.smAll,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          data.title,
          style: AppTypography.labelBold().copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 2),
        Expanded(
          child: Text(
            data.subtitle,
            style: AppTypography.caption().copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        _ActionChip(
          label: data.primaryLabel,
          accent: data.accent,
          enabled: enabled,
        ),
      ],
    );
  }
}

class _WideTileBody extends StatelessWidget {
  const _WideTileBody({required this.data, required this.enabled});

  final _DocumentTileData data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _StepBadge(stepLabel: data.stepLabel, accent: data.accent),
        SizedBox(width: AppSpacing.sm),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: data.accent.withValues(alpha: 0.12),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(data.icon, size: 20, color: data.accent),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: AppTypography.labelBold().copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                data.subtitle,
                style: AppTypography.caption().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 72,
          child: _ActionChip(
            label: data.primaryLabel,
            accent: data.accent,
            enabled: enabled,
          ),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.stepLabel, required this.accent});

  final String stepLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        stepLabel,
        style: AppTypography.captionBold().copyWith(color: accent),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.accent,
    required this.enabled,
  });

  final String label;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: enabled
            ? accent.withValues(alpha: 0.14)
            : AppColors.surfaceContainer,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTypography.captionBold().copyWith(
          color: enabled ? accent : AppColors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
