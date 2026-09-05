import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/adaptive_content_frame.dart';
import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../work_orders/bloc/work_orders_list_bloc.dart';
import '../../work_orders/sections/work_orders_stats_section.dart';
import '../sections/delivery_recent_work_orders_section.dart';
import '../widgets/delivery_home_hub_skeleton.dart';

/// Delivery worker home hub — work-orders focused (ready-delivery retired for now).
class DeliveryHomePage extends StatelessWidget {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthBloc>().state.session;
    final displayName = session?.displayName ?? 'مندوب التسليم';
    final roleLabel =
        session?.role.arabicLabel ?? UserRole.deliveryWorker.arabicLabel;
    final dense = context.density.isExpanded;

    return BlocBuilder<WorkOrdersListBloc, WorkOrdersListState>(
      builder: (context, state) {
        final showSkeleton = state.showBlockingSpinner;

        return RoleTabScaffold(
          title: 'التسليم',
          subtitle: 'أهلاً، $displayName\n$roleLabel',
          actions: [
            HubHeaderIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث',
              onPressed: () => context.read<WorkOrdersListBloc>().add(
                const WorkOrdersListRefreshRequested(),
              ),
            ),
          ],
          body: AdaptiveContentFrame(
            mode: AdaptiveContentMode.hub,
            padding: EdgeInsets.zero,
            child: showSkeleton
                ? ListView(
                    padding: ShellScrollInsets.tabListPadding(context),
                    children: const [DeliveryHomeHubSkeleton()],
                  )
                : dense
                ? _DeliveryHomeDesktopBody(items: state.items)
                : ListView(
                    padding: ShellScrollInsets.tabListPadding(context),
                    children: [
                      WorkOrdersStatsSection(items: state.items),
                      SizedBox(height: AppSpacing.md),
                      DeliveryRecentWorkOrdersSection(
                        items: state.items,
                        showSkeleton: false,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Two-pane home: KPI / shortcuts rail + recent list filling remaining width.
class _DeliveryHomeDesktopBody extends StatelessWidget {
  const _DeliveryHomeDesktopBody({required this.items});

  final List<CommercialOrderSummary> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: DesktopUiTokens.filterSidebarWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'نظرة سريعة',
                  style: AppTypography.titleMd().copyWith(
                    fontSize: DesktopUiTokens.pageTitle - 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: DesktopUiTokens.gapMd),
                WorkOrdersStatsSection(items: items),
                const SizedBox(height: DesktopUiTokens.gapLg),
                AlmoutawaButton(
                  label: 'كل الطلبات',
                  icon: Icons.assignment_outlined,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  onPressed: () => context.go(AppRoutes.deliveryOrders),
                ),
                const SizedBox(height: DesktopUiTokens.gapSm),
                AlmoutawaButton(
                  label: 'طلب جديد',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      context.push(AppRoutes.workOrderCreatePath('delivery')),
                ),
                const SizedBox(height: DesktopUiTokens.gapSm),
                AlmoutawaButton(
                  label: 'العملاء',
                  icon: Icons.people_outline_rounded,
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  onPressed: () => context.go(AppRoutes.deliveryCustomers),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesktopUiTokens.gapLg),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(DesktopUiTokens.radiusLg),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapSm,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            'أحدث طلبات العمل',
                            style: AppTypography.titleMd().copyWith(
                              fontSize: DesktopUiTokens.pageTitle - 1,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (items.isNotEmpty)
                          AlmoutawaButton(
                            label: 'عرض الكل',
                            variant: AlmoutawaButtonVariant.tertiaryText,
                            size: AlmoutawaButtonSize.sm,
                            expanded: false,
                            onPressed: () =>
                                context.go(AppRoutes.deliveryOrders),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: items.isEmpty
                        ? const EmptyStateWidget(
                            message: 'لا توجد طلبات عمل حالياً',
                            icon: Icons.request_quote_outlined,
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final summary = items[index];
                              return DesktopMasterListTile(
                                title: summary.order.orderNumber,
                                subtitle:
                                    '${summary.customer.displayName} · ${summary.order.phase.arabicLabel}',
                                trailing: Icon(
                                  Icons.chevron_left_rounded,
                                  size: DesktopUiTokens.iconSize,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                onTap: () => context.push(
                                  AppRoutes.workOrderDetailPath(
                                    'delivery',
                                    summary.order.id,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
