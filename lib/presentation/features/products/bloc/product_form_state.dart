part of 'product_form_bloc.dart';

enum ProductFormStatus { initial, loading, submitting, success, failure }

class ProductColorDraftEntry extends Equatable {
  const ProductColorDraftEntry({
    required this.localId,
    this.remoteColorId,
    required this.name,
    this.nameEn,
    this.hexCode,
    this.images = const [],
  });

  final String localId;
  final String? remoteColorId;
  final String name;
  final String? nameEn;
  final String? hexCode;
  final List<FormMediaItem> images;

  ProductColorDraftEntry copyWith({
    String? name,
    String? nameEn,
    bool clearNameEn = false,
    String? hexCode,
    List<FormMediaItem>? images,
  }) {
    return ProductColorDraftEntry(
      localId: localId,
      remoteColorId: remoteColorId,
      name: name ?? this.name,
      nameEn: clearNameEn ? null : (nameEn ?? this.nameEn),
      hexCode: hexCode ?? this.hexCode,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [localId, remoteColorId, name, nameEn, hexCode, images];
}

class ProductPropertyDraftEntry extends Equatable {
  const ProductPropertyDraftEntry({
    required this.localId,
    this.definitionId,
    required this.nameAr,
    required this.nameEn,
    this.iconKey,
    this.values = const [],
  });

  final String localId;
  final String? definitionId;
  final String nameAr;
  final String nameEn;
  final String? iconKey;
  final List<ProductPropertyValueDraft> values;

  ProductPropertyDraftEntry copyWith({
    String? nameAr,
    String? nameEn,
    String? iconKey,
    List<ProductPropertyValueDraft>? values,
  }) {
    return ProductPropertyDraftEntry(
      localId: localId,
      definitionId: definitionId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      iconKey: iconKey ?? this.iconKey,
      values: values ?? this.values,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    definitionId,
    nameAr,
    nameEn,
    iconKey,
    values,
  ];
}

class ProductFormState extends Equatable {
  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.editingProduct,
    this.pricingUnit = ProductPricingUnit.meter,
    this.productImages = const [],
    this.colors = const [],
    this.properties = const [],
    this.propertyDefinitions = const [],
    this.storageQuota,
    this.savedProduct,
    this.message,
    this.colorCounter = 0,
    this.propertyCounter = 0,
    this.isLoadingPropertyDefinitions = false,
    this.hasLoadedPropertyDefinitions = false,
    this.isHydrating = false,
  });

  final ProductFormStatus status;
  final Product? editingProduct;
  final ProductPricingUnit pricingUnit;
  final List<FormMediaItem> productImages;
  final List<ProductColorDraftEntry> colors;
  final List<ProductPropertyDraftEntry> properties;
  final List<ProductPropertyDefinition> propertyDefinitions;
  final StorageQuota? storageQuota;
  final Product? savedProduct;
  final String? message;
  final int colorCounter;
  final int propertyCounter;
  final bool isLoadingPropertyDefinitions;
  final bool hasLoadedPropertyDefinitions;
  final bool isHydrating;

  bool get isEditing => editingProduct != null;

  bool get showBlockingSpinner =>
      isHydrating ||
      (isLoadingPropertyDefinitions && !hasLoadedPropertyDefinitions);

  int get pendingUploadBytes =>
      productImages
          .where((item) => item.isLocal)
          .fold<int>(0, (sum, item) => sum + item.sizeBytes) +
      colors.fold<int>(
        0,
        (sum, color) =>
            sum +
            color.images
                .where((item) => item.isLocal)
                .fold<int>(0, (s, img) => s + img.sizeBytes),
      );

  ProductDraft toDraft({
    required String name,
    String? nameEn,
    required String description,
  }) {
    return ProductDraft(
      productId: editingProduct?.id,
      name: name,
      nameEn: nameEn?.trim().isEmpty ?? true ? null : nameEn?.trim(),
      description: description,
      unitPrice: editingProduct?.unitPrice ?? 0,
      pricingUnit: pricingUnit,
      productImages: productImages,
      colors: colors
          .map(
            (entry) => ProductColorDraft(
              remoteColorId: entry.remoteColorId,
              name: entry.name,
              nameEn: entry.nameEn?.trim().isEmpty ?? true
                  ? null
                  : entry.nameEn?.trim(),
              hexCode: entry.hexCode,
              images: entry.images,
            ),
          )
          .toList(growable: false),
      properties: properties
          .map(
            (entry) => ProductPropertyAssignmentDraft(
              localId: entry.localId,
              definitionId: entry.definitionId,
              nameAr: entry.nameAr,
              nameEn: entry.nameEn,
              iconKey: entry.iconKey,
              values: entry.values,
            ),
          )
          .toList(growable: false),
    );
  }

  ProductFormState copyWith({
    ProductFormStatus? status,
    Product? editingProduct,
    bool clearEditingProduct = false,
    ProductPricingUnit? pricingUnit,
    List<FormMediaItem>? productImages,
    List<ProductColorDraftEntry>? colors,
    List<ProductPropertyDraftEntry>? properties,
    List<ProductPropertyDefinition>? propertyDefinitions,
    StorageQuota? storageQuota,
    Product? savedProduct,
    String? message,
    int? colorCounter,
    int? propertyCounter,
    bool? isLoadingPropertyDefinitions,
    bool? hasLoadedPropertyDefinitions,
    bool? isHydrating,
    bool clearMessage = false,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      editingProduct: clearEditingProduct
          ? null
          : (editingProduct ?? this.editingProduct),
      pricingUnit: pricingUnit ?? this.pricingUnit,
      productImages: productImages ?? this.productImages,
      colors: colors ?? this.colors,
      properties: properties ?? this.properties,
      propertyDefinitions: propertyDefinitions ?? this.propertyDefinitions,
      storageQuota: storageQuota ?? this.storageQuota,
      savedProduct: savedProduct ?? this.savedProduct,
      message: clearMessage ? null : (message ?? this.message),
      colorCounter: colorCounter ?? this.colorCounter,
      propertyCounter: propertyCounter ?? this.propertyCounter,
      isLoadingPropertyDefinitions:
          isLoadingPropertyDefinitions ?? this.isLoadingPropertyDefinitions,
      hasLoadedPropertyDefinitions:
          hasLoadedPropertyDefinitions ?? this.hasLoadedPropertyDefinitions,
      isHydrating: isHydrating ?? this.isHydrating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    editingProduct,
    pricingUnit,
    productImages,
    colors,
    properties,
    propertyDefinitions,
    storageQuota,
    savedProduct,
    message,
    colorCounter,
    propertyCounter,
    isLoadingPropertyDefinitions,
    hasLoadedPropertyDefinitions,
    isHydrating,
  ];
}
