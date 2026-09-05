import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../customers/bloc/customers_list_bloc.dart';
import '../../customers/widgets/customers_list_skeleton.dart';
import '../widgets/work_order_customer_pick_tile.dart';

/// Full paginated customer list for selecting a client while creating an order.
class WorkOrderCustomerPickerPage extends StatefulWidget {
  const WorkOrderCustomerPickerPage({super.key});

  @override
  State<WorkOrderCustomerPickerPage> createState() =>
      _WorkOrderCustomerPickerPageState();
}

class _WorkOrderCustomerPickerPageState
    extends State<WorkOrderCustomerPickerPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<CustomersListBloc>().add(
        const CustomersListLoadMoreRequested(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool _matches(Customer customer) {
    if (_query.isEmpty) return true;
    final haystack =
        '${customer.displayName} ${customer.primaryPhone} '
                '${customer.customerNumber} ${customer.governorate ?? ''}'
            .toLowerCase();
    return haystack.contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return RoleDashboardScaffold(
      title: 'اختيار العميل',
      showBackButton: true,
      contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
      body: BlocConsumer<CustomersListBloc, CustomersListState>(
        listenWhen: (p, c) => p.message != c.message,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state.showBlockingSpinner) {
            return const CustomersListSkeleton();
          }

          final filtered = state.customers.where(_matches).toList();
          final pad = dense
              ? DesktopUiTokens.pagePadding
              : AppSpacing.containerPadding;

          return RefreshIndicator(
            color: AppColors.secondaryContainer,
            backgroundColor: AppColors.surfaceContainerHighest,
            onRefresh: () async {
              context.read<CustomersListBloc>().add(
                const CustomersListRefreshRequested(),
              );
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(pad),
              children: [
                AlmoutawaSearchField(
                  controller: _searchController,
                  hint: 'ابحث بالاسم أو الهاتف أو رقم العميل',
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    message: 'لا يوجد عملاء مطابقون',
                    icon: Icons.people_outline_rounded,
                  )
                else if (dense)
                  ...filtered.map(
                    (customer) => DesktopMasterListTile(
                      title: customer.displayName,
                      subtitle:
                          '${customer.primaryPhone} · ${customer.type.arabicLabel}',
                      trailing: Icon(
                        Icons.check_circle_outline_rounded,
                        size: DesktopUiTokens.iconSize,
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                      onTap: () => context.pop(customer),
                    ),
                  )
                else
                  ...filtered.map(
                    (customer) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: WorkOrderCustomerPickTile(
                        customer: customer,
                        selected: false,
                        onTap: () => context.pop(customer),
                      ),
                    ),
                  ),
                ListLoadMoreFooter(
                  isLoading: state.isLoadingMore,
                  hasMore: state.hasMore,
                  itemCount: state.customers.length,
                  totalCount: state.totalCount,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
