import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/shared/widgets/layout/hub_greeting.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/shared/widgets/navigation/glass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName =
        context.watch<AuthBloc>().state.session?.displayName ?? 'المدير';

    return RoleDashboardScaffold(
      appBarMode: AlmoutawaAppBarMode.none,
      header: HubGreeting(
        displayName: displayName,
        subtitle: UserRole.admin.arabicLabel,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: [
          PortalListRow(
            title: 'إدارة المندوبين',
            subtitle: 'إضافة وتعديل المندوبين',
            statusColor: AppColors.primaryContainer,
            leading: HubIconWell(
              icon: Icons.groups_outlined,
              color: AppColors.primaryContainer,
            ),
          ),
          SizedBox(height: AppSpacing.stackGap),
          PortalListRow(
            title: 'المنتجات والأسعار',
            subtitle: 'إدارة المنتجات والتسعير',
            statusColor: AppColors.secondary,
            leading: HubIconWell(
              icon: Icons.inventory_2_outlined,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(height: AppSpacing.stackGap),
          PortalListRow(
            title: 'التقارير',
            subtitle: 'المبيعات والأداء',
            statusColor: AppColors.onTertiaryContainer,
            leading: HubIconWell(
              icon: Icons.analytics_outlined,
              color: AppColors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
