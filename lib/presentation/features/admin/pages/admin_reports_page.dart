import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/pdf/reports_pdf_builder.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/shared/widgets/navigation/navigation.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../di/injection_container.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/admin_reports_bloc.dart';
import '../sections/admin_reports_customers_section.dart';
import '../sections/admin_reports_factories_section.dart';
import '../sections/admin_reports_order_filters_section.dart';
import '../sections/admin_reports_orders_section.dart';
import '../sections/admin_reports_overview_section.dart';
import '../sections/admin_reports_period_filters_section.dart';
import '../sections/admin_reports_staff_section.dart';

/// Admin-only system reports: overview + staff + customers with period filters.
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  static const _tabs = [
    'نظرة عامة',
    'الموظفون',
    'العملاء',
    'الطلبات',
    'المصانع',
  ];

  final _searchController = TextEditingController();

  Future<void> _exportPdf(BuildContext context) async {
    final bundle = context.read<AdminReportsBloc>().state.bundle;
    if (bundle == null) {
      AlmoutawaSnackbar.show(context, 'لا توجد بيانات للتصدير بعد');
      return;
    }
    try {
      final bytes = await ReportsPdfBuilder().buildBundle(
        bundle.copyWith(
          orders: context.read<AdminReportsBloc>().state.filteredOrders,
        ),
      );
      final message = await getIt<PdfShareService>().deliver(
        bytes: bytes,
        fileName: 'تقرير-النظام.pdf',
        subject: 'تقرير النظام',
        action: PdfDocumentAction.save,
      );
      if (!context.mounted) return;
      AlmoutawaSnackbar.show(context, message);
    } catch (error) {
      if (!context.mounted) return;
      AlmoutawaSnackbar.show(context, 'تعذر تصدير التقرير');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final bloc = context.read<AdminReportsBloc>();
    final now = DateTime.now();
    final initialFrom =
        bloc.state.range.from ?? now.subtract(const Duration(days: 30));
    final initialTo = bloc.state.range.to ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialFrom, end: initialTo),
      helpText: 'اختر فترة التقرير',
      cancelText: 'إلغاء',
      confirmText: 'تطبيق',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null || !context.mounted) return;
    bloc.add(
      AdminReportsCustomRangeChanged(from: picked.start, to: picked.end),
    );
  }

  Widget _buildFiltersColumn(BuildContext context, AdminReportsState state) {
    return Column(
      children: [
        AdminReportsPeriodFiltersSection(
          selected: state.range.period,
          onPeriodSelected: (period) => context.read<AdminReportsBloc>().add(
            AdminReportsPeriodChanged(period),
          ),
          onPickCustomRange: () => _pickCustomRange(context),
        ),
        SizedBox(height: AppSpacing.sm),
        SegmentedTabBar(
          tabs: _tabs,
          selectedIndex: state.tabIndex,
          onSelected: (index) {
            if (index == 0 && _searchController.text.isNotEmpty) {
              _searchController.clear();
              context.read<AdminReportsBloc>().add(
                const AdminReportsSearchChanged(''),
              );
            }
            context.read<AdminReportsBloc>().add(AdminReportsTabChanged(index));
          },
        ),
        if (state.tabIndex != 0) ...[
          SizedBox(height: AppSpacing.sm),
          AlmoutawaSearchField(
            controller: _searchController,
            hint: state.tabIndex == 1
                ? 'بحث عن موظف...'
                : state.tabIndex == 2
                ? 'بحث عن عميل...'
                : 'بحث في التقرير...',
            onChanged: (q) => context.read<AdminReportsBloc>().add(
              AdminReportsSearchChanged(q),
            ),
          ),
        ],
        if (state.tabIndex == 3 || state.tabIndex == 4) ...[
          SizedBox(height: AppSpacing.sm),
          AdminReportsOrderFiltersSection(
            orders: state.bundle?.orders ?? const [],
            selectedPhase: state.filterPhase,
            selectedFactoryId: state.filterFactoryId,
            selectedStaffId: state.filterStaffId,
            selectedCustomerId: state.filterCustomerId,
            onPhaseSelected: (phase) => context.read<AdminReportsBloc>().add(
              AdminReportsOrderFiltersChanged(
                phase: phase,
                clearPhase: phase == null,
              ),
            ),
            onFactorySelected: (id) => context.read<AdminReportsBloc>().add(
              AdminReportsOrderFiltersChanged(
                factoryId: id,
                clearFactory: id == null,
              ),
            ),
            onStaffSelected: (id) => context.read<AdminReportsBloc>().add(
              AdminReportsOrderFiltersChanged(
                staffId: id,
                clearStaff: id == null,
              ),
            ),
            onCustomerSelected: (id) => context.read<AdminReportsBloc>().add(
              AdminReportsOrderFiltersChanged(
                customerId: id,
                clearCustomer: id == null,
              ),
            ),
            onClear: () => context.read<AdminReportsBloc>().add(
              const AdminReportsOrderFiltersCleared(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListContent(BuildContext context, AdminReportsState state) {
    return RefreshIndicator(
      color: AppColors.secondaryContainer,
      backgroundColor: AppColors.surfaceContainerHighest,
      onRefresh: () async {
        final bloc = context.read<AdminReportsBloc>();
        bloc.add(const AdminReportsRefreshed());
        await bloc.stream.firstWhere(
          (s) =>
              s.status == AdminReportsStatus.ready ||
              s.status == AdminReportsStatus.failure,
        );
      },
      child: state.showBlockingSkeleton
          ? ListView(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              children: const [AdminReportsOverviewSkeleton()],
            )
          : ListView(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              children: [
                if (state.tabIndex == 0) ...[
                  if (state.bundle != null)
                    AdminReportsOverviewSection(
                      overview: state.bundle!.overview,
                    ),
                ] else if (state.tabIndex == 1)
                  AdminReportsStaffTableSection(
                    rows: state.filteredStaff,
                    roleFilter: state.staffRoleFilter,
                    onRoleFilterChanged: (role) => context
                        .read<AdminReportsBloc>()
                        .add(AdminReportsStaffRoleFilterChanged(role)),
                    onStaffSelected: (row) =>
                        context.read<AdminReportsBloc>().add(
                          AdminReportsOrderFiltersChanged(
                            staffId: row.profileId,
                            tabIndex: 3,
                          ),
                        ),
                  )
                else if (state.tabIndex == 2)
                  AdminReportsCustomersSection(
                    rows: state.filteredCustomers,
                    onCustomerSelected: (row) =>
                        context.read<AdminReportsBloc>().add(
                          AdminReportsOrderFiltersChanged(
                            customerId: row.customerId,
                            tabIndex: 3,
                          ),
                        ),
                  )
                else if (state.tabIndex == 3)
                  AdminReportsOrdersSection(rows: state.filteredOrders)
                else
                  AdminReportsFactoriesSection(orders: state.filteredOrders),
                if (state.status == AdminReportsStatus.refreshing)
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: const LinearProgressIndicator(minHeight: 2),
                  ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.density.isExpanded;

    return RoleDashboardScaffold(
      title: 'التقارير',
      showBackButton: true,
      contentMaxWidth: isExpanded ? double.infinity : null,
      appBarActions: [
        AppBarHeaderIconButton(
          icon: Icons.save_alt_rounded,
          tooltip: 'تصدير PDF',
          onPressed: () => _exportPdf(context),
        ),
        AppBarHeaderIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'تحديث',
          onPressed: () => context.read<AdminReportsBloc>().add(
            const AdminReportsRefreshed(),
          ),
        ),
      ],
      body: BlocConsumer<AdminReportsBloc, AdminReportsState>(
        listenWhen: (p, c) => p.message != c.message && c.message != null,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          final filters = _buildFiltersColumn(context, state);
          final listContent = _buildListContent(context, state);

          if (isExpanded) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: DesktopUiTokens.masterSidebarWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border(
                          left: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(
                          DesktopUiTokens.pagePadding,
                        ),
                        children: [filters],
                      ),
                    ),
                  ),
                  Expanded(child: listContent),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.sm,
                  AppSpacing.containerPadding,
                  0,
                ),
                child: filters,
              ),
              SizedBox(height: AppSpacing.sm),
              Expanded(child: listContent),
            ],
          );
        },
      ),
    );
  }
}
