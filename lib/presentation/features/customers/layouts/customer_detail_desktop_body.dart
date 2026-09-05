import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/customer.dart';
import '../sections/customer_info_section.dart';
import '../sections/customer_ledger_section.dart';
import '../sections/customer_orders_section.dart';

/// Expanded customer detail — header strip + dense tabs (not softGradient phone cards).
class CustomerDetailDesktopBody extends StatelessWidget {
  const CustomerDetailDesktopBody({
    super.key,
    required this.customer,
    required this.ledgerEntries,
    required this.orders,
    required this.selectedTab,
    required this.onTabSelected,
    required this.canEdit,
    required this.onEdit,
    required this.onOrderTap,
    required this.onRefresh,
    this.onExportStatement,
  });

  final Customer customer;
  final List<CustomerAccountEntry> ledgerEntries;
  final List<CommercialOrderSummary> orders;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final bool canEdit;
  final VoidCallback onEdit;
  final ValueChanged<String> onOrderTap;
  final Future<void> Function() onRefresh;
  final VoidCallback? onExportStatement;

  static const _tabs = ['البيانات', 'الطلبات', 'كشف الحساب'];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.secondaryContainer,
      backgroundColor: AppColors.surfaceContainerHighest,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
        children: [
          DesktopEntityHeaderStrip(
            title: customer.displayName,
            subtitle: customer.primaryPhone,
            badge: customer.type.arabicLabel,
            icon: Icons.person_outline_rounded,
            trailing: canEdit
                ? AlmoutawaButton(
                    label: 'تعديل',
                    icon: Icons.edit_rounded,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    variant: AlmoutawaButtonVariant.secondaryGlass,
                    onPressed: onEdit,
                  )
                : null,
            metrics: [
              if (customer.governorate != null &&
                  customer.governorate!.trim().isNotEmpty)
                DesktopEntityMetric(
                  label: 'المحافظة',
                  value: customer.governorate!,
                ),
              if (customer.address != null &&
                  customer.address!.trim().isNotEmpty)
                DesktopEntityMetric(label: 'العنوان', value: customer.address!),
              DesktopEntityMetric(label: 'الطلبات', value: '${orders.length}'),
              DesktopEntityMetric(
                label: 'الرصيد',
                value: '${customer.accountBalance}',
              ),
              if (customer.type == CustomerType.company &&
                  customer.responsiblePerson != null &&
                  customer.responsiblePerson!.trim().isNotEmpty)
                DesktopEntityMetric(
                  label: 'المسؤول',
                  value: customer.responsiblePerson!,
                ),
            ],
          ),
          const SizedBox(height: DesktopUiTokens.gapMd),
          SegmentedTabBar(
            tabs: _tabs,
            selectedIndex: selectedTab,
            onSelected: onTabSelected,
          ),
          const SizedBox(height: DesktopUiTokens.gapMd),
          if (selectedTab == 0)
            CustomerInfoSection(customer: customer)
          else if (selectedTab == 1)
            CustomerOrdersSection(orders: orders, onOrderTap: onOrderTap)
          else
            CustomerLedgerSection(
              balance: customer.accountBalance,
              entries: ledgerEntries,
              onExportPdf: onExportStatement,
            ),
          if (canEdit && selectedTab == 0) ...[
            const SizedBox(height: DesktopUiTokens.gapMd),
            Align(
              alignment: Alignment.centerRight,
              child: AlmoutawaButton(
                label: 'تعديل بيانات العميل',
                icon: Icons.edit_rounded,
                size: AlmoutawaButtonSize.sm,
                expanded: false,
                onPressed: onEdit,
              ),
            ),
          ],
          const SizedBox(height: DesktopUiTokens.gapXl),
        ],
      ),
    );
  }
}
