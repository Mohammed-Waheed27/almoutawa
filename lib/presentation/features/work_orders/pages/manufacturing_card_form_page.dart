import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/pdf/manufacturing_card_pdf_builder.dart';
import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/layout/almoutawa_adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../di/injection_container.dart';
import '../../../../domain/entities/manufacturing_card.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/manufacturing_card_form_bloc.dart';
import '../sections/manufacturing_card_color_section.dart';
import '../sections/manufacturing_card_images_section.dart';
import '../sections/manufacturing_card_meta_section.dart';
import '../sections/manufacturing_card_notes_section.dart';
import '../sections/manufacturing_card_properties_section.dart';
import '../widgets/manufacturing_card_form_skeleton.dart';

class ManufacturingCardFormPage extends StatefulWidget {
  const ManufacturingCardFormPage({
    super.key,
    required this.rolePrefix,
    required this.orderId,
    required this.agreementLineId,
    required this.cardIndex,
  });

  final String rolePrefix;
  final String orderId;
  final String agreementLineId;
  final int cardIndex;

  @override
  State<ManufacturingCardFormPage> createState() =>
      _ManufacturingCardFormPageState();
}

class _ManufacturingCardFormPageState extends State<ManufacturingCardFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _modelArController = TextEditingController();
  final _modelEnController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _colorNameArController = TextEditingController();
  final _colorNameEnController = TextEditingController();
  final _colorCodeController = TextEditingController();
  final _alertController = TextEditingController();
  final _notesController = TextEditingController();

  var _seeded = false;
  var _pdfBusy = false;
  var _poppedAfterSave = false;

  @override
  void dispose() {
    _modelArController.dispose();
    _modelEnController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _colorNameArController.dispose();
    _colorNameEnController.dispose();
    _colorCodeController.dispose();
    _alertController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _seed(ManufacturingCardFormState state) {
    _modelArController.text = state.modelNameAr;
    _modelEnController.text = state.modelNameEn ?? '';
    _widthController.text = state.widthCm > 0
        ? state.widthCm.toStringAsFixed(0)
        : '';
    _heightController.text = state.heightCm > 0
        ? state.heightCm.toStringAsFixed(0)
        : '';
    _colorNameArController.text = state.colorNameAr;
    _colorNameEnController.text = state.colorNameEn ?? '';
    _colorCodeController.text = state.colorCode ?? '';
    _alertController.text = state.alertNote;
    _notesController.text = state.notes ?? '';
  }

  void _syncToBlocBeforeSubmit(BuildContext context) {
    final bloc = context.read<ManufacturingCardFormBloc>();
    bloc.add(
      ManufacturingCardFormModelChanged(
        modelNameAr: _modelArController.text,
        modelNameEn: _modelEnController.text,
      ),
    );
    bloc.add(
      ManufacturingCardFormDimsChanged(
        widthCm: double.tryParse(_widthController.text) ?? 0,
        heightCm: double.tryParse(_heightController.text) ?? 0,
      ),
    );
    // Keep product-color pick unless user is on manual entry (no pick).
    if (bloc.state.pickedProductColor == null) {
      bloc.add(
        ManufacturingCardFormColorManualChanged(
          colorNameAr: _colorNameArController.text,
          colorNameEn: _colorNameEnController.text,
          colorCode: _colorCodeController.text,
        ),
      );
    }
    bloc.add(ManufacturingCardFormAlertNoteChanged(_alertController.text));
    bloc.add(ManufacturingCardFormNotesChanged(_notesController.text));
  }

  Future<void> _onPdfAction(
    BuildContext context, {
    required String action,
    required ManufacturingCardPdfLocale locale,
  }) async {
    final state = context.read<ManufacturingCardFormBloc>().state;
    final card = state.savedCard ?? state.existingCard;
    final detail = state.detail;
    if (card == null || detail == null) {
      AlmoutawaSnackbar.show(context, 'احفظ البطاقة أولاً قبل توليد PDF');
      return;
    }

    setState(() => _pdfBusy = true);
    try {
      final builder = getIt<ManufacturingCardPdfBuilder>();
      final bytes = await builder.build(
        detail: detail,
        card: card,
        locale: locale,
        context: context,
      );
      final pdfService = getIt<PdfShareService>();
      final pdfAction = switch (action) {
        'preview' => PdfDocumentAction.preview,
        _ => PdfDocumentAction.save,
      };
      final message = await pdfService.deliver(
        bytes: bytes,
        fileName: 'card-${card.id.substring(0, 8)}-${locale.fileSuffix}.pdf',
        subject: locale.isArabic ? 'بطاقة تصنيع' : 'Manufacturing Card',
        action: pdfAction,
      );
      if (context.mounted) {
        AlmoutawaSnackbar.show(context, message);
      }
    } catch (_) {
      if (context.mounted) {
        AlmoutawaSnackbar.show(context, 'خطأ في توليد PDF');
      }
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  Future<void> _showPdfSheet(BuildContext context) async {
    final action = await AlmoutawaAdaptiveSheet.show<String>(
      context: context,
      title: 'PDF بطاقة التصنيع',
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.containerPadding,
            AppSpacing.sm,
            AppSpacing.containerPadding,
            AppSpacing.containerPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AlmoutawaButton(
                label: 'حفظ PDF عربي',
                icon: Icons.save_alt_rounded,
                size: AlmoutawaButtonSize.sm,
                onPressed: () => Navigator.pop(ctx, 'save_ar'),
              ),
              SizedBox(height: AppSpacing.sm),
              AlmoutawaButton(
                label: 'حفظ PDF English',
                icon: Icons.save_alt_rounded,
                variant: AlmoutawaButtonVariant.secondaryGlass,
                size: AlmoutawaButtonSize.sm,
                onPressed: () => Navigator.pop(ctx, 'save_en'),
              ),
              if (!PdfShareService.isWindowsDesktop) ...[
                SizedBox(height: AppSpacing.sm),
                AlmoutawaButton(
                  label: 'معاينة PDF عربي',
                  icon: Icons.picture_as_pdf_outlined,
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  onPressed: () => Navigator.pop(ctx, 'preview_ar'),
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaButton(
                  label: 'معاينة PDF English',
                  icon: Icons.picture_as_pdf_outlined,
                  variant: AlmoutawaButtonVariant.tertiaryText,
                  size: AlmoutawaButtonSize.sm,
                  onPressed: () => Navigator.pop(ctx, 'preview_en'),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;
    final locale = action.endsWith('_en')
        ? ManufacturingCardPdfLocale.english
        : ManufacturingCardPdfLocale.arabic;
    final kind = action.startsWith('preview') ? 'preview' : 'save';
    await _onPdfAction(context, action: kind, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      title: 'بطاقة التصنيع',
      showBackButton: true,
      contentMaxWidth: DesktopUiTokens.formMaxWidth,
      body: BlocConsumer<ManufacturingCardFormBloc, ManufacturingCardFormState>(
        listenWhen: (p, c) =>
            p.status != c.status ||
            (p.message != c.message && c.message != null),
        listener: (context, state) {
          if (!_seeded && state.status == ManufacturingCardFormStatus.ready) {
            _seeded = true;
            _seed(state);
            setState(() {});
          }
          if (state.message != null &&
              state.status != ManufacturingCardFormStatus.success) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
          if (state.status == ManufacturingCardFormStatus.success &&
              state.savedCard != null &&
              !_poppedAfterSave) {
            _poppedAfterSave = true;
            AlmoutawaSnackbar.show(context, 'تم حفظ البطاقة');
            context.pop(state.savedCard);
          }
        },
        builder: (context, state) {
          if (state.status == ManufacturingCardFormStatus.loading ||
              state.status == ManufacturingCardFormStatus.initial) {
            return const ManufacturingCardFormSkeleton();
          }

          final isSaving = state.status == ManufacturingCardFormStatus.saving;
          final isReadOnly = state.isReadOnly;
          final fieldsEnabled = !isSaving && !isReadOnly;
          final canPdf =
              (state.existingCard != null || state.savedCard != null) &&
              !isSaving;

          return AlmoutawaFormLayout(
            formKey: _formKey,
            fields: [
              if (isReadOnly) ...[
                Text(
                  'الطلب مكتمل — بطاقة التصنيع للعرض فقط',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],
              ManufacturingCardMetaSection(
                modelArController: _modelArController,
                modelEnController: _modelEnController,
                widthController: _widthController,
                heightController: _heightController,
                enabled: fieldsEnabled,
              ),
              SizedBox(height: AppSpacing.md),
              ManufacturingCardColorSection(
                colorNameArController: _colorNameArController,
                colorNameEnController: _colorNameEnController,
                colorCodeController: _colorCodeController,
                enabled: fieldsEnabled,
              ),
              SizedBox(height: AppSpacing.md),
              ManufacturingCardImagesSection(enabled: fieldsEnabled),
              SizedBox(height: AppSpacing.md),
              ManufacturingCardPropertiesSection(enabled: fieldsEnabled),
              SizedBox(height: AppSpacing.md),
              ManufacturingCardNotesSection(
                alertController: _alertController,
                notesController: _notesController,
                enabled: fieldsEnabled,
              ),
              if (canPdf) ...[
                SizedBox(height: AppSpacing.md),
                AlmoutawaButton(
                  label: _pdfBusy ? 'جاري تجهيز PDF...' : 'حفظ PDF عربي / English',
                  icon: Icons.picture_as_pdf_outlined,
                  variant: AlmoutawaButtonVariant.secondaryGlass,
                  size: AlmoutawaButtonSize.sm,
                  onPressed: _pdfBusy ? null : () => _showPdfSheet(context),
                ),
              ],
            ],
            submitButton: isReadOnly
                ? null
                : AlmoutawaButton(
                    label: isSaving ? 'جاري الحفظ...' : 'حفظ والرجوع',
                    icon: Icons.save_rounded,
                    onPressed: isSaving ? null : () => _submit(context, state),
                  ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context, ManufacturingCardFormState state) {
    if (state.isReadOnly) return;
    _syncToBlocBeforeSubmit(context);

    final widthCm = double.tryParse(_widthController.text) ?? 0;
    final heightCm = double.tryParse(_heightController.text) ?? 0;

    final previewDraft = ManufacturingCardDraft(
      cardId: state.existingCard?.id,
      agreementLineId: widget.agreementLineId,
      cardIndex: widget.cardIndex,
      modelNameAr: _modelArController.text.trim(),
      widthCm: widthCm,
      heightCm: heightCm,
      alertNote: _alertController.text.trim(),
      properties: state.properties,
    );

    if (!FormSubmitValidation.run(
      context: context,
      formKey: _formKey,
      domainError: previewDraft.validationError,
    )) {
      return;
    }

    context.read<ManufacturingCardFormBloc>().add(
      const ManufacturingCardFormSubmitted(),
    );
  }
}
