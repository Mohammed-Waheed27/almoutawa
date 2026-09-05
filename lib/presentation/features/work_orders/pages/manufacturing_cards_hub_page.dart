import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/pdf/manufacturing_card_pdf_builder.dart';
import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/layout/almoutawa_adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../di/injection_container.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/manufacturing_card.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/manufacturing_cards_hub_bloc.dart';
import '../sections/manufacturing_card_slots_section.dart';
import '../widgets/manufacturing_cards_hub_skeleton.dart';

class ManufacturingCardsHubPage extends StatelessWidget {
  const ManufacturingCardsHubPage({
    super.key,
    required this.rolePrefix,
    required this.orderId,
  });

  final String rolePrefix;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return RoleDashboardScaffold(
      title: 'بطاقات التصنيع',
      showBackButton: true,
      contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
      body: BlocConsumer<ManufacturingCardsHubBloc, ManufacturingCardsHubState>(
        listenWhen: (p, c) =>
            p.message != c.message && c.message != null || p.status != c.status,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state.showBlockingSpinner) {
            return const ManufacturingCardsHubSkeleton();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HubProgressStrip(
                completed: state.completedCount,
                total: state.totalCount,
                dense: dense,
              ),
              Expanded(
                child: ManufacturingCardSlotsSection(
                  slots: state.slots,
                  onSlotTap: (slot) => _navigateToCard(context, slot),
                  onPdfTap: state.detail == null
                      ? null
                      : (slot) => _showPdfSheet(
                          context,
                          detail: state.detail!,
                          card: slot.existingCard!,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToCard(
    BuildContext context,
    ManufacturingCardSlot slot,
  ) async {
    final locked =
        context.read<ManufacturingCardsHubBloc>().state.cardsLocked;
    if (locked && !slot.isComplete) {
      AlmoutawaSnackbar.show(
        context,
        'لا يمكن إنشاء بطاقة تصنيع بعد اكتمال الطلب',
      );
      return;
    }
    final saved = await context.push<ManufacturingCard>(
      AppRoutes.workOrderManufacturingCardPath(
        rolePrefix,
        orderId,
        slot.agreementLine.id,
        slot.cardIndex,
      ),
    );
    if (!context.mounted) return;
    if (saved != null) {
      context.read<ManufacturingCardsHubBloc>().add(
        ManufacturingCardsHubCardSaved(saved),
      );
    } else {
      context.read<ManufacturingCardsHubBloc>().add(
        const ManufacturingCardsHubRefreshed(),
      );
    }
  }

  Future<void> _showPdfSheet(
    BuildContext context, {
    required CommercialOrderDetail detail,
    required ManufacturingCard card,
  }) async {
    final action = await AlmoutawaAdaptiveSheet.show<String>(
      context: context,
      title: 'PDF بطاقة التصنيع',
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.containerPadding,
            AppSpacing.sm,
            AppSpacing.containerPadding,
            AppSpacing.containerPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.save_alt_rounded),
                title: const Text('حفظ PDF عربي'),
                onTap: () => Navigator.pop(ctx, 'save_ar'),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt_rounded),
                title: const Text('حفظ PDF English'),
                onTap: () => Navigator.pop(ctx, 'save_en'),
              ),
              if (!PdfShareService.isWindowsDesktop) ...[
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('معاينة PDF عربي'),
                  onTap: () => Navigator.pop(ctx, 'preview_ar'),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('معاينة PDF English'),
                  onTap: () => Navigator.pop(ctx, 'preview_en'),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;

    final locale = action.endsWith('_en')
        ? ManufacturingCardPdfLocale.english
        : ManufacturingCardPdfLocale.arabic;
    final pdfAction = action.startsWith('preview')
        ? PdfDocumentAction.preview
        : PdfDocumentAction.save;

    try {
      final bytes = await getIt<ManufacturingCardPdfBuilder>().build(
        detail: detail,
        card: card,
        locale: locale,
        context: context,
      );
      final message = await getIt<PdfShareService>().deliver(
        bytes: bytes,
        fileName: 'card-${card.id.substring(0, 8)}-${locale.fileSuffix}.pdf',
        subject: locale.isArabic ? 'بطاقة تصنيع' : 'Manufacturing Card',
        action: pdfAction,
      );
      if (context.mounted) {
        AlmoutawaSnackbar.show(context, message);
      }
    } catch (_) {
      if (context.mounted) {
        AlmoutawaSnackbar.show(context, 'خطأ في توليد PDF');
      }
    }
  }
}

class _HubProgressStrip extends StatelessWidget {
  const _HubProgressStrip({
    required this.completed,
    required this.total,
    required this.dense,
  });

  final int completed;
  final int total;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? completed / total : 0.0;
    final accent = completed == total && total > 0
        ? AppColors.success
        : AppColors.onPrimaryFixedVariant;
    final pad = dense
        ? DesktopUiTokens.pagePadding
        : AppSpacing.containerPadding;
    final inner = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.fromLTRB(pad, inner, pad, 0),
        padding: EdgeInsets.all(inner),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(
            dense ? DesktopUiTokens.radiusMd : 12,
          ),
          border: dense
              ? Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  '$completed / $total بطاقة مكتملة',
                  style: AppTypography.captionBold().copyWith(
                    color: accent,
                    fontSize: dense ? DesktopUiTokens.label : null,
                  ),
                ),
                const Spacer(),
                Text(
                  total == 0 ? '—' : '${(fraction * 100).toStringAsFixed(0)}%',
                  style: AppTypography.caption().copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: dense ? DesktopUiTokens.label : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.xs),
            // Text progress only — no LinearProgressIndicator on hub cards.
            Text(
              total == 0
                  ? 'لا بطاقات بعد'
                  : completed == total
                  ? 'اكتملت كل البطاقات'
                  : 'متبقي ${total - completed} بطاقة',
              style: AppTypography.captionOf(context).copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
