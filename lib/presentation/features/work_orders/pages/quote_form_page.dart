import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/product.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/quote_form_bloc.dart';
import '../sections/quote_form_extras_section.dart';
import '../sections/quote_form_lines_summary_section.dart';
import '../sections/quote_form_meta_section.dart';
import '../sections/quote_form_totals_section.dart';
import '../widgets/quote_form_skeleton.dart';
import '../widgets/quote_line_editor.dart';

class QuoteFormPage extends StatefulWidget {
  const QuoteFormPage({
    super.key,
    required this.orderId,
    required this.rolePrefix,
  });

  final String orderId;
  final String rolePrefix;

  @override
  State<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends State<QuoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _specsController;
  late final TextEditingController _commentsController;
  late final TextEditingController _discountController;
  late final TextEditingController _durationController;
  var _seeded = false;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _specsController = TextEditingController();
    _commentsController = TextEditingController(
      text: defaultQuoteOtherCommentsText,
    );
    _discountController = TextEditingController(text: '0');
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _specsController.dispose();
    _commentsController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_dirty) return;
    setState(() => _dirty = true);
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked == null || !context.mounted) return;
    context.read<QuoteFormBloc>().add(QuoteFormDateChanged(picked));
    _markDirty();
  }

  Future<void> _pickProduct(BuildContext context, int index) async {
    final product = await context.push<Product>(
      AppRoutes.workOrderProductPickPath(widget.rolePrefix),
    );
    if (product == null || !context.mounted) return;
    context.read<QuoteFormBloc>().add(QuoteFormProductPicked(index, product));
    _markDirty();
    setState(() {});
  }

  void _goToOrderDetail() {
    context.go(
      AppRoutes.workOrderDetailPath(widget.rolePrefix, widget.orderId),
    );
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_dirty) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مغادرة عرض السعر؟'),
          content: const Text(
            'هناك تعديلات غير محفوظة. هل تريد المغادرة بدون حفظ؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('البقاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('مغادرة', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
    return shouldLeave ?? false;
  }

  Future<void> _handleBack() async {
    final ok = await _confirmDiscardIfNeeded();
    if (!ok || !mounted) return;
    _goToOrderDetail();
  }

  void _submit(BuildContext context, QuoteFormState state) {
    final draft = QuoteDraft(
      quoteDate: state.quoteDate ?? DateTime.now(),
      specsDescription: _specsController.text,
      otherComments: _commentsController.text,
      discountAmount: double.tryParse(_discountController.text) ?? 0,
      vatRate: state.vatRate,
      manufacturingDurationDays: int.tryParse(_durationController.text.trim()),
      extraCharges: state.extraCharges,
      lines: state.lines,
    );

    if (!FormSubmitValidation.run(
      context: context,
      formKey: _formKey,
      domainError: draft.validationError,
    )) {
      return;
    }

    final bloc = context.read<QuoteFormBloc>();
    bloc.add(QuoteFormSpecsChanged(_specsController.text));
    bloc.add(QuoteFormCommentsChanged(_commentsController.text));
    bloc.add(
      QuoteFormDiscountChanged(double.tryParse(_discountController.text) ?? 0),
    );
    bloc.add(
      QuoteFormDurationChanged(int.tryParse(_durationController.text.trim())),
    );
    bloc.add(QuoteFormSubmitted(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: RoleDashboardScaffold(
        title: 'عرض السعر',
        showBackButton: true,
        onBack: _handleBack,
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<QuoteFormBloc, QuoteFormState>(
          listenWhen: (p, c) =>
              p.status != c.status ||
              (p.message != c.message && c.message != null),
          listener: (context, state) {
            if (!_seeded && state.status == QuoteFormStatus.ready) {
              _seeded = true;
              _specsController.text = state.specsDescription;
              _commentsController.text = state.otherComments;
              _discountController.text = state.discountAmount == 0
                  ? '0'
                  : '${state.discountAmount}';
              _durationController.text =
                  state.manufacturingDurationDays?.toString() ?? '';
            }
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
            if (state.status == QuoteFormStatus.success) {
              _dirty = false;
              _goToOrderDetail();
            }
          },
          builder: (context, state) {
            if (state.status == QuoteFormStatus.loading ||
                state.status == QuoteFormStatus.initial ||
                state.detail == null) {
              return const QuoteFormSkeleton();
            }

            final draft = QuoteDraft(
              quoteDate: state.quoteDate ?? DateTime.now(),
              specsDescription: _specsController.text,
              otherComments: _commentsController.text,
              discountAmount: double.tryParse(_discountController.text) ?? 0,
              vatRate: state.vatRate,
              manufacturingDurationDays: int.tryParse(
                _durationController.text.trim(),
              ),
              extraCharges: state.extraCharges,
              lines: state.lines,
            );

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.sm,
                  AppSpacing.containerPadding,
                  AppSpacing.xl,
                ),
                children: [
                  QuoteFormMetaSection(
                    detail: state.detail!,
                    quoteDate: state.quoteDate ?? DateTime.now(),
                    discountController: _discountController,
                    onPickDate: () =>
                        _pickDate(context, state.quoteDate ?? DateTime.now()),
                    onDiscountChanged: (_) {
                      _markDirty();
                      setState(() {});
                    },
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AlmoutawaTextField(
                    controller: _durationController,
                    label: 'مدة التصنيع / التنفيذ (أيام) (اختياري)',
                    hint: 'مثال: 45',
                    dense: true,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _markDirty();
                      context.read<QuoteFormBloc>().add(
                        QuoteFormDurationChanged(
                          int.tryParse(_durationController.text.trim()),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AlmoutawaTextField(
                    controller: _specsController,
                    label: 'مواصفات عامة / البيان',
                    hint:
                        'مثال: توريد وتركيب أبواب ألمنيوم سادة سماكة 6 سم مع إطار 12 سم...',
                    dense: true,
                    maxLines: 3,
                    onChanged: (_) {
                      _markDirty();
                      setState(() {});
                    },
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AlmoutawaTextField(
                    controller: _commentsController,
                    label: 'بنود العرض / ملاحظات أخرى',
                    hint: 'البنود الافتراضية قابلة للتعديل قبل التصدير...',
                    dense: true,
                    maxLines: 5,
                    onChanged: (_) => _markDirty(),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          'بنود الجدول',
                          style: AppTypography.titleSm(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          context.read<QuoteFormBloc>().add(
                            const QuoteFormLineAdded(),
                          );
                          _markDirty();
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'إضافة بند',
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
                  SizedBox(height: AppSpacing.xs),
                  for (var i = 0; i < state.lines.length; i++) ...[
                    QuoteLineEditor(
                      index: i,
                      line: state.lines[i],
                      onChanged: (line) {
                        context.read<QuoteFormBloc>().add(
                          QuoteFormLineUpdated(i, line),
                        );
                        _markDirty();
                        setState(() {});
                      },
                      onRemove: () {
                        context.read<QuoteFormBloc>().add(
                          QuoteFormLineRemoved(i),
                        );
                        _markDirty();
                      },
                      onPickProduct: () => _pickProduct(context, i),
                    ),
                    SizedBox(height: AppSpacing.sm),
                  ],
                  QuoteFormLinesSummarySection(lines: state.lines),
                  SizedBox(height: AppSpacing.md),
                  QuoteFormExtrasSection(
                    charges: state.extraCharges,
                    onChanged: (charges) {
                      context.read<QuoteFormBloc>().add(
                        QuoteFormExtrasChanged(charges),
                      );
                      _markDirty();
                      setState(() {});
                    },
                    onAdd: () {
                      context.read<QuoteFormBloc>().add(
                        QuoteFormExtrasChanged([
                          ...state.extraCharges,
                          DocumentExtraCharge(
                            id:
                                'tmp-${DateTime.now().microsecondsSinceEpoch}',
                            name: '',
                            amount: 0,
                            sortOrder: state.extraCharges.length,
                          ),
                        ]),
                      );
                      _markDirty();
                    },
                    onRemove: (index) {
                      final next = [...state.extraCharges]..removeAt(index);
                      context.read<QuoteFormBloc>().add(
                        QuoteFormExtrasChanged(next),
                      );
                      _markDirty();
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  QuoteFormTotalsSection(draft: draft),
                  SizedBox(height: AppSpacing.md),
                  AlmoutawaButton(
                    label: state.status == QuoteFormStatus.saving
                        ? 'جاري الحفظ...'
                        : 'حفظ عرض السعر',
                    onPressed: state.status == QuoteFormStatus.saving
                        ? null
                        : () => _submit(context, state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
