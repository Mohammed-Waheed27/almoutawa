import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/product.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/agreement_form_bloc.dart';
import '../sections/agreement_form_meta_section.dart';
import '../sections/agreement_form_totals_section.dart';
import '../sections/quote_form_extras_section.dart';
import '../widgets/agreement_copied_line_shell.dart';
import '../widgets/agreement_copy_from_quote_button.dart';
import '../widgets/agreement_form_skeleton.dart';
import '../widgets/agreement_line_editor.dart';

class AgreementFormPage extends StatefulWidget {
  const AgreementFormPage({
    super.key,
    required this.orderId,
    required this.rolePrefix,
  });

  final String orderId;
  final String rolePrefix;

  @override
  State<AgreementFormPage> createState() => _AgreementFormPageState();
}

class _AgreementFormPageState extends State<AgreementFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _city;
  late final TextEditingController _vat;
  late final TextEditingController _days;
  late final TextEditingController _down;
  late final TextEditingController _receipt;
  late final TextEditingController _discount;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    _city = TextEditingController();
    _vat = TextEditingController();
    _days = TextEditingController();
    _down = TextEditingController(text: '0');
    _receipt = TextEditingController();
    _discount = TextEditingController();
  }

  @override
  void dispose() {
    _city.dispose();
    _vat.dispose();
    _days.dispose();
    _down.dispose();
    _receipt.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _pickProduct(BuildContext context, int index) async {
    final product = await context.push<Product>(
      AppRoutes.workOrderProductPickPath(widget.rolePrefix),
    );
    if (product == null || !context.mounted) return;
    context.read<AgreementFormBloc>().add(
      AgreementFormProductPicked(index, product),
    );
  }

  void _syncMetaToBloc(BuildContext context) {
    final days = int.tryParse(_days.text.trim());
    context.read<AgreementFormBloc>().add(
      AgreementFormFieldChanged(
        clientCity: _city.text,
        clientVatNumber: _vat.text,
        manufacturingDays: days,
        clearManufacturingDays: _days.text.trim().isEmpty,
        downPayment: double.tryParse(_down.text.replaceAll(',', '.')) ?? 0,
        receiptReference: _receipt.text,
        discountAmount: double.tryParse(_discount.text.replaceAll(',', '.')) ?? 0,
      ),
    );
  }

  AgreementDraft _draftFrom(AgreementFormState state) {
    return AgreementDraft(
      agreementDate: DateTime.now(),
      clientCity: _city.text,
      clientVatNumber: _vat.text,
      manufacturingDays: int.tryParse(_days.text.trim()),
      downPayment: double.tryParse(_down.text.replaceAll(',', '.')) ?? 0,
      receiptReference: _receipt.text,
      discountAmount: double.tryParse(_discount.text.replaceAll(',', '.')) ?? 0,
      vatRate: state.vatRate,
      extraCharges: state.extraCharges,
      lines: state.lines,
    );
  }

  void _submit(BuildContext context, AgreementFormState state) {
    _syncMetaToBloc(context);
    final draft = _draftFrom(state);

    if (!FormSubmitValidation.run(
      context: context,
      formKey: _formKey,
      domainError: draft.validationError,
    )) {
      return;
    }

    context.read<AgreementFormBloc>().add(
      AgreementFormSubmitted(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      title: 'اتفاقية عمل',
      showBackButton: true,
      contentMaxWidth: DesktopUiTokens.formMaxWidth,
      body: BlocConsumer<AgreementFormBloc, AgreementFormState>(
        listenWhen: (p, c) =>
            p.status != c.status ||
            p.copyGeneration != c.copyGeneration ||
            (p.message != c.message && c.message != null),
        listener: (context, state) {
          if (!_seeded && state.status == AgreementFormStatus.ready) {
            _seeded = true;
            _city.text = state.clientCity;
            _vat.text = state.clientVatNumber;
            _days.text = state.manufacturingDays == null
                ? ''
                : '${state.manufacturingDays}';
            _down.text = state.downPayment == 0 ? '0' : '${state.downPayment}';
            _receipt.text = state.receiptReference;
            _discount.text = state.discountAmount == 0
                ? ''
                : '${state.discountAmount}';
            setState(() {});
          }
          if (state.copyGeneration != 0) {
            _days.text = state.manufacturingDays == null
                ? ''
                : '${state.manufacturingDays}';
            _discount.text = state.discountAmount == 0
                ? ''
                : '${state.discountAmount}';
          }
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
          if (state.status == AgreementFormStatus.success) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state.status == AgreementFormStatus.loading ||
              state.status == AgreementFormStatus.initial ||
              state.detail == null) {
            return const AgreementFormSkeleton();
          }

          final isSaving = state.status == AgreementFormStatus.saving;
          final draft = _draftFrom(state);

          return AlmoutawaFormLayout(
            formKey: _formKey,
            fields: [
              AgreementCopyFromQuoteButton(
                copyGeneration: state.copyGeneration,
                enabled: !isSaving,
                onPressed: () => context.read<AgreementFormBloc>().add(
                  const AgreementFormSeedFromQuote(),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AgreementFormMetaSection(
                detail: state.detail!,
                cityController: _city,
                vatController: _vat,
                daysController: _days,
                downController: _down,
                receiptController: _receipt,
                onMetaChanged: () {
                  _syncMetaToBloc(context);
                  setState(() {});
                },
              ),
              SizedBox(height: AppSpacing.sm),
              AlmoutawaTextField(
                controller: _discount,
                label: 'الخصم ر.س (اختياري)',
                hint: 'مثال: 500',
                dense: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  _syncMetaToBloc(context);
                  setState(() {});
                },
              ),
              SizedBox(height: AppSpacing.md),
              QuoteFormExtrasSection(
                charges: state.extraCharges,
                onChanged: (charges) {
                  context.read<AgreementFormBloc>().add(
                    AgreementFormExtrasChanged(charges),
                  );
                  setState(() {});
                },
                onAdd: () {
                  context.read<AgreementFormBloc>().add(
                    AgreementFormExtrasChanged([
                      ...state.extraCharges,
                      DocumentExtraCharge(
                        id: 'tmp-${DateTime.now().microsecondsSinceEpoch}',
                        name: '',
                        amount: 0,
                        sortOrder: state.extraCharges.length,
                      ),
                    ]),
                  );
                },
                onRemove: (index) {
                  final next = [...state.extraCharges]..removeAt(index);
                  context.read<AgreementFormBloc>().add(
                    AgreementFormExtrasChanged(next),
                  );
                },
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      'بنود الاتفاقية',
                      style: AppTypography.titleSm(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: isSaving
                        ? null
                        : () => context.read<AgreementFormBloc>().add(
                            const AgreementFormLineAdded(),
                          ),
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
                AgreementCopiedLineShell(
                  key: ValueKey('agr-line-$i-${state.copyGeneration}'),
                  index: i,
                  copyGeneration: state.copyGeneration,
                  child: AgreementLineEditor(
                    index: i,
                    line: state.lines[i],
                    onChanged: (line) {
                      context.read<AgreementFormBloc>().add(
                        AgreementFormLineUpdated(i, line),
                      );
                      setState(() {});
                    },
                    onRemove: () => context.read<AgreementFormBloc>().add(
                      AgreementFormLineRemoved(i),
                    ),
                    onPickProduct: () => _pickProduct(context, i),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(height: AppSpacing.md),
              AgreementFormTotalsSection(draft: draft),
            ],
            submitButton: AlmoutawaButton(
              label: isSaving ? 'جاري الحفظ...' : 'حفظ الاتفاقية',
              icon: Icons.save_rounded,
              onPressed: isSaving ? null : () => _submit(context, state),
            ),
          );
        },
      ),
    );
  }
}
