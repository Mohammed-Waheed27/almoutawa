import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/inputs/form_info_banner.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/product_form_bloc.dart';
import '../sections/product_colors_section.dart';
import '../sections/product_properties_section.dart';
import '../widgets/product_form_page_skeleton.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descriptionController;
  var _fieldsHydratedFromRemote = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.existing;
    _nameController = TextEditingController(text: seed?.name ?? '');
    _nameEnController = TextEditingController(text: seed?.nameEn ?? '');
    _descriptionController = TextEditingController(
      text: seed?.description ?? '',
    );
    context.read<ProductFormBloc>().add(const ProductFormStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _hydrateFields(Product? product) {
    if (product == null) return;
    _nameController.text = product.name;
    _nameEnController.text = product.nameEn ?? '';
    _descriptionController.text = product.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: isEditing ? 'تعديل منتج' : 'منتج جديد',
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<ProductFormBloc, ProductFormState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.message != current.message ||
              (previous.isHydrating && !current.isHydrating),
          listener: (context, state) {
            if (!_fieldsHydratedFromRemote &&
                !state.isHydrating &&
                state.hasLoadedPropertyDefinitions &&
                state.editingProduct != null) {
              _hydrateFields(state.editingProduct);
              _fieldsHydratedFromRemote = true;
            }

            if (state.message != null &&
                state.status != ProductFormStatus.submitting) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
            if (state.status == ProductFormStatus.success &&
                state.savedProduct != null) {
              context.pop(state.savedProduct);
            }
          },
          builder: (context, state) {
            if (state.showBlockingSpinner) {
              return const ProductFormPageSkeleton();
            }

            final isSubmitting = state.status == ProductFormStatus.submitting;

            return AlmoutawaFormLayout(
              formKey: _formKey,
              fields: [
                if (!isEditing)
                  const FormInfoBanner(
                    message: 'السعر يُحدَّد لاحقاً من إعدادات المنتج.',
                  ),
                if (!isEditing) SizedBox(height: AppSpacing.md),
                AlmoutawaTextField(
                  controller: _nameController,
                  label: 'اسم المنتج (عربي)',
                  hint: 'مثال: باب MDF كلاسيك',
                  icon: Icons.door_sliding_outlined,
                  readOnly: isSubmitting,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'اسم المنتج مطلوب'
                      : null,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _nameEnController,
                  label: 'اسم المنتج بالإنجليزية (اختياري)',
                  hint: 'Example: Classic MDF Door',
                  icon: Icons.translate_rounded,
                  readOnly: isSubmitting,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _descriptionController,
                  label: 'الوصف (اختياري)',
                  hint: 'أي ملاحظات إضافية...',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  readOnly: isSubmitting,
                ),
                SizedBox(height: AppSpacing.md),
                ProductImagesSection(enabled: !isSubmitting),
                SizedBox(height: AppSpacing.md),
                ProductColorsSection(enabled: !isSubmitting),
                SizedBox(height: AppSpacing.md),
                ProductPropertiesSection(enabled: !isSubmitting),
              ],
              submitButton: AlmoutawaButton(
                label: isSubmitting
                    ? 'جاري الحفظ...'
                    : (isEditing ? 'حفظ التعديلات' : 'حفظ المنتج'),
                icon: Icons.save_outlined,
                onPressed: isSubmitting
                    ? null
                    : () {
                        final draft = state.toDraft(
                          name: _nameController.text,
                          nameEn: _nameEnController.text,
                          description: _descriptionController.text,
                        );
                        if (!FormSubmitValidation.run(
                          context: context,
                          formKey: _formKey,
                          domainError: draft.validationError,
                          formInvalidMessage:
                              'يرجى تصحيح الحقول المميزة باللون البرتقالي',
                        )) {
                          return;
                        }
                        context.read<ProductFormBloc>().add(
                          ProductFormSubmitted(
                            name: _nameController.text,
                            nameEn: _nameEnController.text,
                            description: _descriptionController.text,
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
