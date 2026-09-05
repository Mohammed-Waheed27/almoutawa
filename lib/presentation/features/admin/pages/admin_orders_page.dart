import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../delivery/pages/orders_list_page.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListPage(
      title: 'جميع الطلبات',
      subtitle: 'عرض كل طلبات النظام وتأكيد التسليم',
      emptyMessage: 'لا توجد طلبات مسجلة حالياً',
      orderDetailPath: AppRoutes.adminOrderDetailPath,
      useSubPageScaffold: true,
    );
  }
}
