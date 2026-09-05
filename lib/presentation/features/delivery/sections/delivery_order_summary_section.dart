import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/info_panel_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/delivery_order.dart';

class DeliveryOrderSummarySection extends StatelessWidget {
  const DeliveryOrderSummarySection({super.key, required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return InfoPanelSection(
      title: 'تفاصيل الطلب',
      rows: [
        InfoPanelRow(
          label: 'رقم الطلب',
          value: order.orderNumber,
          highlight: true,
        ),
        InfoPanelRow(label: 'العميل', value: order.customerName),
        InfoPanelRow(
          label: 'الهاتف',
          value: order.customerPhone,
          valueColor: AppColors.secondary,
        ),
        InfoPanelRow(label: 'العنوان', value: order.customerAddress),
      ],
    );
  }
}
