part of 'property_definition_form_bloc.dart';

abstract class PropertyDefinitionFormEvent extends Equatable {
  const PropertyDefinitionFormEvent();

  @override
  List<Object?> get props => [];
}

class PropertyDefinitionFormSubmitted extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormSubmitted({
    required this.nameAr,
    required this.nameEn,
  });

  final String nameAr;
  final String nameEn;

  @override
  List<Object?> get props => [nameAr, nameEn];
}

class PropertyDefinitionFormValueAdded extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormValueAdded({
    required this.valueAr,
    required this.valueEn,
    this.imageUrl,
  });

  final String valueAr;
  final String valueEn;
  final String? imageUrl;

  @override
  List<Object?> get props => [valueAr, valueEn, imageUrl];
}

class PropertyDefinitionFormValueUpdated extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormValueUpdated({
    required this.target,
    required this.valueAr,
    required this.valueEn,
    this.imageUrl,
  });

  final ProductPropertyValueDraft target;
  final String valueAr;
  final String valueEn;
  final String? imageUrl;

  @override
  List<Object?> get props => [target, valueAr, valueEn, imageUrl];
}

class PropertyDefinitionFormValueRemoved extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormValueRemoved(this.target);

  final ProductPropertyValueDraft target;

  @override
  List<Object?> get props => [target];
}

class PropertyDefinitionFormValueImagePicked
    extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormValueImagePicked({
    required this.pick,
    this.target,
  });

  final LocalMediaPick pick;
  final ProductPropertyValueDraft? target;

  @override
  List<Object?> get props => [pick, target];
}

class PropertyDefinitionFormIconChanged extends PropertyDefinitionFormEvent {
  const PropertyDefinitionFormIconChanged(this.iconKey);

  final String iconKey;

  @override
  List<Object?> get props => [iconKey];
}
