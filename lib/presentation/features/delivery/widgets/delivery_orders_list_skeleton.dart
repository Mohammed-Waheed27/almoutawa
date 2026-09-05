import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_spacing.dart';
import '../widgets/delivery_order_card.dart';
import '../../../../domain/entities/delivery_order.dart';

class DeliveryOrdersListSkeleton extends StatelessWidget {
  const DeliveryOrdersListSkeleton({super.key});

  static final _placeholderOrders = List.generate(
    4,
    (index) => DeliveryOrder(
      id: 'skeleton-$index',
      orderNumber: 'ORD-000',
      customerName: 'اسم العميل',
      customerPhone: '01000000000',
      customerAddress: 'العنوان',
      status: ManufacturingOrderStatus.ready,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.sm,
          AppSpacing.containerPadding,
          AppSpacing.sectionMargin,
        ),
        children: _placeholderOrders
            .map(
              (order) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
                child: DeliveryOrderCard(order: order, onTap: () {}),
              ),
            )
            .toList(),
      ),
    );
  }
}
