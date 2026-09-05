import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/pdf/reports_pdf_builder.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/utils/bloc_refresh_wait.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/navigation/app_bar_icon_button.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/customer_detail_bloc.dart';
import '../layouts/customer_detail_desktop_body.dart';
import '../sections/customer_info_section.dart';
import '../sections/customer_ledger_section.dart';
import '../sections/customer_orders_section.dart';
import '../widgets/customer_detail_skeleton.dart';
import '../widgets/customer_profile_header.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({
    super.key,
    required this.customerId,
    required this.rolePrefix,
  });

  final String customerId;
  final String rolePrefix;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  int _selectedTab = 0;

  static const _tabs = ['البيانات', 'الطلبات', 'كشف الحساب'];

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<CustomerDetailBloc>();
    final tickBefore = bloc.state.refreshTick;
    bloc.add(const CustomerDetailRefreshRequested());
    await waitForBlocRefreshTick(
      stream: bloc.stream,
      tickBefore: tickBefore,
      readTick: (state) => state.refreshTick,
    );
  }

  void _openEdit(BuildContext context, Customer customer) {
    context.push(
      AppRoutes.customerEditPath(widget.rolePrefix, customer.id),
      extra: customer,
    );
  }

  void _openOrder(BuildContext context, String orderId) {
    context.push(AppRoutes.workOrderDetailPath(widget.rolePrefix, orderId));
  }

  Future<void> _exportStatement(
    BuildContext context, {
    required Customer customer,
    required List<CustomerAccountEntry> entries,
  }) async {
    try {
      final bytes = await ReportsPdfBuilder().buildCustomerStatement(
        customer: customer,
        entries: entries,
        balance: customer.accountBalance,
      );
      final message = await getIt<PdfShareService>().deliver(
        bytes: bytes,
        fileName: 'كشف-حساب-${customer.customerNumber}.pdf',
        subject: 'كشف حساب ${customer.displayName}',
        action: PdfDocumentAction.save,
      );
      if (!context.mounted) return;
      AlmoutawaSnackbar.show(context, message);
    } catch (_) {
      if (!context.mounted) return;
      AlmoutawaSnackbar.show(context, 'تعذر تصدير كشف الحساب');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: 'تفاصيل العميل',
        accentColor: AppColors.secondary,
        contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
        appBarActions: [
          BlocBuilder<CustomerDetailBloc, CustomerDetailState>(
            builder: (context, state) {
              final customer = state.customer;
              final session = context.read<AuthBloc>().state.session;
              final canEdit =
                  customer != null &&
                  session != null &&
                  customer.canEdit(session);

              if (!canEdit) return const SizedBox.shrink();

              return AppBarHeaderIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'تعديل',
                onPressed: () => _openEdit(context, customer),
              );
            },
          ),
        ],
        body: BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
          listenWhen: (previous, current) =>
              previous.message != current.message,
          listener: (context, state) {
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
          },
          builder: (context, state) {
            if (state.showBlockingSpinner) {
              return const CustomerDetailSkeleton();
            }

            final customer = state.customer;
            if (customer == null) {
              return const Center(child: Text('تعذر تحميل بيانات العميل'));
            }

            final session = context.read<AuthBloc>().state.session;
            final canEdit = session != null && customer.canEdit(session);

            if (dense) {
              return CustomerDetailDesktopBody(
                customer: customer,
                ledgerEntries: state.ledgerEntries,
                orders: state.orders,
                selectedTab: _selectedTab,
                onTabSelected: (index) => setState(() => _selectedTab = index),
                canEdit: canEdit,
                onEdit: () => _openEdit(context, customer),
                onOrderTap: (orderId) => _openOrder(context, orderId),
                onRefresh: () => _refresh(context),
                onExportStatement: () => _exportStatement(
                  context,
                  customer: customer,
                  entries: state.ledgerEntries,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.containerPadding),
                children: [
                  CustomerProfileHeader(customer: customer),
                  SizedBox(height: AppSpacing.sm),
                  SegmentedTabBar(
                    tabs: _tabs,
                    selectedIndex: _selectedTab,
                    onSelected: (index) => setState(() => _selectedTab = index),
                  ),
                  SizedBox(height: AppSpacing.md),
                  if (_selectedTab == 0)
                    CustomerInfoSection(customer: customer)
                  else if (_selectedTab == 1)
                    CustomerOrdersSection(
                      orders: state.orders,
                      onOrderTap: (orderId) => _openOrder(context, orderId),
                    )
                  else
                    CustomerLedgerSection(
                      balance: customer.accountBalance,
                      entries: state.ledgerEntries,
                      onExportPdf: () => _exportStatement(
                        context,
                        customer: customer,
                        entries: state.ledgerEntries,
                      ),
                    ),
                  if (canEdit && _selectedTab == 0) ...[
                    SizedBox(height: AppSpacing.md),
                    AlmoutawaButton(
                      label: 'تعديل بيانات العميل',
                      icon: Icons.edit_rounded,
                      onPressed: () => _openEdit(context, customer),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
