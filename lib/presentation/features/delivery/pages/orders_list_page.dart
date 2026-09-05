import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../bloc/delivery_orders_bloc.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/delivery_orders_list_skeleton.dart';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.orderDetailPath,
    this.useSubPageScaffold = false,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final String Function(String orderId) orderDetailPath;
  final bool useSubPageScaffold;

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<DeliveryOrdersBloc>().add(
        const DeliveryOrdersLoadMoreRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryOrdersBloc, DeliveryOrdersState>(
      listenWhen: (previous, current) =>
          previous.actionMessage != current.actionMessage ||
          previous.message != current.message,
      listener: (context, state) {
        final message = state.actionMessage ?? state.message;
        if (message != null) {
          AlmoutawaSnackbar.show(context, message);
        }
      },
      builder: (context, state) {
        final listBody = state.showBlockingSpinner
            ? const DeliveryOrdersListSkeleton()
            : RefreshIndicator(
                onRefresh: () async {
                  context.read<DeliveryOrdersBloc>().add(
                    const DeliveryOrdersRefreshRequested(),
                  );
                  await context.read<DeliveryOrdersBloc>().stream.firstWhere(
                    (next) =>
                        next.status != DeliveryOrdersStatus.loading ||
                        next.orders.isNotEmpty,
                  );
                },
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ShellScrollInsets.tabListPadding(context),
                  children: [
                    if (state.orders.isEmpty)
                      EmptyStateWidget(
                        message: widget.emptyMessage,
                        icon: Icons.local_shipping_outlined,
                      )
                    else ...[
                      ...state.orders.map(
                        (order) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSpacing.stackGap,
                          ),
                          child: DeliveryOrderCard(
                            order: order,
                            onTap: () =>
                                context.push(widget.orderDetailPath(order.id)),
                          ),
                        ),
                      ),
                      ListLoadMoreFooter(
                        isLoading: state.isLoadingMore,
                        hasMore: state.hasMore,
                        itemCount: state.orders.length,
                        totalCount: state.totalCount,
                      ),
                    ],
                  ],
                ),
              );

        final refreshAction = HubHeaderIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'تحديث',
          onPressed: () => context.read<DeliveryOrdersBloc>().add(
            const DeliveryOrdersRefreshRequested(
              showSkeleton: SkeletonRefresh.showSkeleton,
            ),
          ),
        );

        if (widget.useSubPageScaffold) {
          return RoleDashboardScaffold(
            title: widget.title,
            subtitle: widget.subtitle,
            appBarActions: [refreshAction],
            body: listBody,
          );
        }

        return RoleTabScaffold(
          title: widget.title,
          subtitle: widget.subtitle,
          actions: [refreshAction],
          body: listBody,
        );
      },
    );
  }
}
