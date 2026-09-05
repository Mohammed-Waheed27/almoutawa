import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/navigation/navigation.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../core/utils/bloc_refresh_wait.dart';
import '../../../../domain/entities/product.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/product_detail_bloc.dart';
import '../sections/product_detail_colors_section.dart';
import '../sections/product_detail_overview_section.dart';
import '../sections/product_detail_properties_section.dart';
import '../widgets/product_detail_header.dart';
import '../widgets/product_detail_skeleton.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.readOnly = false,
  });

  final String productId;

  /// When true (e.g. quote product picker), hide admin edit actions.
  final bool readOnly;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedTab = 0;

  static const _tabs = ['نظرة عامة', 'الألوان', 'المواصفات'];

  Future<void> _openEdit(Product product) async {
    final saved = await context.push<Product?>(
      AppRoutes.adminProductEditPath(product.id),
      extra: product,
    );
    if (saved != null && mounted) {
      context.read<ProductDetailBloc>().add(
        ProductDetailStarted(saved.id, initialProduct: saved),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: 'تفاصيل المنتج',
        accentColor: AppColors.secondary,
        contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
        appBarActions: [
          if (!widget.readOnly)
            BlocBuilder<ProductDetailBloc, ProductDetailState>(
              builder: (context, state) {
                final product = state.product;
                if (product == null) return const SizedBox.shrink();
                return AppBarHeaderIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'تعديل المنتج',
                  onPressed: () => _openEdit(product),
                );
              },
            ),
        ],
        body: BlocConsumer<ProductDetailBloc, ProductDetailState>(
          listenWhen: (previous, current) =>
              previous.message != current.message,
          listener: (context, state) {
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
          },
          builder: (context, state) {
            if (state.showBlockingSpinner) {
              return const ProductDetailSkeleton();
            }

            final product = state.product;
            if (product == null) {
              return const Center(child: Text('تعذر تحميل بيانات المنتج'));
            }

            final pad = dense
                ? DesktopUiTokens.pagePadding
                : AppSpacing.containerPadding;
            final gapSm = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;
            final gapMd = dense ? DesktopUiTokens.gapMd : AppSpacing.md;

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ProductDetailBloc>();
                final tickBefore = bloc.state.refreshTick;
                bloc.add(const ProductDetailRefreshRequested());
                await waitForBlocRefreshTick(
                  stream: bloc.stream,
                  tickBefore: tickBefore,
                  readTick: (state) => state.refreshTick,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(pad),
                children: [
                  ProductDetailHeader(product: product),
                  SizedBox(height: gapSm),
                  SegmentedTabBar(
                    tabs: _tabs,
                    selectedIndex: _selectedTab,
                    onSelected: (index) => setState(() => _selectedTab = index),
                  ),
                  SizedBox(height: gapMd),
                  switch (_selectedTab) {
                    0 => ProductDetailOverviewSection(product: product),
                    1 => ProductDetailColorsSection(product: product),
                    _ => ProductDetailPropertiesSection(product: product),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
