import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../core/utils/bloc_refresh_wait.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/customer.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../bloc/customers_list_bloc.dart';
import '../layouts/customers_list_desktop_body.dart';
import '../widgets/customer_list_card.dart';
import '../widgets/customers_list_skeleton.dart';
import '../widgets/customers_search_section.dart';

class CustomersListPage extends StatefulWidget {
  const CustomersListPage({super.key, required this.rolePrefix});

  final String rolePrefix;

  @override
  State<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  CustomerListFilter _filter = CustomerListFilter.all;
  String _query = '';
  String? _selectedId;

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

  bool _matchesQuery(Customer customer) {
    if (_query.isEmpty) return true;
    final haystack =
        '${customer.displayName} ${customer.primaryPhone} '
                '${customer.governorate ?? ''} ${customer.address ?? ''}'
            .toLowerCase();
    return haystack.contains(_query);
  }

  List<Customer> _filtered(CustomersListState state) {
    return state.customers.where(_filter.matches).where(_matchesQuery).toList();
  }

  void _openCreate() {
    context.push(AppRoutes.customerFormPath(widget.rolePrefix));
  }

  Widget _buildCompactBody(CustomersListState state) {
    if (state.showBlockingSpinner) {
      return const CustomersListSkeleton();
    }

    final filtered = _filtered(state);

    return RefreshIndicator(
      color: AppColors.secondaryContainer,
      backgroundColor: AppColors.surfaceContainerHighest,
      onRefresh: () async {
        final bloc = context.read<CustomersListBloc>();
        final tickBefore = bloc.state.refreshTick;
        bloc.add(const CustomersListRefreshRequested());
        await waitForBlocRefreshTick(
          stream: bloc.stream,
          tickBefore: tickBefore,
          readTick: (state) => state.refreshTick,
        );
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ShellScrollInsets.tabListPaddingNoTop(context),
        children: [
          CustomersSearchSection(
            controller: _searchController,
            selectedFilter: _filter,
            onFilterChanged: (value) => setState(() => _filter = value),
          ),
          SizedBox(height: AppSpacing.md),
          if (filtered.isEmpty)
            const EmptyStateWidget(
              message: 'لا يوجد عملاء مطابقون للبحث',
              icon: Icons.people_outline_rounded,
            )
          else
            ...filtered.map(
              (customer) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: CustomerListCard(
                  customer: customer,
                  onTap: () => context.push(
                    AppRoutes.customerDetailPath(
                      widget.rolePrefix,
                      customer.id,
                    ),
                  ),
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
  }

  Widget _buildDesktopBody(CustomersListState state) {
    if (state.showBlockingSpinner) {
      return const CustomersListSkeleton();
    }
    return CustomersListDesktopBody(
      rolePrefix: widget.rolePrefix,
      customers: state.customers,
      filtered: _filtered(state),
      filter: _filter,
      searchController: _searchController,
      selectedId: _selectedId,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      totalCount: state.totalCount,
      onFilterChanged: (value) => setState(() => _filter = value),
      onSelect: (id) => setState(() => _selectedId = id),
      onCreate: _openCreate,
      onRefresh: () => context.read<CustomersListBloc>().add(
        const CustomersListRefreshRequested(
          showSkeleton: SkeletonRefresh.showSkeleton,
        ),
      ),
      scrollController: _scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isShellTab =
        widget.rolePrefix == 'delivery' || widget.rolePrefix == 'admin';
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<CustomersListBloc, CustomersListState>(
        listenWhen: (previous, current) => previous.message != current.message,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          final body = dense
              ? _buildDesktopBody(state)
              : _buildCompactBody(state);

          if (isShellTab) {
            return RoleTabScaffold(
              title: 'العملاء',
              subtitle: widget.rolePrefix == 'admin'
                  ? 'جميع عملاء المطاوعة'
                  : 'إدارة العملاء وكشف الحساب لكل عميل',
              constrainBody: !dense,
              actions: [
                HubHeaderIconButton(
                  icon: Icons.person_add_outlined,
                  tooltip: 'عميل جديد',
                  onPressed: _openCreate,
                ),
                HubHeaderIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'تحديث',
                  onPressed: () => context.read<CustomersListBloc>().add(
                    const CustomersListRefreshRequested(
                      showSkeleton: SkeletonRefresh.showSkeleton,
                    ),
                  ),
                ),
              ],
              body: body,
            );
          }

          return RoleDashboardScaffold(
            title: 'العملاء',
            subtitle: 'جميع عملاء المطاوعة',
            accentColor: AppColors.secondary,
            contentMaxWidth: dense ? double.infinity : null,
            body: body,
          );
        },
      ),
    );
  }
}
