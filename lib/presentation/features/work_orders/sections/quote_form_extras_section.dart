import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/commercial_order.dart';

class QuoteFormExtrasSection extends StatelessWidget {
  const QuoteFormExtrasSection({
    super.key,
    required this.charges,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final List<DocumentExtraCharge> charges;
  final ValueChanged<List<DocumentExtraCharge>> onChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'مصاريف وبنود إضافية',
                  style: AppTypography.titleSm(),
                  textAlign: TextAlign.right,
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'إضافة مصروف',
                  style: AppTypography.labelMd().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onPrimaryFixedVariant,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (charges.isEmpty)
            Text(
              'مثل النقل أو التركيب أو أي تكلفة إضافية. اختياري.',
              style: AppTypography.caption().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            )
          else
            for (var i = 0; i < charges.length; i++) ...[
              _ExtraChargeRow(
                key: ValueKey('extra-${charges[i].id ?? 'row-$i'}'),
                charge: charges[i],
                onChanged: (updated) {
                  final next = [...charges];
                  next[i] = DocumentExtraCharge(
                    id: updated.id,
                    name: updated.name,
                    amount: updated.amount,
                    sortOrder: i,
                  );
                  onChanged(next);
                },
                onRemove: () => onRemove(i),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _ExtraChargeRow extends StatefulWidget {
  const _ExtraChargeRow({
    super.key,
    required this.charge,
    required this.onChanged,
    required this.onRemove,
  });

  final DocumentExtraCharge charge;
  final ValueChanged<DocumentExtraCharge> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ExtraChargeRow> createState() => _ExtraChargeRowState();
}

class _ExtraChargeRowState extends State<_ExtraChargeRow> {
  late final TextEditingController _name;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.charge.name);
    _amount = TextEditingController(
      text: widget.charge.amount == 0 ? '' : '${widget.charge.amount}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      DocumentExtraCharge(
        id: widget.charge.id,
        name: _name.text,
        amount: double.tryParse(_amount.text) ?? 0,
        sortOrder: widget.charge.sortOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: AlmoutawaTextField(
            controller: _name,
            label: 'الوصف',
            hint: 'مثال: مصاريف نقل',
            dense: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _emit(),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: AlmoutawaTextField(
            controller: _amount,
            label: 'القيمة ر.س',
            hint: 'مثال: 250',
            dense: true,
            textInputAction: TextInputAction.next,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _emit(),
          ),
        ),
        IconButton(
          onPressed: widget.onRemove,
          icon: Icon(Icons.delete_outline, color: AppColors.error),
        ),
      ],
    );
  }
}
