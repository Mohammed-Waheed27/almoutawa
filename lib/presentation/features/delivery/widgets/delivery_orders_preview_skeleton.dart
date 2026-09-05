import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/delivery_order.dart';
import 'delivery_order_card.dart';

class DeliveryOrdersPreviewSkeleton extends StatelessWidget {
  const DeliveryOrdersPreviewSkeleton({super.key, this.itemCount = 2});

  final int itemCount;

  static final _placeholderOrders = List.generate(
    2,
    (index) => DeliveryOrder(
      id: 'preview-skeleton-$index',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _placeholderOrders
            .take(itemCount)
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
