import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../products/bloc/products_list_bloc.dart';
import '../../products/widgets/products_list_skeleton.dart';
import '../widgets/work_order_product_pick_card.dart';

/// Full-screen product catalog for quote/agreement line picking (not a dialog).
class WorkOrderProductPickerPage extends StatefulWidget {
  const WorkOrderProductPickerPage({super.key, required this.rolePrefix});

  final String rolePrefix;

  @override
  State<WorkOrderProductPickerPage> createState() =>
      _WorkOrderProductPickerPageState();
}

class _WorkOrderProductPickerPageState
    extends State<WorkOrderProductPickerPage> {
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
      context.read<ProductsListBloc>().add(
        const ProductsListLoadMoreRequested(),
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

  bool _matches(Product product) {
    if (_query.isEmpty) return true;
    final haystack =
        '${product.name} ${product.description ?? ''} ${product.priceLabel}'
            .toLowerCase();
    return haystack.contains(_query);
  }

  Future<void> _openDetails(Product product) async {
    await context.push(
      AppRoutes.workOrderProductDetailPath(widget.rolePrefix, product.id),
      extra: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return RoleDashboardScaffold(
      title: 'اختيار منتج',
      showBackButton: true,
      contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
      body: BlocConsumer<ProductsListBloc, ProductsListState>(
        listenWhen: (p, c) => p.message != c.message,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state.showBlockingSpinner) {
            return const ProductsListSkeleton();
          }

          final filtered = state.products.where(_matches).toList();
          final pad = dense
              ? DesktopUiTokens.pagePadding
              : AppSpacing.containerPadding;

          return RefreshIndicator(
            color: AppColors.secondaryContainer,
            backgroundColor: AppColors.surfaceContainerHighest,
            onRefresh: () async {
              context.read<ProductsListBloc>().add(
                const ProductsListRefreshRequested(),
              );
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(pad),
              children: [
                Text(
                  'اضغط لاختيار المنتج، أو افتح التفاصيل للمعاينة',
                  style: AppTypography.caption().copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: dense ? DesktopUiTokens.label : null,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapSm : AppSpacing.sm),
                AlmoutawaSearchField(
                  controller: _searchController,
                  hint: 'ابحث باسم المنتج أو الوصف',
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    message: 'لا توجد منتجات مطابقة',
                    icon: Icons.inventory_2_outlined,
                  )
                else if (dense)
                  ...filtered.map(
                    (product) => DesktopMasterListTile(
                      title: product.name,
                      subtitle: product.priceLabel,
                      onTap: () => context.pop(product),
                      trailing: AlmoutawaButton(
                        label: 'تفاصيل',
                        variant: AlmoutawaButtonVariant.tertiaryText,
                        size: AlmoutawaButtonSize.sm,
                        expanded: false,
                        onPressed: () => _openDetails(product),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (product) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: WorkOrderProductPickCard(
                        product: product,
                        onSelect: () => context.pop(product),
                        onViewDetails: () => _openDetails(product),
                      ),
                    ),
                  ),
                ListLoadMoreFooter(
                  isLoading: state.isLoadingMore,
                  hasMore: state.hasMore,
                  itemCount: state.products.length,
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
