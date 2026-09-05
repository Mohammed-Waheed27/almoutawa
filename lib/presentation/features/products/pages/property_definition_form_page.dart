import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/media/media_picker_helper.dart';
import '../../../../core/shared/forms/form_submit_validation.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/cards/almoutawa_card.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_form_layout.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/product_property.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/property_definition_form_bloc.dart';

class PropertyDefinitionFormPage extends StatefulWidget {
  const PropertyDefinitionFormPage({super.key, this.existing});

  final ProductPropertyDefinition? existing;

  @override
  State<PropertyDefinitionFormPage> createState() =>
      _PropertyDefinitionFormPageState();
}

class _PropertyDefinitionFormPageState
    extends State<PropertyDefinitionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  final _valueArController = TextEditingController();
  final _valueEnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.existing?.nameAr);
    _nameEnController = TextEditingController(text: widget.existing?.nameEn);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _valueArController.dispose();
    _valueEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: widget.existing == null ? 'خاصية جديدة' : 'تعديل الخاصية',
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<PropertyDefinitionFormBloc, PropertyDefinitionFormState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.message != current.message,
          listener: (context, state) {
            if (state.message != null) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
            if (state.status == PropertyDefinitionFormStatus.success) {
              context.pop(true);
            }
          },
          builder: (context, state) {
            final isSubmitting =
                state.status == PropertyDefinitionFormStatus.submitting;

            return AlmoutawaFormLayout(
              formKey: _formKey,
              fields: [
                _IconPickerRow(
                  selectedKey: state.iconKey,
                  enabled: !isSubmitting,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _nameArController,
                  label: 'اسم الخاصية (عربي)',
                  hint: 'مثال: نوع الكالون',
                  icon: Icons.translate_rounded,
                  readOnly: isSubmitting,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الاسم بالعربية مطلوب'
                      : null,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _nameEnController,
                  label: 'Property name (English)',
                  hint: 'Example: Lock Type',
                  icon: Icons.language_outlined,
                  readOnly: isSubmitting,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'English name is required'
                      : null,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'قيم الخاصية',
                  style: AppTypography.titleSm().copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                ...state.values.map(
                  (value) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AlmoutawaCard(
                      variant: AlmoutawaCardVariant.solid,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.valueAr,
                                  style: AppTypography.titleMd(),
                                ),
                                Text(
                                  value.valueEn,
                                  style: AppTypography.labelMd().copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (value.imageUrl != null &&
                              value.imageUrl!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(left: AppSpacing.sm),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  value.imageUrl!,
                                  width: 44,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          AlmoutawaButton(
                            label: 'صورة',
                            icon: Icons.add_photo_alternate_outlined,
                            variant: AlmoutawaButtonVariant.tertiaryText,
                            size: AlmoutawaButtonSize.sm,
                            expanded: false,
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final picks =
                                        await MediaPickerHelper.pickImages(
                                      source: ImageSource.gallery,
                                      multiple: false,
                                    );
                                    if (picks.isEmpty || !context.mounted) {
                                      return;
                                    }
                                    context
                                        .read<PropertyDefinitionFormBloc>()
                                        .add(
                                          PropertyDefinitionFormValueImagePicked(
                                            pick: picks.first,
                                            target: value,
                                          ),
                                        );
                                  },
                          ),
                          AlmoutawaButton(
                            label: 'حذف',
                            icon: Icons.delete_outline_rounded,
                            variant: AlmoutawaButtonVariant.destructive,
                            size: AlmoutawaButtonSize.sm,
                            expanded: false,
                            onPressed: isSubmitting
                                ? null
                                : () => context
                                      .read<PropertyDefinitionFormBloc>()
                                      .add(
                                        PropertyDefinitionFormValueRemoved(
                                          value,
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AlmoutawaTextField(
                  controller: _valueArController,
                  label: 'قيمة جديدة (عربي)',
                  hint: 'مثال: عادي',
                  readOnly: isSubmitting,
                ),
                SizedBox(height: AppSpacing.sm),
                AlmoutawaTextField(
                  controller: _valueEnController,
                  label: 'New value (English)',
                  hint: 'Example: Normal',
                  readOnly: isSubmitting,
                ),
                SizedBox(height: AppSpacing.sm),
                if (state.pendingValueImageUrl != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        state.pendingValueImageUrl!,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    AlmoutawaButton(
                      label: 'صورة القيمة (اختياري)',
                      icon: Icons.add_photo_alternate_outlined,
                      variant: AlmoutawaButtonVariant.tertiaryText,
                      size: AlmoutawaButtonSize.sm,
                      expanded: false,
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final picks = await MediaPickerHelper.pickImages(
                                source: ImageSource.gallery,
                                multiple: false,
                              );
                              if (picks.isEmpty || !context.mounted) return;
                              context.read<PropertyDefinitionFormBloc>().add(
                                PropertyDefinitionFormValueImagePicked(
                                  pick: picks.first,
                                ),
                              );
                            },
                    ),
                    SizedBox(width: AppSpacing.sm),
                    AlmoutawaButton(
                      label: 'إضافة قيمة',
                      icon: Icons.add_rounded,
                      variant: AlmoutawaButtonVariant.tertiaryText,
                      size: AlmoutawaButtonSize.sm,
                      expanded: false,
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context.read<PropertyDefinitionFormBloc>().add(
                                PropertyDefinitionFormValueAdded(
                                  valueAr: _valueArController.text,
                                  valueEn: _valueEnController.text,
                                ),
                              );
                              _valueArController.clear();
                              _valueEnController.clear();
                            },
                    ),
                  ],
                ),
              ],
              submitButton: AlmoutawaButton(
                label: isSubmitting ? 'جاري الحفظ...' : 'حفظ الخاصية',
                icon: Icons.save_outlined,
                onPressed: isSubmitting
                    ? null
                    : () {
                        final draft = ProductPropertyDefinitionDraft(
                          nameAr: _nameArController.text,
                          nameEn: _nameEnController.text,
                          values: state.values,
                        );
                        if (!FormSubmitValidation.run(
                          context: context,
                          formKey: _formKey,
                          domainError: draft.validationError,
                        )) {
                          return;
                        }
                        context.read<PropertyDefinitionFormBloc>().add(
                          PropertyDefinitionFormSubmitted(
                            nameAr: _nameArController.text,
                            nameEn: _nameEnController.text,
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

class _IconPickerRow extends StatelessWidget {
  const _IconPickerRow({required this.selectedKey, required this.enabled});

  final String selectedKey;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: productPropertyIconOptions.entries.map((entry) {
        final selected = entry.key == selectedKey;
        return ChoiceChip(
          label: Icon(entry.value, size: 20),
          selected: selected,
          onSelected: enabled
              ? (_) => context.read<PropertyDefinitionFormBloc>().add(
                  PropertyDefinitionFormIconChanged(entry.key),
                )
              : null,
          selectedColor: AppColors.secondaryFixed,
        );
      }).toList(),
    );
  }
}
