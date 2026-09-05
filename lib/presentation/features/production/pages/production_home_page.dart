import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../delivery/widgets/delivery_home_hub_skeleton.dart';
import '../../work_orders/bloc/work_orders_list_bloc.dart';
import '../../work_orders/sections/work_orders_stats_section.dart';
import '../sections/production_recent_work_orders_section.dart';

/// Operations manager home hub — work-orders focused.
class ProductionHomePage extends StatelessWidget {
  const ProductionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthBloc>().state.session;
    final displayName = session?.displayName ?? 'مدير التشغيل';
    final roleLabel =
        session?.role.arabicLabel ?? UserRole.productionManager.arabicLabel;

    return BlocBuilder<WorkOrdersListBloc, WorkOrdersListState>(
      builder: (context, state) {
        final showSkeleton = state.showBlockingSpinner;

        return RoleTabScaffold(
          title: 'التشغيل',
          subtitle: 'أهلاً، $displayName\n$roleLabel',
          actions: [
            HubHeaderIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث',
              onPressed: () => context.read<WorkOrdersListBloc>().add(
                const WorkOrdersListRefreshRequested(),
              ),
            ),
          ],
          body: ListView(
            padding: ShellScrollInsets.tabListPadding(context),
            children: [
              if (showSkeleton)
                const DeliveryHomeHubSkeleton()
              else ...[
                WorkOrdersStatsSection(items: state.items),
                SizedBox(height: AppSpacing.md),
                ProductionRecentWorkOrdersSection(
                  items: state.items,
                  showSkeleton: false,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
