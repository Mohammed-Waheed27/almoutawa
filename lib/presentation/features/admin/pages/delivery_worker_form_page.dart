import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/staff_profile.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/delivery_worker_form_bloc.dart';

class DeliveryWorkerFormPage extends StatefulWidget {
  const DeliveryWorkerFormPage({
    super.key,
    this.existing,
    this.staffRole = UserRole.deliveryWorker,
  });

  final StaffProfile? existing;
  final UserRole staffRole;

  @override
  State<DeliveryWorkerFormPage> createState() => _DeliveryWorkerFormPageState();
}

class _DeliveryWorkerFormPageState extends State<DeliveryWorkerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  UserRole get _role => widget.existing?.role ?? widget.staffRole;

  bool get _isOps => _role == UserRole.productionManager;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.displayName ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final title = isEditing
        ? (_isOps ? 'تعديل مدير تشغيل' : 'تعديل مندوب')
        : (_isOps ? 'مدير تشغيل جديد' : 'مندوب تسليم جديد');
    final nameLabel = _isOps ? 'اسم مدير التشغيل' : 'اسم المندوب';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: title,
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<DeliveryWorkerFormBloc, DeliveryWorkerFormState>(
          listenWhen: (previous, current) =>
              current.status == DeliveryWorkerFormStatus.success ||
              current.status == DeliveryWorkerFormStatus.failure,
          listener: (context, state) {
            if (state.status == DeliveryWorkerFormStatus.success) {
              context.pop(true);
            }
            if (state.message != null &&
                state.status == DeliveryWorkerFormStatus.failure) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
          },
          builder: (context, state) {
            final isSubmitting =
                state.status == DeliveryWorkerFormStatus.submitting;

            return AlmoutawaFormLayout(
              formKey: _formKey,
              fields: [
                AlmoutawaTextField(
                  controller: _nameController,
                  label: nameLabel,
                  hint: _isOps ? 'مثال: أحمد محمد' : 'مثال: محمد أحمد علي',
                  icon: Icons.person_outline_rounded,
                  readOnly: isSubmitting,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '$nameLabel مطلوب'
                      : null,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'name@company.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: isEditing || isSubmitting,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'البريد الإلكتروني مطلوب'
                      : null,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _phoneController,
                  label: 'الهاتف (اختياري)',
                  hint: 'مثال: 01012345678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  readOnly: isSubmitting,
                ),
                if (!isEditing) ...[
                  SizedBox(height: AppSpacing.sm),
                  AlmoutawaTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    readOnly: isSubmitting,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              submitButton: AlmoutawaButton(
                label: isSubmitting
                    ? 'جاري الحفظ...'
                    : (isEditing
                          ? 'حفظ التعديلات'
                          : (_isOps ? 'إضافة مدير التشغيل' : 'إضافة المندوب')),
                icon: Icons.save_outlined,
                onPressed: isSubmitting
                    ? null
                    : () {
                        final domainError = isEditing
                            ? StaffProfileUpdateDraft(
                                displayName: _nameController.text,
                                phone: _phoneController.text,
                              ).validationError
                            : StaffProfileDraft(
                                displayName: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                phone: _phoneController.text,
                                role: _role,
                              ).validationError;
                        if (!FormSubmitValidation.run(
                          context: context,
                          formKey: _formKey,
                          domainError: domainError,
                        )) {
                          return;
                        }
                        context.read<DeliveryWorkerFormBloc>().add(
                          DeliveryWorkerFormSubmitted(
                            displayName: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            phone: _phoneController.text,
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
