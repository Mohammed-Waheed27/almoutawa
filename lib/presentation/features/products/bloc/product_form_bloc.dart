import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/form_media_item.dart';
import '../../../../domain/entities/local_media_pick.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_property.dart';
import '../../../../domain/entities/storage_quota.dart';
import '../../../../domain/usecases/product_usecases.dart';
import '../../../../domain/usecases/product_property_usecases.dart';
import '../../../../domain/usecases/storage_usecases.dart';

part 'product_form_event.dart';
part 'product_form_state.dart';

ProductFormState _productFormStateFromProduct(Product product) {
  var colorCounter = 0;
  final colors = product.colors
      .map((color) {
        colorCounter++;
        return ProductColorDraftEntry(
          localId: 'color_${color.id}',
          remoteColorId: color.id,
          name: color.name,
          nameEn: color.nameEn,
          hexCode: color.hexCode,
          images: color.images
              .map(FormMediaItem.remote)
              .toList(growable: false),
        );
      })
      .toList(growable: false);

  var propertyCounter = 0;
  final properties = product.properties
      .map((assignment) {
        propertyCounter++;
        final definition = assignment.definition;
        return ProductPropertyDraftEntry(
          localId: 'prop_${assignment.id}',
          definitionId: definition.id,
          nameAr: definition.nameAr,
          nameEn: definition.nameEn,
          iconKey: definition.iconKey,
          values: assignment.values
              .map(
                (value) => ProductPropertyValueDraft(
                  valueId: value.id,
                  valueAr: value.valueAr,
                  valueEn: value.valueEn,
                ),
              )
              .toList(growable: false),
        );
      })
      .toList(growable: false);

  return ProductFormState(
    editingProduct: product,
    pricingUnit: product.pricingUnit,
    productImages: product.images
        .map(FormMediaItem.remote)
        .toList(growable: false),
    colors: colors,
    properties: properties,
    colorCounter: colorCounter,
    propertyCounter: propertyCounter,
  );
}

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  ProductFormBloc({
    required CreateProductUseCase createProduct,
    required UpdateProductUseCase updateProduct,
    required FetchProductDetailUseCase fetchProductDetail,
    required FetchStorageQuotaUseCase fetchStorageQuota,
    required FetchProductPropertyDefinitionsUseCase fetchPropertyDefinitions,
    Product? existing,
  }) : _createProduct = createProduct,
       _updateProduct = updateProduct,
       _fetchProductDetail = fetchProductDetail,
       _fetchStorageQuota = fetchStorageQuota,
       _fetchPropertyDefinitions = fetchPropertyDefinitions,
       _seedProduct = existing,
       super(
         existing == null
             ? const ProductFormState()
             : _productFormStateFromProduct(existing),
       ) {
    on<ProductFormStarted>(_onStarted);
    on<ProductFormPricingUnitChanged>(_onPricingUnitChanged);
    on<ProductFormProductImagesAdded>(_onProductImagesAdded);
    on<ProductFormProductImageRemoved>(_onProductImageRemoved);
    on<ProductFormColorAdded>(_onColorAdded);
    on<ProductFormColorUpdated>(_onColorUpdated);
    on<ProductFormColorRemoved>(_onColorRemoved);
    on<ProductFormColorImagesAdded>(_onColorImagesAdded);
    on<ProductFormColorImageRemoved>(_onColorImageRemoved);
    on<ProductFormPropertyAddedFromCatalog>(_onPropertyAddedFromCatalog);
    on<ProductFormCustomPropertyAdded>(_onCustomPropertyAdded);
    on<ProductFormPropertyRemoved>(_onPropertyRemoved);
    on<ProductFormPropertyValueToggled>(_onPropertyValueToggled);
    on<ProductFormPropertyCustomValueAdded>(_onPropertyCustomValueAdded);
    on<ProductFormSubmitted>(_onSubmitted);
  }

  final CreateProductUseCase _createProduct;
  final UpdateProductUseCase _updateProduct;
  final FetchProductDetailUseCase _fetchProductDetail;
  final FetchStorageQuotaUseCase _fetchStorageQuota;
  final FetchProductPropertyDefinitionsUseCase _fetchPropertyDefinitions;
  final Product? _seedProduct;

  Future<void> _onStarted(
    ProductFormStarted event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingPropertyDefinitions: true,
        isHydrating: _seedProduct != null,
        clearMessage: true,
      ),
    );

    Product? editingProduct = _seedProduct;
    if (editingProduct != null) {
      final detailResult = await _fetchProductDetail(editingProduct.id);
      detailResult.fold(
        (failure) => dbgProductsError(
          'edit hydrate fetch failed',
          error: failure.message,
        ),
        (loaded) => editingProduct = loaded,
      );
    }

    StorageQuota? quota;
    var definitions = const <ProductPropertyDefinition>[];
    String? definitionsError;

    final quotaResult = await _fetchStorageQuota();
    quotaResult.fold(
      (failure) =>
          dbgProductsError('quota load failed', error: failure.message),
      (loaded) => quota = loaded,
    );

    final definitionsResult = await _fetchPropertyDefinitions();
    definitionsResult.fold(
      (failure) => definitionsError = failure.message,
      (loaded) => definitions = loaded,
    );

    if (definitionsError != null) {
      dbgProductsError(
        'property definitions load failed',
        error: definitionsError,
      );
      emit(
        (editingProduct == null
                ? state
                : _productFormStateFromProduct(editingProduct!))
            .copyWith(
              storageQuota: quota,
              isLoadingPropertyDefinitions: false,
              hasLoadedPropertyDefinitions: true,
              isHydrating: false,
              message: definitionsError,
            ),
      );
      return;
    }

    final hydratedBase = editingProduct == null
        ? state
        : _productFormStateFromProduct(editingProduct!);

    emit(
      hydratedBase.copyWith(
        status: ProductFormStatus.initial,
        storageQuota: quota,
        propertyDefinitions: definitions,
        isLoadingPropertyDefinitions: false,
        hasLoadedPropertyDefinitions: true,
        isHydrating: false,
        clearMessage: true,
      ),
    );
  }

  void _onPricingUnitChanged(
    ProductFormPricingUnitChanged event,
    Emitter<ProductFormState> emit,
  ) {
    emit(state.copyWith(pricingUnit: event.unit, clearMessage: true));
  }

  void _onProductImagesAdded(
    ProductFormProductImagesAdded event,
    Emitter<ProductFormState> emit,
  ) {
    final quota = state.storageQuota;
    if (quota == null) return;

    final next = [...state.productImages];
    for (final pick in event.picks) {
      if (next.length >= quota.maxProductImages) {
        emit(
          state.copyWith(
            message: 'الحد الأقصى ${quota.maxProductImages} صور للمنتج',
          ),
        );
        break;
      }
      final fileError = quota.validateFileSize(pick.sizeBytes);
      if (fileError != null) {
        emit(state.copyWith(message: fileError));
        continue;
      }
      if (!quota.canUploadBytes(state.pendingUploadBytes + pick.sizeBytes)) {
        emit(state.copyWith(message: 'مساحة التخزين غير كافية'));
        break;
      }
      next.add(FormMediaItem.local(pick));
    }

    emit(state.copyWith(productImages: next, clearMessage: true));
  }

  void _onProductImageRemoved(
    ProductFormProductImageRemoved event,
    Emitter<ProductFormState> emit,
  ) {
    emit(
      state.copyWith(
        productImages: state.productImages
            .where((item) => item.key != event.localId)
            .toList(growable: false),
        clearMessage: true,
      ),
    );
  }

  void _onColorAdded(
    ProductFormColorAdded event,
    Emitter<ProductFormState> emit,
  ) {
    final quota = state.storageQuota;
    if (quota == null) return;

    final name = event.name.trim();
    if (name.isEmpty) return;

    if (state.colors.length >= quota.maxColorsPerProduct) {
      emit(
        state.copyWith(
          message: 'الحد الأقصى ${quota.maxColorsPerProduct} ألوان للمنتج',
        ),
      );
      return;
    }

    final nextCounter = state.colorCounter + 1;
    emit(
      state.copyWith(
        colors: [
          ...state.colors,
          ProductColorDraftEntry(
            localId: 'color_$nextCounter',
            name: name,
            hexCode: event.hexCode?.trim(),
          ),
        ],
        colorCounter: nextCounter,
        clearMessage: true,
      ),
    );
  }

  void _onColorUpdated(
    ProductFormColorUpdated event,
    Emitter<ProductFormState> emit,
  ) {
    final next = state.colors
        .map(
          (color) => color.localId == event.localId
              ? color.copyWith(
                  name: event.name.trim(),
                  hexCode: event.hexCode?.trim(),
                )
              : color,
        )
        .toList(growable: false);
    emit(state.copyWith(colors: next, clearMessage: true));
  }

  void _onColorRemoved(
    ProductFormColorRemoved event,
    Emitter<ProductFormState> emit,
  ) {
    emit(
      state.copyWith(
        colors: state.colors
            .where((color) => color.localId != event.localId)
            .toList(growable: false),
        clearMessage: true,
      ),
    );
  }

  void _onColorImagesAdded(
    ProductFormColorImagesAdded event,
    Emitter<ProductFormState> emit,
  ) {
    final quota = state.storageQuota;
    if (quota == null) return;

    final nextColors = <ProductColorDraftEntry>[];
    for (final color in state.colors) {
      if (color.localId != event.colorLocalId) {
        nextColors.add(color);
        continue;
      }

      final images = [...color.images];
      for (final pick in event.picks) {
        if (images.length >= quota.maxColorImages) {
          emit(
            state.copyWith(
              message: 'الحد الأقصى ${quota.maxColorImages} صور لكل لون',
            ),
          );
          break;
        }
        final fileError = quota.validateFileSize(pick.sizeBytes);
        if (fileError != null) {
          emit(state.copyWith(message: fileError));
          continue;
        }
        if (!quota.canUploadBytes(state.pendingUploadBytes + pick.sizeBytes)) {
          emit(state.copyWith(message: 'مساحة التخزين غير كافية'));
          break;
        }
        images.add(FormMediaItem.local(pick));
      }
      nextColors.add(color.copyWith(images: images));
    }

    emit(state.copyWith(colors: nextColors, clearMessage: true));
  }

  void _onColorImageRemoved(
    ProductFormColorImageRemoved event,
    Emitter<ProductFormState> emit,
  ) {
    final nextColors = state.colors
        .map(
          (color) => color.localId == event.colorLocalId
              ? color.copyWith(
                  images: color.images
                      .where((img) => img.key != event.imageLocalId)
                      .toList(growable: false),
                )
              : color,
        )
        .toList(growable: false);

    emit(state.copyWith(colors: nextColors, clearMessage: true));
  }

  void _onPropertyAddedFromCatalog(
    ProductFormPropertyAddedFromCatalog event,
    Emitter<ProductFormState> emit,
  ) {
    if (state.properties.any(
      (item) => item.definitionId == event.definition.id,
    )) {
      emit(state.copyWith(message: 'هذه الخاصية مضافة بالفعل'));
      return;
    }

    final nextCounter = state.propertyCounter + 1;
    emit(
      state.copyWith(
        properties: [
          ...state.properties,
          ProductPropertyDraftEntry(
            localId: 'prop_$nextCounter',
            definitionId: event.definition.id,
            nameAr: event.definition.nameAr,
            nameEn: event.definition.nameEn,
            iconKey: event.definition.iconKey,
          ),
        ],
        propertyCounter: nextCounter,
        clearMessage: true,
      ),
    );
  }

  void _onCustomPropertyAdded(
    ProductFormCustomPropertyAdded event,
    Emitter<ProductFormState> emit,
  ) {
    final nameAr = event.nameAr.trim();
    final nameEn = event.nameEn.trim();
    if (nameAr.isEmpty) return;

    final nextCounter = state.propertyCounter + 1;
    emit(
      state.copyWith(
        properties: [
          ...state.properties,
          ProductPropertyDraftEntry(
            localId: 'prop_$nextCounter',
            nameAr: nameAr,
            nameEn: nameEn,
            iconKey: event.iconKey,
          ),
        ],
        propertyCounter: nextCounter,
        clearMessage: true,
      ),
    );
  }

  void _onPropertyRemoved(
    ProductFormPropertyRemoved event,
    Emitter<ProductFormState> emit,
  ) {
    emit(
      state.copyWith(
        properties: state.properties
            .where((item) => item.localId != event.localId)
            .toList(growable: false),
        clearMessage: true,
      ),
    );
  }

  void _onPropertyValueToggled(
    ProductFormPropertyValueToggled event,
    Emitter<ProductFormState> emit,
  ) {
    final next = state.properties
        .map((property) {
          if (property.localId != event.localId) return property;

          final exists = property.values.any(
            (value) =>
                (event.valueId != null && value.valueId == event.valueId) ||
                (value.valueAr == event.valueAr &&
                    value.valueEn == event.valueEn),
          );

          if (exists) {
            return property.copyWith(
              values: property.values
                  .where(
                    (value) =>
                        !((event.valueId != null &&
                                value.valueId == event.valueId) ||
                            (value.valueAr == event.valueAr &&
                                value.valueEn == event.valueEn)),
                  )
                  .toList(growable: false),
            );
          }

          return property.copyWith(
            values: [
              ...property.values,
              ProductPropertyValueDraft(
                valueId: event.valueId,
                valueAr: event.valueAr,
                valueEn: event.valueEn,
              ),
            ],
          );
        })
        .toList(growable: false);

    emit(state.copyWith(properties: next, clearMessage: true));
  }

  void _onPropertyCustomValueAdded(
    ProductFormPropertyCustomValueAdded event,
    Emitter<ProductFormState> emit,
  ) {
    final valueAr = event.valueAr.trim();
    final valueEn = event.valueEn.trim();
    if (valueAr.isEmpty) return;

    final next = state.properties
        .map((property) {
          if (property.localId != event.localId) return property;
          return property.copyWith(
            values: [
              ...property.values,
              ProductPropertyValueDraft(valueAr: valueAr, valueEn: valueEn),
            ],
          );
        })
        .toList(growable: false);

    emit(state.copyWith(properties: next, clearMessage: true));
  }

  Future<void> _onSubmitted(
    ProductFormSubmitted event,
    Emitter<ProductFormState> emit,
  ) async {
    final draft = state.toDraft(
      name: event.name,
      nameEn: event.nameEn,
      description: event.description,
    );
    final validationError = draft.validationError;
    if (validationError != null) {
      dbgProducts('form submit blocked validation=$validationError');
      emit(
        state.copyWith(
          status: ProductFormStatus.failure,
          message: validationError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: ProductFormStatus.submitting, clearMessage: true),
    );

    final result = draft.isEditing
        ? await _updateProduct(
            productId: draft.productId!,
            draft: draft,
            baseline: state.editingProduct!,
          )
        : await _createProduct(draft);

    result.fold(
      (failure) {
        dbgProductsError('form submit failed', error: failure.message);
        emit(
          state.copyWith(
            status: ProductFormStatus.failure,
            message: failure.message,
          ),
        );
      },
      (product) {
        dbgProducts(
          'form submit ok id=${product.id} editing=${draft.isEditing}',
        );
        emit(
          state.copyWith(
            status: ProductFormStatus.success,
            savedProduct: product,
            editingProduct: product,
          ),
        );
      },
    );
  }
}
