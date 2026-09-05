import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import 'orders_list_page.dart';

class DeliveryOrdersPage extends StatelessWidget {
  const DeliveryOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersListPage(
      title: 'الطلبات الجاهزة',
      subtitle: 'استلام وتسليم الطلبات المخصصة لك',
      emptyMessage: 'لا توجد طلبات جاهزة للتسليم حالياً',
      orderDetailPath: AppRoutes.deliveryOrderDetailPath,
    );
  }
}
