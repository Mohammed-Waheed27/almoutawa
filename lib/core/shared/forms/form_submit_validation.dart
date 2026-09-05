import 'package:flutter/material.dart';

import '../widgets/feedback/almoutawa_snackbar.dart';

/// Runs [FormState] validators and optional domain-level draft validation
/// before dispatching a save/submit action.
class FormSubmitValidation {
  const FormSubmitValidation._();

  /// Returns `true` when the form and domain checks pass.
  ///
  /// - Field errors are shown inline by [FormState.validate].
  /// - The first invalid field is scrolled into view when possible.
  /// - [domainError] is surfaced in a snackbar (colors, media, cross-field rules).
  static bool run({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    String? domainError,
    String formInvalidMessage = 'يرجى تعبئة الحقول المطلوبة',
  }) {
    final formState = formKey.currentState;
    if (formState == null) return false;

    final formValid = formState.validate();
    if (!formValid) {
      _scrollToFirstInvalidField(formState);
      final firstError = _firstFieldErrorMessage(formState);
      AlmoutawaSnackbar.show(context, firstError ?? formInvalidMessage);
      return false;
    }

    if (domainError != null && domainError.trim().isNotEmpty) {
      AlmoutawaSnackbar.show(context, domainError.trim());
      return false;
    }

    return true;
  }

  static void _scrollToFirstInvalidField(FormState formState) {
    final invalidField = _findFirstInvalidField(formState.context as Element);
    if (invalidField == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!invalidField.mounted) return;
      Scrollable.ensureVisible(
        invalidField.context,
        alignment: 0.2,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  static FormFieldState<dynamic>? _findFirstInvalidField(Element element) {
    FormFieldState<dynamic>? found;

    void visit(Element child) {
      if (found != null) return;
      if (child is StatefulElement && child.state is FormFieldState<dynamic>) {
        final fieldState = child.state as FormFieldState<dynamic>;
        if (fieldState.hasError) {
          found = fieldState;
          return;
        }
      }
      child.visitChildren(visit);
    }

    element.visitChildren(visit);
    return found;
  }

  static String? _firstFieldErrorMessage(FormState formState) {
    final invalidField = _findFirstInvalidField(formState.context as Element);
    return invalidField?.errorText;
  }
}
