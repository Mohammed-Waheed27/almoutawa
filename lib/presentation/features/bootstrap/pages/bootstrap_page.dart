import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/shared/widgets/layout/hub_greeting.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/shared/widgets/navigation/glass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';

/// Dev bootstrap — role picker until all flows are auth-gated.
class BootstrapPage extends StatelessWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      appBarMode: AlmoutawaAppBarMode.none,
      header: const HubGreeting(
        displayName: 'مطور',
        subtitle: 'اختر نوع المستخدم للمعاينة',
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.containerPadding),
        children: [
          PortalListRow(
            title: UserRole.salesRep.arabicLabel,
            subtitle: 'عروض الأسعار، العملاء، الطلبات',
            statusColor: AppColors.secondary,
            leading: const HubIconWell(
              icon: Icons.storefront_outlined,
              color: AppColors.secondary,
            ),
            onTap: () => context.push(AppRoutes.salesDashboard),
          ),
          SizedBox(height: AppSpacing.stackGap),
          PortalListRow(
            title: UserRole.admin.arabicLabel,
            subtitle: 'المندوبين، المنتجات، التقارير',
            statusColor: AppColors.primaryContainer,
            leading: const HubIconWell(
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.primaryContainer,
            ),
            onTap: () => context.push(AppRoutes.adminDashboard),
          ),
          SizedBox(height: AppSpacing.stackGap),
          PortalListRow(
            title: UserRole.productionManager.arabicLabel,
            subtitle: 'طلبات العمل، المصنع، التصنيع والحالات',
            statusColor: AppColors.onTertiaryContainer,
            leading: const HubIconWell(
              icon: Icons.precision_manufacturing_outlined,
              color: AppColors.onTertiaryContainer,
            ),
            onTap: () => context.push(AppRoutes.productionDashboard),
          ),
          SizedBox(height: AppSpacing.stackGap),
          PortalListRow(
            title: UserRole.deliveryWorker.arabicLabel,
            subtitle: 'استلام الطلبات الجاهزة وتسليمها',
            statusColor: AppColors.secondaryContainer,
            leading: const HubIconWell(
              icon: Icons.local_shipping_outlined,
              color: AppColors.secondaryContainer,
            ),
            onTap: () => context.push(AppRoutes.deliveryDashboard),
          ),
          SizedBox(height: AppSpacing.sectionMargin),
          AlmoutawaButton(
            label: 'تسجيل الدخول',
            icon: Icons.login_rounded,
            onPressed: () => context.push(AppRoutes.login),
          ),
          SizedBox(height: AppSpacing.lg),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status != AuthStatus.authenticated) {
                return const SizedBox.shrink();
              }
              return AlmoutawaButton(
                label: 'تسجيل الخروج',
                icon: Icons.logout_rounded,
                variant: AlmoutawaButtonVariant.tertiaryText,
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
              );
            },
          ),
        ],
      ),
    );
  }
}
