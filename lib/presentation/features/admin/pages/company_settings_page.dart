import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/settings/settings_group_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/company_settings.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/company_settings_bloc.dart';
import '../widgets/company_settings_skeleton.dart';

class CompanySettingsPage extends StatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _vatController = TextEditingController();
  final _termsController = TextEditingController();
  final _labelController = TextEditingController();
  final _phoneController = TextEditingController();
  var _showOnPdf = true;
  String? _editingPhoneId;
  var _seeded = false;

  @override
  void dispose() {
    _vatController.dispose();
    _termsController.dispose();
    _labelController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _seedVat(CompanySettings settings) {
    if (_seeded) return;
    _seeded = true;
    _vatController.text = settings.vatPercent.toStringAsFixed(
      settings.vatPercent == settings.vatPercent.roundToDouble() ? 0 : 2,
    );
    if (_termsController.text.isEmpty) {
      _termsController.text = settings.agreementTermsAr;
    }
  }

  void _editPhone(CompanyContactPhone phone) {
    setState(() {
      _editingPhoneId = phone.id;
      _labelController.text = phone.label;
      _phoneController.text = phone.phone;
      _showOnPdf = phone.showOnPdf;
    });
  }

  void _clearPhoneForm() {
    setState(() {
      _editingPhoneId = null;
      _labelController.clear();
      _phoneController.clear();
      _showOnPdf = true;
    });
  }

  void _saveVat(BuildContext context) {
    final percent = double.tryParse(_vatController.text.trim());
    if (percent == null || percent < 0 || percent > 100) {
      AlmoutawaSnackbar.show(context, 'أدخل نسبة ضريبة بين 0 و 100');
      return;
    }
    context.read<CompanySettingsBloc>().add(
      CompanySettingsVatSaved(percent / 100),
    );
  }

  void _savePhone(BuildContext context, CompanySettings settings) {
    final draft = CompanyContactPhoneDraft(
      id: _editingPhoneId,
      label: _labelController.text,
      phone: _phoneController.text,
      sortOrder: _editingPhoneId == null
          ? settings.phones.length
          : settings.phones
                .firstWhere((item) => item.id == _editingPhoneId)
                .sortOrder,
      showOnPdf: _showOnPdf,
    );
    if (!FormSubmitValidation.run(
      context: context,
      formKey: _formKey,
      domainError: draft.validationError,
    )) {
      return;
    }
    context.read<CompanySettingsBloc>().add(CompanySettingsPhoneSaved(draft));
    _clearPhoneForm();
  }

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      title: 'إعدادات الشركة',
      showBackButton: true,
      contentMaxWidth: DesktopUiTokens.formMaxWidth,
      body: BlocConsumer<CompanySettingsBloc, CompanySettingsState>(
        listenWhen: (p, c) => p.message != c.message && c.message != null,
        listener: (context, state) {
          AlmoutawaSnackbar.show(context, state.message!);
        },
        builder: (context, state) {
          if (state.status == CompanySettingsStatus.loading ||
              state.status == CompanySettingsStatus.initial ||
              state.settings == null) {
            return const CompanySettingsSkeleton();
          }
          final settings = state.settings!;
          _seedVat(settings);

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.containerPadding),
              children: [
                SettingsGroupSection(
                  title: 'الضريبة',
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تُستخدم النسبة الجديدة في عروض الأسعار والمستندات الجديدة فقط. المستندات المحفوظة سابقاً تحتفظ بالنسبة المسجّلة عليها.',
                            style: AppTypography.caption().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaTextField(
                            controller: _vatController,
                            label: 'نسبة الضريبة %',
                            hint: 'مثال: 15',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaButton(
                            label: state.busy ? 'جاري...' : 'حفظ نسبة الضريبة',
                            onPressed: state.busy
                                ? null
                                : () => _saveVat(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                SettingsGroupSection(
                  title: 'شروط وأحكام الاتفاقية',
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تظهر هذه الشروط في الصفحة الثانية من كل اتفاقية عمل جديدة. الاتفاقيات المحفوظة سابقاً تحتفظ بالنص المسجّل عليها.',
                            style: AppTypography.caption().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaTextField(
                            controller: _termsController,
                            label: 'نص الشروط والأحكام',
                            hint: 'اكتب بنود الاتفاقية كما ستظهر للعميل',
                            maxLines: 12,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaButton(
                            label: state.busy ? 'جاري...' : 'حفظ الشروط',
                            onPressed: state.busy
                                ? null
                                : () => context.read<CompanySettingsBloc>().add(
                                    CompanySettingsTermsSaved(
                                      _termsController.text,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                SettingsGroupSection(
                  title: 'أرقام التواصل',
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تظهر الأرقام المحددة في ملفات PDF الجديدة لجميع المستندات.',
                            style: AppTypography.caption().copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          if (settings.phones.isEmpty)
                            Text(
                              'لا توجد أرقام بعد',
                              style: AppTypography.bodyMd(),
                              textAlign: TextAlign.right,
                            )
                          else
                            for (final phone in settings.phones)
                              _PhoneRow(
                                phone: phone,
                                enabled: !state.busy,
                                onEdit: () => _editPhone(phone),
                                onDelete: () => context
                                    .read<CompanySettingsBloc>()
                                    .add(CompanySettingsPhoneDeleted(phone.id)),
                              ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            _editingPhoneId == null
                                ? 'إضافة رقم جديد'
                                : 'تعديل الرقم',
                            style: AppTypography.labelBold(),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaTextField(
                            controller: _labelController,
                            label: 'الوصف',
                            hint: 'مثال: هاتف المبيعات',
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AlmoutawaTextField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            hint: 'مثال: 0138333444',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _showOnPdf,
                            title: Text(
                              'إظهار في ملفات PDF',
                              style: AppTypography.bodyMd(),
                              textAlign: TextAlign.right,
                            ),
                            onChanged: (value) =>
                                setState(() => _showOnPdf = value),
                          ),
                          AlmoutawaButton(
                            label: _editingPhoneId == null
                                ? 'إضافة الرقم'
                                : 'حفظ التعديل',
                            onPressed: state.busy
                                ? null
                                : () => _savePhone(context, settings),
                          ),
                          if (_editingPhoneId != null) ...[
                            SizedBox(height: AppSpacing.sm),
                            AlmoutawaButton(
                              label: 'إلغاء التعديل',
                              variant: AlmoutawaButtonVariant.tertiaryText,
                              onPressed: _clearPhoneForm,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.phone,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  final CompanyContactPhone phone;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(phone.label, style: AppTypography.labelBold()),
        subtitle: Text(
          '${phone.phone}${phone.showOnPdf ? ' · يظهر في PDF' : ''}',
          style: AppTypography.caption(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: enabled ? onEdit : null,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: enabled ? onDelete : null,
              icon: Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
