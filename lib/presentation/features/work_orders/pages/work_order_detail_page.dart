import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/work_order_detail_bloc.dart';
import '../layouts/work_order_detail_desktop_body.dart';
import '../sections/work_order_documents_section.dart';
import '../sections/work_order_ops_actions_section.dart';
import '../sections/work_order_timeline_section.dart';
import '../widgets/work_order_detail_skeleton.dart';

class WorkOrderDetailPage extends StatelessWidget {
  const WorkOrderDetailPage({
    super.key,
    required this.rolePrefix,
    required this.orderId,
  });

  final String rolePrefix;
  final String orderId;

  bool get _isOpsManager => rolePrefix == 'production';

  bool get _isAdmin => rolePrefix == 'admin';

  bool get _canAssignFactory => _isOpsManager || _isAdmin;

  bool _canRequestManufacturing(CommercialOrderPhase phase) =>
      phase == CommercialOrderPhase.manufacturingDraft;

  bool _canComplete(CommercialOrderPhase phase) =>
      (_isOpsManager || _isAdmin) &&
      phase == CommercialOrderPhase.manufacturing;

  bool _canDeliver(CommercialOrderPhase phase) =>
      phase == CommercialOrderPhase.completed;

  bool _canCancel(CommercialOrderPhase phase) =>
      (_isOpsManager || _isAdmin) &&
      (phase == CommercialOrderPhase.quote ||
          phase == CommercialOrderPhase.agreement ||
          phase == CommercialOrderPhase.manufacturingDraft ||
          phase == CommercialOrderPhase.manufacturing);

  String get _ordersListPath => switch (rolePrefix) {
    'admin' => AppRoutes.adminWorkOrders,
    'production' => AppRoutes.productionOrders,
    _ => AppRoutes.deliveryOrders,
  };

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(_ordersListPath);
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack(context);
      },
      child: RoleDashboardScaffold(
        title: 'تفاصيل طلب العمل',
        showBackButton: true,
        onBack: () => _goBack(context),
        contentMaxWidth: dense ? DesktopUiTokens.hubMaxWidth : null,
        body: BlocConsumer<WorkOrderDetailBloc, WorkOrderDetailState>(
          listenWhen: (p, c) => p.message != c.message && c.message != null,
          listener: (context, state) {
            AlmoutawaSnackbar.show(context, state.message!);
          },
          builder: (context, state) {
            if (state.status == WorkOrderDetailStatus.loading ||
                state.detail == null) {
              return const WorkOrderDetailSkeleton();
            }
            final detail = state.detail!;

            if (dense) {
              return WorkOrderDetailDesktopBody(
                rolePrefix: rolePrefix,
                orderId: orderId,
                detail: detail,
                isOpsManager: _isOpsManager,
                manufacturingCardsDone: state.manufacturingCardsDone,
                factories: state.factories,
                busyAction: state.busyAction,
                showFactoryPicker: _canAssignFactory,
                canRequestManufacturing: _canRequestManufacturing(
                  detail.order.phase,
                ),
                canComplete: _canComplete(detail.order.phase),
                canDeliver: _canDeliver(detail.order.phase),
                canCancel: _canCancel(detail.order.phase),
                onFactorySelected: (id) => context
                    .read<WorkOrderDetailBloc>()
                    .add(WorkOrderDetailFactoryAssigned(id)),
                onStartManufacturing: () =>
                    context.read<WorkOrderDetailBloc>().add(
                      const WorkOrderDetailPhaseAdvanceRequested(
                        CommercialOrderPhase.manufacturing,
                      ),
                    ),
                onComplete: () => context.read<WorkOrderDetailBloc>().add(
                  const WorkOrderDetailPhaseAdvanceRequested(
                    CommercialOrderPhase.completed,
                  ),
                ),
                onMarkDelivered: () => context.read<WorkOrderDetailBloc>().add(
                  const WorkOrderDetailPhaseAdvanceRequested(
                    CommercialOrderPhase.delivered,
                  ),
                ),
                onCancel: () => context.read<WorkOrderDetailBloc>().add(
                  const WorkOrderDetailPhaseAdvanceRequested(
                    CommercialOrderPhase.cancelled,
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              children: [
                DecorativeSummaryCard(
                  tone: DecorativeCardTone.blue,
                  compact: true,
                  title: detail.order.orderNumber,
                  subtitle: detail.customer.displayName,
                  badge: detail.order.phase.arabicLabel,
                  metrics: [
                    DecorativeSummaryMetric(
                      label: 'رقم العميل',
                      value: '${detail.customer.customerNumber}',
                    ),
                    DecorativeSummaryMetric(
                      label: 'الهاتف',
                      value: detail.customer.phone ?? '—',
                    ),
                    DecorativeSummaryMetric(
                      label: 'المصنع',
                      value: detail.factory?.displayName ?? 'لم يُحدد',
                    ),
                  ],
                ),
                if (detail.createdBy != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'أنشأه: ${detail.createdBy!.displayName} · ${detail.createdBy!.roleLabelAr}',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                SizedBox(height: AppSpacing.sm),
                AlmoutawaCard(
                  variant: AlmoutawaCardVariant.solid,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: WorkOrderTimelineSection(phase: detail.order.phase),
                ),
                if (_canAssignFactory ||
                    _canRequestManufacturing(detail.order.phase) ||
                    _canComplete(detail.order.phase) ||
                    _canDeliver(detail.order.phase) ||
                    _canCancel(detail.order.phase)) ...[
                  SizedBox(height: AppSpacing.md),
                  WorkOrderOpsActionsSection(
                    factories: state.factories,
                    selectedFactoryId: detail.order.factoryId,
                    currentPhase: detail.order.phase,
                    busy: state.busyAction,
                    showFactoryPicker: _canAssignFactory,
                    canRequestManufacturing: _canRequestManufacturing(
                      detail.order.phase,
                    ),
                    canComplete: _canComplete(detail.order.phase),
                    canDeliver: _canDeliver(detail.order.phase),
                    canCancel: _canCancel(detail.order.phase),
                    onFactorySelected: (id) => context
                        .read<WorkOrderDetailBloc>()
                        .add(WorkOrderDetailFactoryAssigned(id)),
                    onStartManufacturing: () =>
                        context.read<WorkOrderDetailBloc>().add(
                          const WorkOrderDetailPhaseAdvanceRequested(
                            CommercialOrderPhase.manufacturing,
                          ),
                        ),
                    onComplete: () => context.read<WorkOrderDetailBloc>().add(
                      const WorkOrderDetailPhaseAdvanceRequested(
                        CommercialOrderPhase.completed,
                      ),
                    ),
                    onMarkDelivered: () =>
                        context.read<WorkOrderDetailBloc>().add(
                          const WorkOrderDetailPhaseAdvanceRequested(
                            CommercialOrderPhase.delivered,
                          ),
                        ),
                    onCancel: () => context.read<WorkOrderDetailBloc>().add(
                      const WorkOrderDetailPhaseAdvanceRequested(
                        CommercialOrderPhase.cancelled,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.md),
                WorkOrderDocumentsSection(
                  rolePrefix: rolePrefix,
                  orderId: orderId,
                  detail: detail,
                  manufacturingCardsDone: state.manufacturingCardsDone,
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            );
          },
        ),
      ),
    );
  }
}
