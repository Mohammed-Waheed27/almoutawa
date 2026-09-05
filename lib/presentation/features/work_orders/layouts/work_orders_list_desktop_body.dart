import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/layout/master_detail_desktop_shell.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../sections/work_orders_stats_section.dart';
import '../widgets/work_orders_list_filters.dart';
import '../widgets/work_orders_search_section.dart';

/// Expanded work-orders hub — filters sidebar + master list + preview pane.
class WorkOrdersListDesktopBody extends StatelessWidget {
  const WorkOrdersListDesktopBody({
    super.key,
    required this.rolePrefix,
    required this.items,
    required this.filtered,
    required this.filters,
    required this.searchController,
    required this.customerOptions,
    required this.selectedId,
    required this.showCreateAction,
    required this.onFiltersChanged,
    required this.onSelect,
    required this.onRefresh,
    required this.onCreate,
    required this.onActiveTap,
    required this.onFinishedTap,
  });

  final String rolePrefix;
  final List<CommercialOrderSummary> items;
  final List<CommercialOrderSummary> filtered;
  final WorkOrdersListFilters filters;
  final TextEditingController searchController;
  final List<WorkOrderCustomerFilterOption> customerOptions;
  final String? selectedId;
  final bool showCreateAction;
  final ValueChanged<WorkOrdersListFilters> onFiltersChanged;
  final ValueChanged<String?> onSelect;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final VoidCallback onActiveTap;
  final VoidCallback onFinishedTap;

  CommercialOrderSummary? get _selected {
    if (selectedId == null) return null;
    for (final item in filtered) {
      if (item.order.id == selectedId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailDesktopShell(
      sidebarWidth: DesktopUiTokens.filterSidebarWidth,
      masterWidth: DesktopUiTokens.masterListMaxWidth,
      sidebar: _FiltersSidebar(
        items: items,
        filters: filters,
        searchController: searchController,
        customerOptions: customerOptions,
        showCreateAction: showCreateAction,
        onFiltersChanged: onFiltersChanged,
        onRefresh: onRefresh,
        onCreate: onCreate,
        onActiveTap: onActiveTap,
        onFinishedTap: onFinishedTap,
      ),
      master: _MasterList(
        filtered: filtered,
        itemsEmpty: items.isEmpty,
        showCreateAction: showCreateAction,
        selectedId: selectedId,
        onSelect: onSelect,
        onCreate: onCreate,
      ),
      detail: _selected == null
          ? null
          : _DetailPreview(summary: _selected!, rolePrefix: rolePrefix),
    );
  }
}

class _FiltersSidebar extends StatelessWidget {
  const _FiltersSidebar({
    required this.items,
    required this.filters,
    required this.searchController,
    required this.customerOptions,
    required this.showCreateAction,
    required this.onFiltersChanged,
    required this.onRefresh,
    required this.onCreate,
    required this.onActiveTap,
    required this.onFinishedTap,
  });

  final List<CommercialOrderSummary> items;
  final WorkOrdersListFilters filters;
  final TextEditingController searchController;
  final List<WorkOrderCustomerFilterOption> customerOptions;
  final bool showCreateAction;
  final ValueChanged<WorkOrdersListFilters> onFiltersChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final VoidCallback onActiveTap;
  final VoidCallback onFinishedTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      children: [
        Text(
          'طلبات العمل',
          style: AppTypography.headlineSm().copyWith(
            fontSize: DesktopUiTokens.pageTitle,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: DesktopUiTokens.gapMd),
        WorkOrdersStatsSection(
          items: items,
          onActiveTap: onActiveTap,
          onFinishedTap: onFinishedTap,
        ),
        const SizedBox(height: DesktopUiTokens.gapMd),
        WorkOrdersSearchSection(
          controller: searchController,
          filters: filters,
          customerOptions: customerOptions,
          onFiltersChanged: onFiltersChanged,
        ),
        const SizedBox(height: DesktopUiTokens.gapLg),
        if (showCreateAction)
          AlmoutawaButton(
            label: 'طلب جديد',
            icon: Icons.add_rounded,
            onPressed: onCreate,
          ),
        const SizedBox(height: DesktopUiTokens.gapSm),
        AlmoutawaButton(
          label: 'تحديث',
          icon: Icons.refresh_rounded,
          variant: AlmoutawaButtonVariant.secondaryGlass,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _MasterList extends StatelessWidget {
  const _MasterList({
    required this.filtered,
    required this.itemsEmpty,
    required this.showCreateAction,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
  });

  final List<CommercialOrderSummary> filtered;
  final bool itemsEmpty;
  final bool showCreateAction;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (itemsEmpty) {
      return EmptyStateWidget(
        message: showCreateAction
            ? 'لا توجد طلبات عمل بعد — أنشئ طلباً لبدء عرض السعر'
            : 'لا توجد طلبات عمل بعد',
        icon: Icons.assignment_outlined,
        actionLabel: showCreateAction ? 'طلب جديد' : null,
        onAction: showCreateAction ? onCreate : null,
      );
    }
    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        message: 'لا توجد طلبات مطابقة للبحث أو التصفية',
        icon: Icons.search_off_rounded,
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final selected = item.order.id == selectedId;
        return DesktopMasterListTile(
          selected: selected,
          title: item.order.orderNumber,
          subtitle:
              '${item.customer.displayName} · ${item.order.phase.arabicLabel}',
          trailing: Icon(
            Icons.chevron_left_rounded,
            size: DesktopUiTokens.iconSize,
            color: AppColors.onSurfaceVariant,
          ),
          onTap: () => onSelect(item.order.id),
        );
      },
    );
  }
}

class _DetailPreview extends StatelessWidget {
  const _DetailPreview({required this.summary, required this.rolePrefix});

  final CommercialOrderSummary summary;
  final String rolePrefix;

  @override
  Widget build(BuildContext context) {
    final order = summary.order;
    final customer = summary.customer;
    return Padding(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DesktopUiTokens.detailMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopEntityHeaderStrip(
                title: order.orderNumber,
                subtitle: customer.displayName,
                badge: order.phase.arabicLabel,
                icon: Icons.inventory_2_outlined,
                metrics: [
                  if (customer.phone != null && customer.phone!.isNotEmpty)
                    DesktopEntityMetric(
                      label: 'الهاتف',
                      value: customer.phone!,
                    ),
                  DesktopEntityMetric(
                    label: 'المرحلة',
                    value: order.phase.arabicLabel,
                  ),
                ],
              ),
              const SizedBox(height: DesktopUiTokens.gapLg),
              AlmoutawaButton(
                label: 'فتح التفاصيل والمستندات',
                icon: Icons.open_in_new_rounded,
                onPressed: () => context.push(
                  AppRoutes.workOrderDetailPath(rolePrefix, order.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
