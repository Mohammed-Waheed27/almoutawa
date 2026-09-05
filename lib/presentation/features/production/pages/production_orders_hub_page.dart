import 'package:flutter/material.dart';

import '../../../widgets/role_tab_scaffold.dart';
import '../../work_orders/pages/work_orders_list_page.dart';

/// Production orders tab — commercial work orders (no create).
class ProductionOrdersHubPage extends StatelessWidget {
  const ProductionOrdersHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleTabScaffold(
      title: 'طلبات العمل',
      subtitle: 'تشغيل المصنع',
      constrainBody: false,
      body: WorkOrdersListPage(
        rolePrefix: 'production',
        embedInParent: true,
        showCreateAction: false,
      ),
    );
  }
}
