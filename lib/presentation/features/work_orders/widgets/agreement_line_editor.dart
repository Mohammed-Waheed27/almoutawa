import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dimension_cm.dart';
import '../../../../core/utils/sar_money.dart';
import '../../../../domain/entities/commercial_order.dart';

/// Dense agreement line editor — same sizing rhythm as [QuoteLineEditor].
class AgreementLineEditor extends StatefulWidget {
  const AgreementLineEditor({
    super.key,
    required this.index,
    required this.line,
    required this.onChanged,
    required this.onRemove,
    required this.onPickProduct,
  });

  final int index;
  final AgreementLineDraft line;
  final ValueChanged<AgreementLineDraft> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onPickProduct;

  @override
  State<AgreementLineEditor> createState() => _AgreementLineEditorState();
}

class _AgreementLineEditorState extends State<AgreementLineEditor> {
  late final TextEditingController _descController;
  late final TextEditingController _qtyController;
  late final TextEditingController _colorController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _unitController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.line.description);
    _qtyController = TextEditingController(
      text: widget.line.quantity == null
          ? ''
          : DimensionCm.format(widget.line.quantity!),
    );
    _colorController = TextEditingController(text: widget.line.color ?? '');
    _widthController = TextEditingController(
      text: DimensionCm.format(widget.line.widthCm ?? 0),
    );
    _heightController = TextEditingController(
      text: DimensionCm.format(widget.line.heightCm ?? 0),
    );
    _unitController = TextEditingController(
      text: SarMoney.amountInput(widget.line.unitPrice),
    );
    _notesController = TextEditingController(text: widget.line.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant AgreementLineEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line == widget.line) return;

    final replaced =
        oldWidget.line.productId != widget.line.productId ||
        oldWidget.line.description != widget.line.description ||
        oldWidget.line.quantity != widget.line.quantity ||
        oldWidget.line.widthCm != widget.line.widthCm ||
        oldWidget.line.heightCm != widget.line.heightCm ||
        oldWidget.line.unitPrice != widget.line.unitPrice ||
        oldWidget.line.color != widget.line.color ||
        oldWidget.line.notes != widget.line.notes;

    if (!replaced) return;

    _descController.text = widget.line.description;
    _qtyController.text = widget.line.quantity == null
        ? ''
        : DimensionCm.format(widget.line.quantity!);
    _colorController.text = widget.line.color ?? '';
    _widthController.text = DimensionCm.format(widget.line.widthCm ?? 0);
    _heightController.text = DimensionCm.format(widget.line.heightCm ?? 0);
    _unitController.text = SarMoney.amountInput(widget.line.unitPrice);
    _notesController.text = widget.line.notes ?? '';
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _colorController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _parsePrice(String value) {
    final normalized = value
        .replaceAll(',', '')
        .replaceAll(SarMoney.symbol, '')
        .replaceAll(SarMoney.code, '')
        .trim();
    if (normalized.isEmpty) return 0;
    return DimensionCm.round(double.tryParse(normalized) ?? 0);
  }

  double? _parseOptionalQty(String value) {
    final t = value.trim();
    if (t.isEmpty) return null;
    return DimensionCm.parse(t);
  }

  AgreementLineDraft _draftFromControllers() {
    return AgreementLineDraft(
      productId: widget.line.productId,
      description: _descController.text,
      quantity: _parseOptionalQty(_qtyController.text),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      widthCm: () {
        final v = DimensionCm.parse(_widthController.text);
        return v <= 0 ? null : v;
      }(),
      heightCm: () {
        final v = DimensionCm.parse(_heightController.text);
        return v <= 0 ? null : v;
      }(),
      unitPrice: _parsePrice(_unitController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      sortOrder: widget.line.sortOrder,
    );
  }

  void _emit() {
    widget.onChanged(_draftFromControllers());
  }

  @override
  Widget build(BuildContext context) {
    final computed = _draftFromControllers();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    'البند ${widget.index + 1}',
                    style: AppTypography.labelBold(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.onPickProduct();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    'من المنتجات',
                    style: AppTypography.labelMd().copyWith(
                      color: AppColors.onPrimaryFixedVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  tooltip: 'حذف البند',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            AlmoutawaTextField(
              controller: _descController,
              label: 'البيان',
              hint: 'مثال: توريد وتركيب أبواب',
              dense: true,
              onChanged: (_) => _emit(),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _widthController,
                    label: 'العرض (سم)',
                    hint: 'مثال: 117',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _heightController,
                    label: 'الارتفاع (سم)',
                    hint: 'مثال: 243',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _qtyController,
                    label: 'الكمية',
                    hint: 'مثال: 1',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _colorController,
                    label: 'اللون',
                    hint: 'مثال: مطلي / بني',
                    dense: true,
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _unitController,
                    label: 'السعر م² (${SarMoney.symbol})',
                    hint: 'مثال: 1500',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _notesController,
                    label: 'الملاحظات (اختياري)',
                    hint: 'مثال: الأقفال على العميل',
                    dense: true,
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Text(
                    'المساحة ${computed.areaM2.toStringAsFixed(2)} م²',
                    style: AppTypography.caption().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  'الإجمالي ${SarMoney.format(computed.lineTotal)}',
                  style: AppTypography.captionBold().copyWith(
                    color: AppColors.onPrimaryFixedVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
