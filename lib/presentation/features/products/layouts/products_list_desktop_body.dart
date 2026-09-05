import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/layout/master_detail_desktop_shell.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';
import '../../../routes/app_routes.dart';
import '../widgets/products_search_section.dart';

/// Expanded products hub — search sidebar + master list + preview.
class ProductsListDesktopBody extends StatelessWidget {
  const ProductsListDesktopBody({
    super.key,
    required this.products,
    required this.filtered,
    required this.searchController,
    required this.selectedId,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalCount,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onCreate,
    required this.onRefresh,
    required this.onEdit,
    required this.scrollController,
  });

  final List<Product> products;
  final List<Product> filtered;
  final TextEditingController searchController;
  final String? selectedId;
  final bool isLoadingMore;
  final bool hasMore;
  final int? totalCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final ValueChanged<Product> onEdit;
  final ScrollController scrollController;

  Product? get _selected {
    if (selectedId == null) return null;
    for (final p in filtered) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailDesktopShell(
      sidebar: ListView(
        padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
        children: [
          Text(
            'المنتجات',
            style: AppTypography.headlineSm().copyWith(
              fontSize: DesktopUiTokens.pageTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DesktopUiTokens.gapMd),
          ProductsSearchSection(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: DesktopUiTokens.gapLg),
          AlmoutawaButton(
            label: 'منتج جديد',
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
      ),
      master: products.isEmpty
          ? const EmptyStateWidget(
              message: 'لا توجد منتجات — أضف أول منتج',
              icon: Icons.door_sliding_outlined,
            )
          : filtered.isEmpty
          ? const EmptyStateWidget(
              message: 'لا توجد منتجات مطابقة',
              icon: Icons.search_off_rounded,
            )
          : ListView.builder(
              controller: scrollController,
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return ListLoadMoreFooter(
                    isLoading: isLoadingMore,
                    hasMore: hasMore,
                    itemCount: products.length,
                    totalCount: totalCount ?? products.length,
                  );
                }
                final product = filtered[index];
                return DesktopMasterListTile(
                  selected: product.id == selectedId,
                  title: product.name,
                  subtitle: product.nameEn?.isNotEmpty == true
                      ? product.nameEn
                      : null,
                  onTap: () => onSelect(product.id),
                );
              },
            ),
      detail: _selected == null
          ? null
          : _ProductPreview(
              product: _selected!,
              onOpen: () => context.push(
                AppRoutes.adminProductDetailPath(_selected!.id),
                extra: _selected,
              ),
              onEdit: () => onEdit(_selected!),
            ),
    );
  }
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview({
    required this.product,
    required this.onOpen,
    required this.onEdit,
  });

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
                title: product.name,
                subtitle: product.nameEn,
                badge: product.pricingUnit.shortLabel,
                icon: Icons.door_sliding_outlined,
                metrics: [
                  DesktopEntityMetric(
                    label: 'السعر',
                    value: product.priceLabel,
                  ),
                  if (product.colors.isNotEmpty)
                    DesktopEntityMetric(
                      label: 'الألوان',
                      value: '${product.colors.length}',
                    ),
                ],
              ),
              const SizedBox(height: DesktopUiTokens.gapMd),
              Wrap(
                spacing: DesktopUiTokens.gapSm,
                runSpacing: DesktopUiTokens.gapSm,
                textDirection: TextDirection.rtl,
                children: [
                  AlmoutawaButton(
                    label: 'فتح التفاصيل',
                    icon: Icons.open_in_new_rounded,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: onOpen,
                  ),
                  AlmoutawaButton(
                    label: 'تعديل',
                    icon: Icons.edit_outlined,
                    variant: AlmoutawaButtonVariant.secondaryGlass,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
