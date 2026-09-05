import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../../../../domain/entities/delivery_order.dart';
import '../bloc/delivery_orders_bloc.dart';
import '../sections/delivery_order_summary_section.dart';
import '../widgets/delivery_order_detail_skeleton.dart';

class DeliveryOrderDetailPage extends StatefulWidget {
  const DeliveryOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryOrderDetailPage> createState() =>
      _DeliveryOrderDetailPageState();
}

class _DeliveryOrderDetailPageState extends State<DeliveryOrderDetailPage> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: 'تفاصيل التسليم',
        body: BlocConsumer<DeliveryOrdersBloc, DeliveryOrdersState>(
          listenWhen: (previous, current) =>
              previous.actionMessage != current.actionMessage ||
              previous.message != current.message,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.pop();
            }
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
          },
          builder: (context, state) {
            if (state.showBlockingSpinner) {
              return const DeliveryOrderDetailSkeleton();
            }

            final DeliveryOrder? order = state.orders
                .where((item) => item.id == widget.orderId)
                .fold<DeliveryOrder?>(
                  null,
                  (previous, element) => previous ?? element,
                );

            if (order == null) {
              return const Center(child: Text('الطلب غير متاح'));
            }

            final isDelivering =
                state.status == DeliveryOrdersStatus.delivering;
            final canDeliver = order.status == ManufacturingOrderStatus.ready;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.containerPadding),
                    children: [
                      DeliveryOrderSummarySection(order: order),
                      if (canDeliver) ...[
                        SizedBox(height: AppSpacing.sectionMargin),
                        AlmoutawaTextField(
                          controller: _notesController,
                          label: 'ملاحظات التسليم (اختياري)',
                          hint: 'مثال: سلّم للأمن، الطابق الثالث...',
                          maxLines: 3,
                          readOnly: isDelivering,
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                        ),
                      ],
                    ],
                  ),
                ),
                if (canDeliver)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.all(
                        AppSpacing.containerPadding,
                      ),
                      child: AlmoutawaButton(
                        label: isDelivering
                            ? 'جاري التأكيد...'
                            : 'تأكيد التسليم',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: isDelivering
                            ? null
                            : () {
                                context.read<DeliveryOrdersBloc>().add(
                                  DeliveryOrderDeliverRequested(
                                    orderId: order.id,
                                    deliveryNotes:
                                        _notesController.text.trim().isEmpty
                                        ? null
                                        : _notesController.text.trim(),
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
