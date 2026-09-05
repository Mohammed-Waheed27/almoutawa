import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../work_orders/pages/work_orders_list_page.dart';

/// Delivery orders tab — commercial work orders only (quotes / agreements).
class DeliveryOrdersHubPage extends StatelessWidget {
  const DeliveryOrdersHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleTabScaffold(
      title: 'طلبات العمل',
      subtitle: 'عروض الأسعار والاتفاقيات',
      constrainBody: false,
      actions: [
        HubHeaderIconButton(
          icon: Icons.add_rounded,
          tooltip: 'طلب جديد',
          onPressed: () =>
              context.push(AppRoutes.workOrderCreatePath('delivery')),
        ),
      ],
      body: const WorkOrdersListPage(
        rolePrefix: 'delivery',
        embedInParent: true,
      ),
    );
  }
}
