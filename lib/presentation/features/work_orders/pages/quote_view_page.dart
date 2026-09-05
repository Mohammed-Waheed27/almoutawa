import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/layout/expandable_notes_card.dart';
import '../../../../core/shared/widgets/layout/info_panel_section.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/work_order_detail_bloc.dart';
import '../sections/quote_view_header_section.dart';
import '../sections/quote_view_lines_section.dart';
import '../sections/quote_view_totals_section.dart';
import '../widgets/document_pdf_actions_bar.dart';
import '../widgets/document_view_skeleton.dart';

/// Read-only in-app quote viewer with separate PDF actions.
class QuoteViewPage extends StatelessWidget {
  const QuoteViewPage({
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
      title: 'عرض السعر',
      showBackButton: true,
      contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
      body: BlocConsumer<WorkOrderDetailBloc, WorkOrderDetailState>(
        listenWhen: (p, c) => p.message != c.message && c.message != null,
        listener: (context, state) {
          AlmoutawaSnackbar.show(context, state.message!);
        },
        builder: (context, state) {
          if (state.status == WorkOrderDetailStatus.loading ||
              state.detail == null) {
            return const DocumentViewSkeleton();
          }
          final detail = state.detail!;
          final quote = detail.quote;
          final pad = dense
              ? DesktopUiTokens.pagePadding
              : AppSpacing.containerPadding;
          final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

          if (quote == null) {
            return ListView(
              padding: EdgeInsets.all(pad),
              children: [
                Text('لا يوجد عرض سعر محفوظ بعد.', textAlign: TextAlign.right),
                SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
                AlmoutawaButton(
                  label: 'إنشاء عرض السعر',
                  expanded: !dense,
                  onPressed: () => context.push(
                    AppRoutes.workOrderQuotePath(rolePrefix, orderId),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: EdgeInsets.all(pad),
            children: [
              QuoteViewHeaderSection(detail: detail),
              SizedBox(height: gap),
              InfoPanelSection(
                title: 'بيانات العميل',
                compact: true,
                rows: [
                  InfoPanelRow(
                    label: 'العميل',
                    value: detail.customer.displayName,
                  ),
                  InfoPanelRow(
                    label: 'رقم العميل',
                    value: '${detail.customer.customerNumber}',
                  ),
                  InfoPanelRow(
                    label: 'الهاتف',
                    value: detail.customer.phone ?? '—',
                  ),
                  InfoPanelRow(
                    label: 'المصنع',
                    value: detail.factory?.nameAr ?? 'لم يُحدد',
                  ),
                ],
              ),
              SizedBox(height: gap),
              QuoteViewLinesSection(lines: quote.lines),
              SizedBox(height: gap),
              QuoteViewTotalsSection(quote: quote),
              if (quote.specsDescription.isNotEmpty) ...[
                SizedBox(height: gap),
                ExpandableNotesCard(
                  title: 'المواصفات',
                  body: quote.specsDescription,
                ),
              ],
              if (quote.otherComments.isNotEmpty) ...[
                SizedBox(height: gap),
                ExpandableNotesCard(
                  title: 'ملاحظات',
                  body: quote.otherComments,
                ),
              ],
              SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: AlmoutawaButton(
                  label: 'تعديل عرض السعر',
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  icon: Icons.edit_rounded,
                  size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
                  expanded: !dense,
                  onPressed: () => context.push(
                    AppRoutes.workOrderQuotePath(rolePrefix, orderId),
                  ),
                ),
              ),
              SizedBox(height: gap),
              DocumentPdfActionsBar(
                busy: state.busyPdf,
                enabled: true,
                onAction: (action) => context.read<WorkOrderDetailBloc>().add(
                  WorkOrderDetailQuotePdfRequested(action, context: context),
                ),
              ),
              SizedBox(height: dense ? DesktopUiTokens.gapXl : AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
