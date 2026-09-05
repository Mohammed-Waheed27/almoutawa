import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/factory_profile.dart';
import '../sections/work_order_documents_section.dart';
import '../sections/work_order_ops_actions_section.dart';
import '../sections/work_order_timeline_section.dart';

/// Expanded work-order detail — outlined header + dense docs (not phone bento).
class WorkOrderDetailDesktopBody extends StatelessWidget {
  const WorkOrderDetailDesktopBody({
    super.key,
    required this.rolePrefix,
    required this.orderId,
    required this.detail,
    required this.isOpsManager,
    this.manufacturingCardsDone,
    this.factories = const [],
    this.busyAction = false,
    this.showFactoryPicker = true,
    this.canRequestManufacturing = false,
    this.canComplete = false,
    this.canDeliver = false,
    this.canCancel = false,
    this.onFactorySelected,
    this.onStartManufacturing,
    this.onComplete,
    this.onMarkDelivered,
    this.onCancel,
  });

  final String rolePrefix;
  final String orderId;
  final CommercialOrderDetail detail;
  final bool isOpsManager;
  final int? manufacturingCardsDone;
  final List<FactoryProfile> factories;
  final bool busyAction;
  final bool showFactoryPicker;
  final bool canRequestManufacturing;
  final bool canComplete;
  final bool canDeliver;
  final bool canCancel;
  final ValueChanged<String>? onFactorySelected;
  final VoidCallback? onStartManufacturing;
  final VoidCallback? onComplete;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final order = detail.order;
    final customer = detail.customer;
    final wide = MediaQuery.sizeOf(context).width >= 1280;

    final header = DesktopEntityHeaderStrip(
      title: order.orderNumber,
      subtitle: customer.displayName,
      badge: order.phase.arabicLabel,
      icon: Icons.inventory_2_outlined,
      metrics: [
        DesktopEntityMetric(
          label: 'رقم العميل',
          value: '${customer.customerNumber}',
        ),
        DesktopEntityMetric(label: 'الهاتف', value: customer.phone ?? '—'),
        DesktopEntityMetric(
          label: 'المصنع',
          value: detail.factory?.displayName ?? 'لم يُحدد',
        ),
      ],
    );

    final timeline = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(DesktopUiTokens.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesktopUiTokens.gapMd,
          vertical: DesktopUiTokens.gapSm,
        ),
        child: WorkOrderTimelineSection(phase: order.phase),
      ),
    );

    final docs = WorkOrderDocumentsSection(
      rolePrefix: rolePrefix,
      orderId: orderId,
      detail: detail,
      manufacturingCardsDone: manufacturingCardsDone,
    );

    final hasActions =
        canRequestManufacturing || canComplete || canDeliver || canCancel;
    final ops =
        (showFactoryPicker || hasActions) &&
            onFactorySelected != null &&
            onStartManufacturing != null &&
            onComplete != null &&
            onCancel != null
        ? WorkOrderOpsActionsSection(
            factories: factories,
            selectedFactoryId: order.factoryId,
            currentPhase: order.phase,
            busy: busyAction,
            showFactoryPicker: showFactoryPicker,
            canRequestManufacturing: canRequestManufacturing,
            canComplete: canComplete,
            canDeliver: canDeliver,
            canCancel: canCancel,
            onFactorySelected: onFactorySelected!,
            onStartManufacturing: onStartManufacturing!,
            onComplete: onComplete!,
            onMarkDelivered: onMarkDelivered,
            onCancel: onCancel!,
          )
        : null;

    return ListView(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      children: [
        header,
        if (detail.createdBy != null) ...[
          const SizedBox(height: DesktopUiTokens.gapSm),
          Text(
            'أنشأه: ${detail.createdBy!.displayName} · ${detail.createdBy!.roleLabelAr}',
            style: AppTypography.caption().copyWith(
              fontSize: DesktopUiTokens.label,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ],
        const SizedBox(height: DesktopUiTokens.gapMd),
        if (wide)
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    timeline,
                    if (ops != null) ...[
                      const SizedBox(height: DesktopUiTokens.gapMd),
                      ops,
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DesktopUiTokens.gapLg),
              Expanded(flex: 6, child: docs),
            ],
          )
        else ...[
          timeline,
          if (ops != null) ...[
            const SizedBox(height: DesktopUiTokens.gapMd),
            ops,
          ],
          const SizedBox(height: DesktopUiTokens.gapMd),
          docs,
        ],
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
