import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/products_list_bloc.dart';
import '../layouts/products_list_desktop_body.dart';
import '../widgets/product_list_card.dart';
import '../widgets/products_list_skeleton.dart';
import '../widgets/products_search_section.dart';

class AdminProductsListPage extends StatefulWidget {
  const AdminProductsListPage({super.key});

  @override
  State<AdminProductsListPage> createState() => _AdminProductsListPageState();
}

class _AdminProductsListPageState extends State<AdminProductsListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
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

  Future<void> _openProductForm() async {
    final saved = await context.push<Product?>(AppRoutes.adminProductForm);
    if (saved != null && mounted) {
      context.read<ProductsListBloc>().add(ProductsListProductSaved(saved));
    }
  }

  Future<void> _openProductEdit(Product product) async {
    final saved = await context.push<Product?>(
      AppRoutes.adminProductEditPath(product.id),
      extra: product,
    );
    if (saved != null && mounted) {
      context.read<ProductsListBloc>().add(ProductsListProductSaved(saved));
    }
  }

  Widget _buildCompactBody(ProductsListState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductsListBloc>().add(
          const ProductsListRefreshRequested(),
        );
        await context.read<ProductsListBloc>().stream.firstWhere(
          (next) =>
              next.status != ProductsListStatus.loading ||
              next.products.isNotEmpty,
        );
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ShellScrollInsets.tabListPadding(context),
        children: [
          ProductsSearchSection(
            controller: _searchController,
            onChanged: (query) => context.read<ProductsListBloc>().add(
              ProductsListSearchChanged(query),
            ),
          ),
          if (state.products.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '${state.filteredProducts.length} منتج مطابق للفلاتر الحالية',
                style: AppTypography.labelMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          if (state.products.isEmpty)
            const EmptyStateWidget(
              message: 'لا توجد منتجات — أضف أول منتج',
              icon: Icons.door_sliding_outlined,
            )
          else ...[
            ...state.filteredProducts.map(
              (product) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                child: ProductListCard(
                  product: product,
                  onTap: () => context.push(
                    AppRoutes.adminProductDetailPath(product.id),
                    extra: product,
                  ),
                  onEdit: () => _openProductEdit(product),
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
        ],
      ),
    );
  }

  Widget _buildDesktopBody(ProductsListState state) {
    return ProductsListDesktopBody(
      products: state.products,
      filtered: state.filteredProducts,
      searchController: _searchController,
      selectedId: _selectedId,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      totalCount: state.totalCount,
      onSearchChanged: (query) => context.read<ProductsListBloc>().add(
        ProductsListSearchChanged(query),
      ),
      onSelect: (id) => setState(() => _selectedId = id),
      onCreate: _openProductForm,
      onRefresh: () => context.read<ProductsListBloc>().add(
        const ProductsListRefreshRequested(
          showSkeleton: SkeletonRefresh.showSkeleton,
        ),
      ),
      onEdit: _openProductEdit,
      scrollController: _scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthBloc>().state.session;
    final displayName = session?.displayName ?? 'المدير';
    final roleLabel = session?.role.arabicLabel ?? UserRole.admin.arabicLabel;
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<ProductsListBloc, ProductsListState>(
        listenWhen: (previous, current) => previous.message != current.message,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          return RoleTabScaffold(
            title: 'المنتجات',
            subtitle: 'أهلاً، $displayName\n$roleLabel',
            constrainBody: !dense,
            actions: [
              HubHeaderIconButton(
                icon: Icons.add_rounded,
                tooltip: 'منتج جديد',
                onPressed: _openProductForm,
              ),
              HubHeaderIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'تحديث',
                onPressed: () => context.read<ProductsListBloc>().add(
                  const ProductsListRefreshRequested(
                    showSkeleton: SkeletonRefresh.showSkeleton,
                  ),
                ),
              ),
            ],
            body: state.showBlockingSpinner
                ? const ProductsListSkeleton()
                : (dense ? _buildDesktopBody(state) : _buildCompactBody(state)),
          );
        },
      ),
    );
  }
}
