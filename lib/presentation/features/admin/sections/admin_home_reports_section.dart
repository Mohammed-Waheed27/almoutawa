import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/cards/portal_list_row.dart';
import '../../../../core/shared/widgets/layout/hub_icon_well.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../routes/app_routes.dart';

class AdminHomeReportsSection extends StatelessWidget {
  const AdminHomeReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: dense ? DesktopUiTokens.gapXs : AppSpacing.sm),
          PortalListRow(
            title: 'التقارير',
            subtitle: 'نظرة عامة + أداء الموظفين والعملاء حسب الفترة',
            statusColor: AppColors.success,
            leading: const HubIconWell(
              icon: Icons.bar_chart_rounded,
              color: AppColors.success,
            ),
            onTap: () => context.push(AppRoutes.adminReports),
          ),
        ],
      ),
    );
  }
}
