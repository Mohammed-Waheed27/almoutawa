import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/adaptive_content_frame.dart';
import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/shared/widgets/layout/hub_greeting.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/shared/widgets/navigation/glass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';

class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName =
        context.watch<AuthBloc>().state.session?.displayName ?? 'المندوب';

    return RoleDashboardScaffold(
      appBarMode: AlmoutawaAppBarMode.none,
      contentMaxWidth: double.infinity,
      header: HubGreeting(
        displayName: displayName,
        subtitle: UserRole.salesRep.arabicLabel,
      ),
      body: AdaptiveContentFrame(
        mode: AdaptiveContentMode.hub,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.containerPadding),
          children: [
            PortalListRow(
              title: 'العملاء',
              subtitle: 'إضافة ومتابعة العملاء',
              statusColor: AppColors.secondary,
              leading: HubIconWell(
                icon: Icons.people_outline_rounded,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: AppSpacing.stackGap),
            PortalListRow(
              title: 'عروض الأسعار',
              subtitle: 'إنشاء ومتابعة العروض',
              statusColor: AppColors.tertiaryContainer,
              leading: HubIconWell(
                icon: Icons.request_quote_outlined,
                color: AppColors.onTertiaryContainer,
              ),
            ),
            SizedBox(height: AppSpacing.stackGap),
            PortalListRow(
              title: 'الطلبات',
              subtitle: 'متابعة الطلبات الجارية',
              statusColor: AppColors.success,
              leading: HubIconWell(
                icon: Icons.inventory_2_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
