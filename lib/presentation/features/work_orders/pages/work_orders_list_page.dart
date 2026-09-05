import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/buttons/gradient_fab.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/bloc_refresh_wait.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/work_orders_list_bloc.dart';
import '../layouts/work_orders_list_desktop_body.dart';
import '../sections/work_orders_stats_section.dart';
import '../widgets/work_order_list_card.dart';
import '../widgets/work_orders_list_filters.dart';
import '../widgets/work_orders_list_skeleton.dart';
import '../widgets/work_orders_search_section.dart';

class WorkOrdersListPage extends StatefulWidget {
  const WorkOrdersListPage({
    super.key,
    required this.rolePrefix,
    this.embedInParent = false,
    this.showCreateAction = true,
  });

  final String rolePrefix;

  /// When true, omit scaffold chrome (parent shell already provides it).
  final bool embedInParent;

  /// When false, hide FAB / empty-state create CTA (ops manager read-only list).
  final bool showCreateAction;

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  final _searchController = TextEditingController();
  WorkOrdersListFilters _filters = WorkOrdersListFilters.empty;
  String _query = '';
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreate() {
    context.push(AppRoutes.workOrderCreatePath(widget.rolePrefix));
  }

  bool _matchesQuery(CommercialOrderSummary summary) {
    if (_query.isEmpty) return true;
    final haystack =
        '${summary.order.orderNumber} ${summary.customer.displayName} '
                '${summary.customer.customerNumber} '
                '${summary.customer.phone ?? ''} '
                '${summary.order.phase.arabicLabel}'
            .toLowerCase();
    return haystack.contains(_query);
  }

  List<CommercialOrderSummary> _filtered(List<CommercialOrderSummary> items) {
    return items.where(_filters.matches).where(_matchesQuery).toList();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<WorkOrdersListBloc>();
    final tickBefore = bloc.state.refreshTick;
    bloc.add(const WorkOrdersListRefreshRequested());
    await waitForBlocRefreshTick(
      stream: bloc.stream,
      tickBefore: tickBefore,
      readTick: (state) => state.refreshTick,
    );
  }

  Widget _buildCompactListBody(WorkOrdersListState state) {
    if (state.showBlockingSpinner) {
      return const WorkOrdersListSkeleton();
    }

    final filtered = _filtered(state.items);
    final customers = customerOptionsFromOrders(state.items);
    final bottomPad = widget.embedInParent
        ? ShellScrollInsets.bottom(context)
        : 100.0;

    return RefreshIndicator(
      color: AppColors.secondaryContainer,
      backgroundColor: AppColors.surfaceContainerHighest,
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.md,
          AppSpacing.containerPadding,
          bottomPad,
        ),
        children: [
          WorkOrdersStatsSection(
            items: state.items,
            onActiveTap: () => setState(
              () => _filters = const WorkOrdersListFilters(
                activity: WorkOrderActivityFilter.active,
              ),
            ),
            onFinishedTap: () => setState(
              () => _filters = const WorkOrdersListFilters(
                activity: WorkOrderActivityFilter.finished,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          WorkOrdersSearchSection(
            controller: _searchController,
            filters: _filters,
            customerOptions: customers,
            onFiltersChanged: (value) => setState(() => _filters = value),
          ),
          SizedBox(height: AppSpacing.md),
          if (state.items.isEmpty)
            EmptyStateWidget(
              message: widget.showCreateAction
                  ? 'لا توجد طلبات عمل بعد — أنشئ طلباً لبدء عرض السعر'
                  : 'لا توجد طلبات عمل بعد',
              icon: Icons.assignment_outlined,
              actionLabel: widget.showCreateAction ? 'طلب جديد' : null,
              onAction: widget.showCreateAction ? _openCreate : null,
            )
          else if (filtered.isEmpty)
            const EmptyStateWidget(
              message: 'لا توجد طلبات مطابقة للبحث أو التصفية',
              icon: Icons.search_off_rounded,
            )
          else
            ...filtered.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                child: WorkOrderListCard(
                  summary: item,
                  onTap: () => context.push(
                    AppRoutes.workOrderDetailPath(
                      widget.rolePrefix,
                      item.order.id,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(WorkOrdersListState state) {
    if (state.showBlockingSpinner) {
      return const WorkOrdersListSkeleton();
    }
    final filtered = _filtered(state.items);
    return WorkOrdersListDesktopBody(
      rolePrefix: widget.rolePrefix,
      items: state.items,
      filtered: filtered,
      filters: _filters,
      searchController: _searchController,
      customerOptions: customerOptionsFromOrders(state.items),
      selectedId: _selectedOrderId,
      showCreateAction: widget.showCreateAction,
      onFiltersChanged: (value) => setState(() => _filters = value),
      onSelect: (id) => setState(() => _selectedOrderId = id),
      onRefresh: () => context.read<WorkOrdersListBloc>().add(
        const WorkOrdersListRefreshRequested(),
      ),
      onCreate: _openCreate,
      onActiveTap: () => setState(
        () => _filters = const WorkOrdersListFilters(
          activity: WorkOrderActivityFilter.active,
        ),
      ),
      onFinishedTap: () => setState(
        () => _filters = const WorkOrdersListFilters(
          activity: WorkOrderActivityFilter.finished,
        ),
      ),
    );
  }

  List<Widget> get _headerActions => [
    if (widget.showCreateAction)
      HubHeaderIconButton(
        icon: Icons.add_rounded,
        tooltip: 'طلب جديد',
        onPressed: _openCreate,
      ),
    HubHeaderIconButton(
      icon: Icons.refresh_rounded,
      tooltip: 'تحديث',
      onPressed: () => context.read<WorkOrdersListBloc>().add(
        const WorkOrdersListRefreshRequested(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<WorkOrdersListBloc, WorkOrdersListState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          AlmoutawaSnackbar.show(context, state.message!);
        },
        builder: (context, state) {
          final body = dense
              ? _buildDesktopBody(state)
              : _buildCompactListBody(state);

          if (widget.embedInParent) {
            if (dense || !widget.showCreateAction) return body;
            return Stack(
              children: [
                body,
                Positioned(
                  left: AppSpacing.containerPadding,
                  bottom: AppSpacing.containerPadding,
                  child: GradientFab(
                    onPressed: _openCreate,
                    icon: Icons.add_rounded,
                    tooltip: 'طلب جديد',
                  ),
                ),
              ],
            );
          }

          return RoleDashboardScaffold(
            title: 'طلبات العمل',
            subtitle: 'عروض الأسعار والاتفاقيات',
            accentColor: AppColors.secondary,
            contentMaxWidth: dense ? double.infinity : null,
            appBarActions: _headerActions,
            floatingActionButton: widget.showCreateAction
                ? GradientFab(
                    onPressed: _openCreate,
                    icon: Icons.add_rounded,
                    tooltip: 'طلب جديد',
                  )
                : null,
            body: body,
          );
        },
      ),
    );
  }
}
