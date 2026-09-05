import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/inputs/form_info_banner.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/customer_form_bloc.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.existing});

  final Customer? existing;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _governorateController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _responsibleController;
  late final TextEditingController _commercialRegisterController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _fullNameController = TextEditingController(text: existing?.fullName ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _addressController = TextEditingController(text: existing?.address ?? '');
    _governorateController = TextEditingController(
      text: existing?.governorate ?? '',
    );
    _companyNameController = TextEditingController(
      text: existing?.companyName ?? '',
    );
    _responsibleController = TextEditingController(
      text: existing?.responsiblePerson ?? '',
    );
    _commercialRegisterController = TextEditingController(
      text: existing?.commercialRegister ?? '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _governorateController.dispose();
    _companyNameController.dispose();
    _responsibleController.dispose();
    _commercialRegisterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: isEditing ? 'تعديل عميل' : 'إضافة عميل',
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<CustomerFormBloc, CustomerFormState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.message != current.message,
          listener: (context, state) {
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
            if (state.status == CustomerFormStatus.success &&
                state.savedCustomer != null) {
              context.pop(state.savedCustomer);
            }
          },
          builder: (context, state) {
            final isIndividual = state.type == CustomerType.individual;
            final typeIndex = isIndividual ? 0 : 1;
            final dense = context.density.isExpanded;
            final gap = dense ? DesktopUiTokens.gapSm : AppSpacing.sm;

            Widget pair(Widget a, Widget b) {
              if (!dense) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    a,
                    SizedBox(height: gap),
                    b,
                  ],
                );
              }
              return Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: a),
                  SizedBox(width: DesktopUiTokens.gapMd),
                  Expanded(child: b),
                ],
              );
            }

            return AlmoutawaFormLayout(
              formKey: _formKey,
              fields: [
                SegmentedTabBar(
                  tabs: const ['فرد', 'مؤسسة'],
                  selectedIndex: typeIndex,
                  onSelected: (index) {
                    context.read<CustomerFormBloc>().add(
                      CustomerFormTypeChanged(
                        index == 0
                            ? CustomerType.individual
                            : CustomerType.company,
                      ),
                    );
                  },
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
                if (isIndividual)
                  AlmoutawaTextField(
                    controller: _fullNameController,
                    label: 'الاسم',
                    hint: 'مثال: محمد أحمد علي',
                    icon: Icons.person_outline_rounded,
                    dense: dense,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'الاسم مطلوب'
                        : null,
                  )
                else ...[
                  AlmoutawaTextField(
                    controller: _companyNameController,
                    label: 'اسم المؤسسة',
                    hint: 'مثال: شركة المطاوعة للأبواب',
                    icon: Icons.business_outlined,
                    dense: dense,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'اسم المؤسسة مطلوب'
                        : null,
                  ),
                  SizedBox(height: gap),
                  pair(
                    AlmoutawaTextField(
                      controller: _responsibleController,
                      label: 'المسؤول',
                      hint: 'مثال: أحمد محمود',
                      icon: Icons.badge_outlined,
                      dense: dense,
                    ),
                    AlmoutawaTextField(
                      controller: _commercialRegisterController,
                      label: 'السجل التجاري',
                      hint: 'مثال: 1234567890',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      dense: dense,
                    ),
                  ),
                ],
                SizedBox(height: gap),
                pair(
                  AlmoutawaTextField(
                    controller: _phoneController,
                    label: 'الهاتف',
                    hint: 'مثال: 01012345678',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    dense: dense,
                  ),
                  AlmoutawaTextField(
                    controller: _governorateController,
                    label: 'المحافظة',
                    hint: 'مثال: القاهرة',
                    icon: Icons.map_outlined,
                    dense: dense,
                  ),
                ),
                SizedBox(height: gap),
                AlmoutawaTextField(
                  controller: _addressController,
                  label: 'العنوان',
                  hint: 'مثال: شارع النيل، المعادي',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  dense: dense,
                ),
                SizedBox(height: gap),
                AlmoutawaTextField(
                  controller: _notesController,
                  label: 'ملاحظات (اختياري)',
                  hint: 'أي ملاحظات إضافية عن العميل...',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  dense: dense,
                ),
                SizedBox(height: dense ? DesktopUiTokens.gapMd : AppSpacing.md),
                const FormInfoBanner(
                  message:
                      'تعطيل العميل لا يحذف أوامر الشحن أو كشف الحساب السابق.',
                ),
              ],
              submitButton: AlmoutawaButton(
                label: isEditing ? 'حفظ التعديلات' : 'حفظ العميل',
                icon: Icons.save_outlined,
                size: dense ? AlmoutawaButtonSize.sm : AlmoutawaButtonSize.md,
                expanded: !dense,
                onPressed: state.status == CustomerFormStatus.submitting
                    ? null
                    : () {
                        final draft = CustomerDraft(
                          type: state.type,
                          fullName: _fullNameController.text,
                          phone: _phoneController.text,
                          address: _addressController.text,
                          governorate: _governorateController.text,
                          companyName: _companyNameController.text,
                          responsiblePerson: _responsibleController.text,
                          commercialRegister:
                              _commercialRegisterController.text,
                          notes: _notesController.text,
                        );
                        if (!FormSubmitValidation.run(
                          context: context,
                          formKey: _formKey,
                          domainError: draft.validationError,
                        )) {
                          return;
                        }
                        context.read<CustomerFormBloc>().add(
                          CustomerFormSubmitted(
                            fullName: _fullNameController.text,
                            phone: _phoneController.text,
                            address: _addressController.text,
                            governorate: _governorateController.text,
                            companyName: _companyNameController.text,
                            responsiblePerson: _responsibleController.text,
                            commercialRegister:
                                _commercialRegisterController.text,
                            notes: _notesController.text,
                          ),
                        );
                      },
              ),
            );
          },
        ),
      ),
    );
  }
}
