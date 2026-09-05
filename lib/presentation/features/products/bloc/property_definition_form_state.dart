part of 'property_definition_form_bloc.dart';

enum PropertyDefinitionFormStatus { initial, submitting, success, failure }

class PropertyDefinitionFormState extends Equatable {
  const PropertyDefinitionFormState({
    this.definitionId,
    this.iconKey = 'category_outlined',
    this.values = const [],
    this.status = PropertyDefinitionFormStatus.initial,
    this.savedDefinition,
    this.message,
    this.valueCounter = 0,
    this.pendingValueImageUrl,
  });

  final String? definitionId;
  final String iconKey;
  final List<ProductPropertyValueDraft> values;
  final PropertyDefinitionFormStatus status;
  final ProductPropertyDefinition? savedDefinition;
  final String? message;
  final int valueCounter;
  final String? pendingValueImageUrl;

  bool get isEditing => definitionId != null;

  factory PropertyDefinitionFormState.fromExisting(
    ProductPropertyDefinition? existing,
  ) {
    if (existing == null) {
      return const PropertyDefinitionFormState();
    }
    return PropertyDefinitionFormState(
      definitionId: existing.id,
      iconKey: existing.iconKey ?? 'category_outlined',
      values: existing.values
          .map(
            (value) => ProductPropertyValueDraft(
              valueId: value.id,
              valueAr: value.valueAr,
              valueEn: value.valueEn,
              imageUrl: value.imageUrl,
            ),
          )
          .toList(growable: false),
      valueCounter: existing.values.length,
    );
  }

  PropertyDefinitionFormState copyWith({
    String? definitionId,
    String? iconKey,
    List<ProductPropertyValueDraft>? values,
    PropertyDefinitionFormStatus? status,
    ProductPropertyDefinition? savedDefinition,
    String? message,
    int? valueCounter,
    String? pendingValueImageUrl,
    bool clearPendingValueImage = false,
    bool clearMessage = false,
  }) {
    return PropertyDefinitionFormState(
      definitionId: definitionId ?? this.definitionId,
      iconKey: iconKey ?? this.iconKey,
      values: values ?? this.values,
      status: status ?? this.status,
      savedDefinition: savedDefinition ?? this.savedDefinition,
      message: clearMessage ? null : (message ?? this.message),
      valueCounter: valueCounter ?? this.valueCounter,
      pendingValueImageUrl: clearPendingValueImage
          ? null
          : (pendingValueImageUrl ?? this.pendingValueImageUrl),
    );
  }

  @override
  List<Object?> get props => [
    definitionId,
    iconKey,
    values,
    status,
    savedDefinition,
    message,
    valueCounter,
    pendingValueImageUrl,
  ];
}
