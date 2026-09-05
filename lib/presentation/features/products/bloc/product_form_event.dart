part of 'product_form_bloc.dart';

abstract class ProductFormEvent extends Equatable {
  const ProductFormEvent();

  @override
  List<Object?> get props => [];
}

class ProductFormStarted extends ProductFormEvent {
  const ProductFormStarted();
}

class ProductFormPricingUnitChanged extends ProductFormEvent {
  const ProductFormPricingUnitChanged(this.unit);

  final ProductPricingUnit unit;

  @override
  List<Object?> get props => [unit];
}

class ProductFormProductImagesAdded extends ProductFormEvent {
  const ProductFormProductImagesAdded(this.picks);

  final List<LocalMediaPick> picks;

  @override
  List<Object?> get props => [picks];
}

class ProductFormProductImageRemoved extends ProductFormEvent {
  const ProductFormProductImageRemoved(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class ProductFormColorAdded extends ProductFormEvent {
  const ProductFormColorAdded({required this.name, this.hexCode});

  final String name;
  final String? hexCode;

  @override
  List<Object?> get props => [name, hexCode];
}

class ProductFormColorUpdated extends ProductFormEvent {
  const ProductFormColorUpdated({
    required this.localId,
    required this.name,
    this.hexCode,
  });

  final String localId;
  final String name;
  final String? hexCode;

  @override
  List<Object?> get props => [localId, name, hexCode];
}

class ProductFormColorRemoved extends ProductFormEvent {
  const ProductFormColorRemoved(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class ProductFormColorImagesAdded extends ProductFormEvent {
  const ProductFormColorImagesAdded({
    required this.colorLocalId,
    required this.picks,
  });

  final String colorLocalId;
  final List<LocalMediaPick> picks;

  @override
  List<Object?> get props => [colorLocalId, picks];
}

class ProductFormColorImageRemoved extends ProductFormEvent {
  const ProductFormColorImageRemoved({
    required this.colorLocalId,
    required this.imageLocalId,
  });

  final String colorLocalId;
  final String imageLocalId;

  @override
  List<Object?> get props => [colorLocalId, imageLocalId];
}

class ProductFormPropertyAddedFromCatalog extends ProductFormEvent {
  const ProductFormPropertyAddedFromCatalog(this.definition);

  final ProductPropertyDefinition definition;

  @override
  List<Object?> get props => [definition];
}

class ProductFormCustomPropertyAdded extends ProductFormEvent {
  const ProductFormCustomPropertyAdded({
    required this.nameAr,
    required this.nameEn,
    this.iconKey,
  });

  final String nameAr;
  final String nameEn;
  final String? iconKey;

  @override
  List<Object?> get props => [nameAr, nameEn, iconKey];
}

class ProductFormPropertyRemoved extends ProductFormEvent {
  const ProductFormPropertyRemoved(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class ProductFormPropertyValueToggled extends ProductFormEvent {
  const ProductFormPropertyValueToggled({
    required this.localId,
    this.valueId,
    required this.valueAr,
    required this.valueEn,
  });

  final String localId;
  final String? valueId;
  final String valueAr;
  final String valueEn;

  @override
  List<Object?> get props => [localId, valueId, valueAr, valueEn];
}

class ProductFormPropertyCustomValueAdded extends ProductFormEvent {
  const ProductFormPropertyCustomValueAdded({
    required this.localId,
    required this.valueAr,
    required this.valueEn,
  });

  final String localId;
  final String valueAr;
  final String valueEn;

  @override
  List<Object?> get props => [localId, valueAr, valueEn];
}

class ProductFormSubmitted extends ProductFormEvent {
  const ProductFormSubmitted({
    required this.name,
    this.nameEn,
    required this.description,
  });

  final String name;
  final String? nameEn;
  final String description;

  @override
  List<Object?> get props => [name, nameEn, description];
}
