import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../routes/app_routes.dart';
import '../sections/admin_home_reports_section.dart';
import '../sections/admin_home_stats_section.dart';

/// Two-pane admin home: KPI / shortcuts rail + full recent orders list.
class AdminHomeDesktopBody extends StatelessWidget {
  const AdminHomeDesktopBody({
    super.key,
    required this.items,
    required this.totalCount,
  });

  final List<CommercialOrderSummary> items;
  final int totalCount;

  void _openAllOrders(BuildContext context) {
    context.push(AppRoutes.adminWorkOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: DesktopUiTokens.filterSidebarWidth,
            child: ListView(
              children: [
                Text(
                  'نظرة سريعة',
                  style: AppTypography.titleOf(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: DesktopUiTokens.gapMd),
                AdminHomeStatsSection(items: items, totalCount: totalCount),
                const SizedBox(height: DesktopUiTokens.gapLg),
                AlmoutawaButton(
                  label: 'كل الطلبات',
                  icon: Icons.assignment_outlined,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  onPressed: () => _openAllOrders(context),
                ),
                const SizedBox(height: DesktopUiTokens.gapSm),
                AlmoutawaButton(
                  label: 'طلب جديد',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      context.push(AppRoutes.workOrderCreatePath('admin')),
                ),
                const SizedBox(height: DesktopUiTokens.gapMd),
                const AdminHomeReportsSection(),
              ],
            ),
          ),
          const SizedBox(width: DesktopUiTokens.gapLg),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(DesktopUiTokens.radiusLg),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapMd,
                      DesktopUiTokens.gapSm,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            'طلبات العمل',
                            style: AppTypography.titleOf(context).copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          totalCount > 0
                              ? '$totalCount طلب'
                              : '${items.length} طلب',
                          style: AppTypography.captionOf(
                            context,
                          ).copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        if (items.isNotEmpty) ...[
                          const SizedBox(width: DesktopUiTokens.gapSm),
                          AlmoutawaButton(
                            label: 'عرض الكل',
                            variant: AlmoutawaButtonVariant.tertiaryText,
                            size: AlmoutawaButtonSize.sm,
                            expanded: false,
                            onPressed: () => _openAllOrders(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: items.isEmpty
                        ? const EmptyStateWidget(
                            message: 'لا توجد طلبات عمل حالياً',
                            icon: Icons.request_quote_outlined,
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final summary = items[index];
                              return DesktopMasterListTile(
                                title: summary.order.orderNumber,
                                subtitle:
                                    '${summary.customer.displayName} · ${summary.order.phase.arabicLabel}',
                                trailing: Icon(
                                  Icons.chevron_left_rounded,
                                  size: DesktopUiTokens.iconSize,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                onTap: () => context.push(
                                  AppRoutes.workOrderDetailPath(
                                    'admin',
                                    summary.order.id,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
