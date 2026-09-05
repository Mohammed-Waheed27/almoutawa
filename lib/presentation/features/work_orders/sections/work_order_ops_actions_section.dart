import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/factory_profile.dart';
import 'work_order_factory_picker_section.dart';

/// Phase actions on a commercial work order detail.
class WorkOrderOpsActionsSection extends StatelessWidget {
  const WorkOrderOpsActionsSection({
    super.key,
    required this.factories,
    required this.selectedFactoryId,
    required this.currentPhase,
    required this.busy,
    required this.onFactorySelected,
    required this.onStartManufacturing,
    required this.onComplete,
    required this.onCancel,
    this.onMarkDelivered,
    this.showFactoryPicker = true,
    this.canRequestManufacturing = false,
    this.canComplete = false,
    this.canDeliver = false,
    this.canCancel = false,
  });

  final List<FactoryProfile> factories;
  final String? selectedFactoryId;
  final CommercialOrderPhase currentPhase;
  final bool busy;
  final ValueChanged<String> onFactorySelected;
  final VoidCallback onStartManufacturing;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback? onMarkDelivered;
  final bool showFactoryPicker;
  final bool canRequestManufacturing;
  final bool canComplete;
  final bool canDeliver;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final actions = <Widget>[
      if (canRequestManufacturing)
        AlmoutawaButton(
          label: busy ? 'جاري...' : 'طلب التصنيع',
          variant: AlmoutawaButtonVariant.primaryGradient,
          icon: Icons.precision_manufacturing_rounded,
          size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
          expanded: !dense,
          onPressed: busy ? null : onStartManufacturing,
        ),
      if (canComplete)
        AlmoutawaButton(
          label: busy ? 'جاري...' : 'تأكيد الإنجاز',
          variant: AlmoutawaButtonVariant.secondaryGlass,
          icon: Icons.task_alt_rounded,
          size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
          expanded: !dense,
          onPressed: busy ? null : onComplete,
        ),
      if (canDeliver)
        AlmoutawaButton(
          label: busy ? 'جاري...' : 'تأكيد التسليم',
          variant: AlmoutawaButtonVariant.primaryGradient,
          icon: Icons.local_shipping_rounded,
          size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
          expanded: !dense,
          onPressed: busy ? null : onMarkDelivered,
        ),
      if (canCancel)
        AlmoutawaButton(
          label: busy ? 'جاري...' : 'إلغاء الطلب',
          variant: AlmoutawaButtonVariant.destructive,
          icon: Icons.cancel_outlined,
          size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
          expanded: !dense,
          onPressed: busy ? null : onCancel,
        ),
    ];

    if (!showFactoryPicker && actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showFactoryPicker)
            WorkOrderFactoryPickerSection(
              factories: factories,
              selectedFactoryId: selectedFactoryId,
              onSelected: busy ? (_) {} : onFactorySelected,
            ),
          if (actions.isNotEmpty) ...[
            SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
            if (dense)
              Wrap(
                spacing: DesktopUiTokens.gapSm,
                runSpacing: DesktopUiTokens.gapSm,
                textDirection: TextDirection.rtl,
                children: actions,
              )
            else ...[
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0)
                  SizedBox(
                    height: i == actions.length - 1 && canCancel
                        ? AppSpacing.sm
                        : AppSpacing.md,
                  ),
                actions[i],
              ],
            ],
          ],
        ],
      ),
    );
  }
}
