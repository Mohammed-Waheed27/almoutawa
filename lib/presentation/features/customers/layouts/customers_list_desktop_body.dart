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
import '../../../../domain/entities/customer.dart';
import '../../../routes/app_routes.dart';
import '../widgets/customers_search_section.dart';

/// Expanded customers hub — filter sidebar + master list + preview pane.
class CustomersListDesktopBody extends StatelessWidget {
  const CustomersListDesktopBody({
    super.key,
    required this.rolePrefix,
    required this.customers,
    required this.filtered,
    required this.filter,
    required this.searchController,
    required this.selectedId,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalCount,
    required this.onFilterChanged,
    required this.onSelect,
    required this.onCreate,
    required this.onRefresh,
    required this.scrollController,
  });

  final String rolePrefix;
  final List<Customer> customers;
  final List<Customer> filtered;
  final CustomerListFilter filter;
  final TextEditingController searchController;
  final String? selectedId;
  final bool isLoadingMore;
  final bool hasMore;
  final int? totalCount;
  final ValueChanged<CustomerListFilter> onFilterChanged;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final ScrollController scrollController;

  Customer? get _selected {
    if (selectedId == null) return null;
    for (final c in filtered) {
      if (c.id == selectedId) return c;
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
            'العملاء',
            style: AppTypography.headlineSm().copyWith(
              fontSize: DesktopUiTokens.pageTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DesktopUiTokens.gapMd),
          CustomersSearchSection(
            controller: searchController,
            selectedFilter: filter,
            onFilterChanged: onFilterChanged,
          ),
          const SizedBox(height: DesktopUiTokens.gapLg),
          AlmoutawaButton(
            label: 'عميل جديد',
            icon: Icons.person_add_outlined,
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
      master: filtered.isEmpty
          ? const EmptyStateWidget(
              message: 'لا يوجد عملاء مطابقون للبحث',
              icon: Icons.people_outline_rounded,
            )
          : ListView.builder(
              controller: scrollController,
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return ListLoadMoreFooter(
                    isLoading: isLoadingMore,
                    hasMore: hasMore,
                    itemCount: customers.length,
                    totalCount: totalCount ?? customers.length,
                  );
                }
                final customer = filtered[index];
                return DesktopMasterListTile(
                  selected: customer.id == selectedId,
                  title: customer.displayName,
                  subtitle:
                      '${customer.primaryPhone} · ${customer.type.arabicLabel}',
                  onTap: () => onSelect(customer.id),
                );
              },
            ),
      detail: _selected == null
          ? null
          : _CustomerPreview(customer: _selected!, rolePrefix: rolePrefix),
    );
  }
}

class _CustomerPreview extends StatelessWidget {
  const _CustomerPreview({required this.customer, required this.rolePrefix});

  final Customer customer;
  final String rolePrefix;

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
                title: customer.displayName,
                subtitle: customer.primaryPhone,
                badge: customer.type.arabicLabel,
                icon: Icons.person_outline_rounded,
                metrics: [
                  if (customer.governorate != null)
                    DesktopEntityMetric(
                      label: 'المحافظة',
                      value: customer.governorate!,
                    ),
                  if (customer.address != null)
                    DesktopEntityMetric(
                      label: 'العنوان',
                      value: customer.address!,
                    ),
                  DesktopEntityMetric(
                    label: 'الرصيد',
                    value: '${customer.accountBalance}',
                  ),
                ],
              ),
              const SizedBox(height: DesktopUiTokens.gapLg),
              AlmoutawaButton(
                label: 'فتح التفاصيل وكشف الحساب',
                icon: Icons.open_in_new_rounded,
                onPressed: () => context.push(
                  AppRoutes.customerDetailPath(rolePrefix, customer.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
