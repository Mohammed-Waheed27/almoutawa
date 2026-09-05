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

/// Dense line editor for quote table rows — no oversized card chrome.
class QuoteLineEditor extends StatefulWidget {
  const QuoteLineEditor({
    super.key,
    required this.index,
    required this.line,
    required this.onChanged,
    required this.onRemove,
    required this.onPickProduct,
  });

  final int index;
  final QuoteLineDraft line;
  final ValueChanged<QuoteLineDraft> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onPickProduct;

  @override
  State<QuoteLineEditor> createState() => _QuoteLineEditorState();
}

class _QuoteLineEditorState extends State<QuoteLineEditor> {
  late final TextEditingController _descController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _qtyController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.line.description);
    _widthController = TextEditingController(
      text: DimensionCm.format(widget.line.widthCm),
    );
    _heightController = TextEditingController(
      text: DimensionCm.format(widget.line.heightCm),
    );
    _qtyController = TextEditingController(text: '${widget.line.quantity}');
    _unitController = TextEditingController(
      text: SarMoney.amountInput(widget.line.unitPrice),
    );
  }

  @override
  void didUpdateWidget(covariant QuoteLineEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line == widget.line) return;

    // Sync from product pick / external replace — avoid fighting mid-typing.
    final productPicked =
        oldWidget.line.productId != widget.line.productId ||
        (widget.line.productId != null &&
            oldWidget.line.description != widget.line.description &&
            oldWidget.line.unitPrice != widget.line.unitPrice);

    if (productPicked || _descController.text != widget.line.description) {
      if (_descController.text != widget.line.description) {
        _descController.text = widget.line.description;
      }
    }
    if (productPicked) {
      _unitController.text = SarMoney.amountInput(widget.line.unitPrice);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
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

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  QuoteLineDraft _draftFromControllers() {
    return QuoteLineDraft(
      productId: widget.line.productId,
      description: _descController.text,
      widthCm: DimensionCm.parse(_widthController.text),
      heightCm: DimensionCm.parse(_heightController.text),
      quantity: _parseInt(_qtyController.text).clamp(0, 999999),
      unitPrice: _parsePrice(_unitController.text),
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
              hint: 'مثال: باب خارجي الصالة',
              dense: true,
              textInputAction: TextInputAction.next,
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
                    hint: 'مثال: 279',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _heightController,
                    label: 'الارتفاع (سم)',
                    hint: 'مثال: 141',
                    dense: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
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
                    label: 'العدد',
                    hint: '1',
                    dense: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AlmoutawaTextField(
                    controller: _unitController,
                    label: 'سعر المتر (${SarMoney.symbol})',
                    hint: 'مثال: 1350',
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
