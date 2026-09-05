import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/adaptive_content_frame.dart';
import '../../../../core/layout/adaptive_feature_layout.dart';
import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../l10n/app_strings.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../work_orders/bloc/work_orders_list_bloc.dart';
import '../layouts/admin_home_desktop_body.dart';
import '../sections/admin_home_reports_section.dart';
import '../sections/admin_home_stats_section.dart';
import '../sections/admin_recent_work_orders_section.dart';
import '../widgets/admin_home_stats_skeleton.dart';

/// Admin shell home hub — commercial work-orders dashboard.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthBloc>().state.session;
    final displayName = session?.displayName ?? 'المدير';
    final roleLabel = session?.role.arabicLabel ?? UserRole.admin.arabicLabel;

    return BlocBuilder<WorkOrdersListBloc, WorkOrdersListState>(
      builder: (context, state) {
        final showSkeleton = state.showBlockingSpinner;

        return RoleTabScaffold(
          title: AppStrings.appName,
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
          body: AdaptiveContentFrame(
            mode: AdaptiveContentMode.hub,
            padding: EdgeInsets.zero,
            child: showSkeleton
                ? ListView(
                    padding: ShellScrollInsets.tabListPadding(context),
                    children: const [AdminHomeStatsSkeleton()],
                  )
                : AdaptiveFeatureLayout(
                    compact: ListView(
                      padding: ShellScrollInsets.tabListPadding(context),
                      children: [
                        AdminHomeStatsSection(
                          items: state.items,
                          totalCount: state.totalCount,
                        ),
                        SizedBox(height: AppSpacing.md),
                        const AdminHomeReportsSection(),
                        SizedBox(height: AppSpacing.md),
                        AdminRecentWorkOrdersSection(items: state.items),
                      ],
                    ),
                    expanded: AdminHomeDesktopBody(
                      items: state.items,
                      totalCount: state.totalCount,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
