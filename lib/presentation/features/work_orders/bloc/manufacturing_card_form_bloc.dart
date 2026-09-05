import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/local_media_pick.dart';
import '../../../../domain/entities/manufacturing_card.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/product_property.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';
import '../../../../domain/usecases/product_property_usecases.dart';
import '../../../../domain/usecases/product_usecases.dart';

class ManufacturingCardFormBloc
    extends Bloc<ManufacturingCardFormEvent, ManufacturingCardFormState> {
  ManufacturingCardFormBloc({
    required FetchCommercialOrderDetailUseCase fetchDetail,
    required FetchManufacturingCardsUseCase fetchCards,
    required SaveManufacturingCardUseCase saveCard,
    required FetchProductDetailUseCase fetchProductDetail,
    required FetchProductPropertyDefinitionsUseCase fetchPropertyDefinitions,
    required AppendProductImageUseCase appendProductImage,
    required AppendColorImageUseCase appendColorImage,
    required UploadPublicMediaUseCase uploadPublicMedia,
  }) : _fetchDetail = fetchDetail,
       _fetchCards = fetchCards,
       _saveCard = saveCard,
       _fetchProductDetail = fetchProductDetail,
       _fetchPropertyDefinitions = fetchPropertyDefinitions,
       _appendProductImage = appendProductImage,
       _appendColorImage = appendColorImage,
       _uploadPublicMedia = uploadPublicMedia,
       super(const ManufacturingCardFormState()) {
    on<ManufacturingCardFormStarted>(_onStarted);
    on<ManufacturingCardFormModelChanged>(_onModelChanged);
    on<ManufacturingCardFormDimsChanged>(_onDimsChanged);
    on<ManufacturingCardFormColorProductPicked>(_onColorProductPicked);
    on<ManufacturingCardFormColorManualChanged>(_onColorManualChanged);
    on<ManufacturingCardFormPropertyAdded>(_onPropertyAdded);
    on<ManufacturingCardFormPropertyUpdated>(_onPropertyUpdated);
    on<ManufacturingCardFormPropertyRemoved>(_onPropertyRemoved);
    on<ManufacturingCardFormPropertyAddedFromCatalog>(
      _onPropertyAddedFromCatalog,
    );
    on<ManufacturingCardFormAlertNoteChanged>(_onAlertNoteChanged);
    on<ManufacturingCardFormNotesChanged>(_onNotesChanged);
    on<ManufacturingCardFormClientSignedToggled>(_onClientSignedToggled);
    on<ManufacturingCardFormProductImagePicked>(_onProductImagePicked);
    on<ManufacturingCardFormColorImagePicked>(_onColorImagePicked);
    on<ManufacturingCardFormProductImageCleared>(_onProductImageCleared);
    on<ManufacturingCardFormColorImageCleared>(_onColorImageCleared);
    on<ManufacturingCardFormPropertyImagePicked>(_onPropertyImagePicked);
    on<ManufacturingCardFormSubmitted>(_onSubmitted);
  }

  final FetchCommercialOrderDetailUseCase _fetchDetail;
  final FetchManufacturingCardsUseCase _fetchCards;
  final SaveManufacturingCardUseCase _saveCard;
  final FetchProductDetailUseCase _fetchProductDetail;
  final FetchProductPropertyDefinitionsUseCase _fetchPropertyDefinitions;
  final AppendProductImageUseCase _appendProductImage;
  final AppendColorImageUseCase _appendColorImage;
  final UploadPublicMediaUseCase _uploadPublicMedia;

  Future<void> _onStarted(
    ManufacturingCardFormStarted event,
    Emitter<ManufacturingCardFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ManufacturingCardFormStatus.loading,
        orderId: event.orderId,
        targetLineId: event.agreementLineId,
        targetCardIndex: event.cardIndex,
      ),
    );

    final detailResult = await _fetchDetail(event.orderId);
    final cardsResult = await _fetchCards(event.orderId);
    final defsResult = await _fetchPropertyDefinitions();

    CommercialOrderDetail? detail;
    List<ManufacturingCard> cards = const [];
    List<ProductPropertyDefinition> definitions = const [];
    String? error;

    detailResult.fold((f) => error = f.message, (v) => detail = v);
    cardsResult.fold((f) => error ??= f.message, (v) => cards = v);
    defsResult.fold((f) {}, (v) => definitions = v);

    if (error != null || detail == null) {
      dbgWorkOrdersError('card form load failed', error: error);
      emit(
        state.copyWith(
          status: ManufacturingCardFormStatus.failure,
          message: error,
        ),
      );
      return;
    }

    final agreement = detail!.agreement;
    if (agreement == null) {
      emit(
        state.copyWith(
          status: ManufacturingCardFormStatus.failure,
          message: 'لا توجد اتفاقية لهذا الطلب',
        ),
      );
      return;
    }

    AgreementLine? targetLine;
    for (final line in agreement.lines) {
      if (line.id == event.agreementLineId) {
        targetLine = line;
        break;
      }
    }

    if (targetLine == null) {
      emit(
        state.copyWith(
          status: ManufacturingCardFormStatus.failure,
          message: 'بند الاتفاقية غير موجود',
        ),
      );
      return;
    }

    ManufacturingCard? existingCard;
    for (final card in cards) {
      if (card.agreementLineId == event.agreementLineId &&
          card.cardIndex == event.cardIndex) {
        existingCard = card;
        break;
      }
    }

    Product? linkedProduct;
    if (targetLine.productId != null) {
      final productResult = await _fetchProductDetail(targetLine.productId!);
      productResult.fold(
        (f) => dbgWorkOrdersError(
          'card form product load failed',
          error: f.message,
        ),
        (v) => linkedProduct = v,
      );
    }

    final seededState = _seedState(
      detail: detail!,
      agreement: agreement,
      targetLine: targetLine,
      cardIndex: event.cardIndex,
      existingCard: existingCard,
      linkedProduct: linkedProduct,
      definitions: definitions,
    );

    dbgWorkOrders(
      'card form loaded orderId=${event.orderId} lineId=${event.agreementLineId} cardIndex=${event.cardIndex} editing=${existingCard != null}',
    );

    emit(seededState);
  }

  ManufacturingCardFormState _seedState({
    required CommercialOrderDetail detail,
    required OrderAgreement agreement,
    required AgreementLine targetLine,
    required int cardIndex,
    ManufacturingCard? existingCard,
    Product? linkedProduct,
    required List<ProductPropertyDefinition> definitions,
  }) {
    final card = existingCard;
    final modelNameAr =
        card?.modelNameAr ??
        linkedProduct?.name ??
        targetLine.description.trim();
    final modelNameEn = card?.modelNameEn ?? linkedProduct?.nameEn;
    final widthCm = card?.widthCm ?? targetLine.widthCm ?? 0.0;
    final heightCm = card?.heightCm ?? targetLine.heightCm ?? 0.0;

    final colorNameAr = card?.colorNameAr ?? targetLine.color ?? '';
    final colorNameEn = card?.colorNameEn;
    final colorCode = card?.colorCode;
    final colorImageUrl = card?.colorImageUrl;

    final List<ManufacturingCardPropertyDraft> properties;
    if (card != null && card.properties.isNotEmpty) {
      properties = card.properties
          .map(
            (p) => ManufacturingCardPropertyDraft(
              definitionId: p.definitionId,
              valueId: p.valueId,
              nameAr: p.nameAr,
              nameEn: p.nameEn,
              valueAr: p.valueAr,
              valueEn: p.valueEn,
              iconKey: p.iconKey,
              imageUrl: p.imageUrl,
              sortOrder: p.sortOrder,
            ),
          )
          .toList();
    } else if (linkedProduct != null && linkedProduct.properties.isNotEmpty) {
      final seeded = <ManufacturingCardPropertyDraft>[];
      for (final assignment in linkedProduct.properties) {
        if (assignment.values.isEmpty) continue;
        final def = assignment.definition;
        final firstValue = assignment.values.first;
        seeded.add(
          ManufacturingCardPropertyDraft(
            definitionId: def.id,
            valueId: firstValue.id,
            nameAr: def.nameAr,
            nameEn: def.nameEn.isEmpty ? null : def.nameEn,
            valueAr: firstValue.valueAr,
            valueEn: firstValue.valueEn.isEmpty ? null : firstValue.valueEn,
            iconKey: def.iconKey,
            imageUrl: firstValue.imageUrl,
            sortOrder: seeded.length,
          ),
        );
      }
      properties = seeded;
    } else {
      properties = const [];
    }

    return ManufacturingCardFormState(
      status: ManufacturingCardFormStatus.ready,
      orderId: detail.order.id,
      agreementId: agreement.id,
      detail: detail,
      targetLine: targetLine,
      targetCardIndex: cardIndex,
      existingCard: existingCard,
      linkedProduct: linkedProduct,
      propertyDefinitions: definitions,
      modelNameAr: modelNameAr,
      modelNameEn: modelNameEn,
      widthCm: widthCm,
      heightCm: heightCm,
      colorNameAr: colorNameAr,
      colorNameEn: colorNameEn,
      colorCode: colorCode,
      colorImageUrl: colorImageUrl,
      productImageUrl: card?.productImageUrl ?? linkedProduct?.coverImageUrl,
      properties: properties,
      alertNote: card?.alertNote ?? defaultManufacturingCardAlert,
      notes: card?.notes,
      clientSigned: card?.clientSigned ?? false,
    );
  }

  void _onModelChanged(
    ManufacturingCardFormModelChanged event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(
      state.copyWith(
        modelNameAr: event.modelNameAr,
        modelNameEn: event.modelNameEn,
      ),
    );
  }

  void _onDimsChanged(
    ManufacturingCardFormDimsChanged event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(widthCm: event.widthCm, heightCm: event.heightCm));
  }

  void _onColorProductPicked(
    ManufacturingCardFormColorProductPicked event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    final color = event.color;
    if (color == null) {
      emit(
        state.copyWith(
          colorNameAr: '',
          clearColorNameEn: true,
          clearColorCode: true,
          clearColorImageUrl: true,
          clearPickedColor: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        pickedProductColor: color,
        colorNameAr: color.name,
        colorNameEn: color.nameEn,
        colorCode: color.hexCode,
        colorImageUrl:
            color.colorImageUrl ??
            (color.images.isNotEmpty ? color.images.first.publicUrl : null),
      ),
    );
  }

  void _onColorManualChanged(
    ManufacturingCardFormColorManualChanged event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(
      state.copyWith(
        colorNameAr: event.colorNameAr,
        colorNameEn: event.colorNameEn,
        colorCode: event.colorCode,
        clearPickedColor: true,
      ),
    );
  }

  void _onPropertyAdded(
    ManufacturingCardFormPropertyAdded event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    final props = [...state.properties, event.property];
    emit(state.copyWith(properties: _reindexed(props)));
  }

  void _onPropertyUpdated(
    ManufacturingCardFormPropertyUpdated event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    if (event.index < 0 || event.index >= state.properties.length) return;
    final props = [...state.properties];
    props[event.index] = event.property;
    emit(state.copyWith(properties: props));
  }

  void _onPropertyRemoved(
    ManufacturingCardFormPropertyRemoved event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    final props = [...state.properties]..removeAt(event.index);
    emit(state.copyWith(properties: _reindexed(props)));
  }

  void _onPropertyAddedFromCatalog(
    ManufacturingCardFormPropertyAddedFromCatalog event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    final def = event.definition;
    if (state.properties.any((p) => p.definitionId == def.id)) {
      emit(state.copyWith(message: 'هذه الخاصية مضافة بالفعل'));
      return;
    }
    final props = [
      ...state.properties,
      ManufacturingCardPropertyDraft(
        definitionId: def.id,
        nameAr: def.nameAr,
        nameEn: def.nameEn,
        valueAr: def.values.isNotEmpty ? def.values.first.valueAr : '',
        valueEn: def.values.isNotEmpty ? def.values.first.valueEn : null,
        valueId: def.values.isNotEmpty ? def.values.first.id : null,
        iconKey: def.iconKey,
        imageUrl: def.values.isNotEmpty ? def.values.first.imageUrl : null,
        sortOrder: state.properties.length,
      ),
    ];
    emit(state.copyWith(properties: _reindexed(props), message: null));
  }

  void _onAlertNoteChanged(
    ManufacturingCardFormAlertNoteChanged event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(alertNote: event.note));
  }

  void _onNotesChanged(
    ManufacturingCardFormNotesChanged event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(notes: event.notes.isEmpty ? null : event.notes));
  }

  void _onClientSignedToggled(
    ManufacturingCardFormClientSignedToggled event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(clientSigned: !state.clientSigned));
  }

  Future<void> _onProductImagePicked(
    ManufacturingCardFormProductImagePicked event,
    Emitter<ManufacturingCardFormState> emit,
  ) async {
    emit(state.copyWith(message: null));
    final productId = state.linkedProduct?.id;
    if (productId != null) {
      final result = await _appendProductImage(
        productId: productId,
        pick: event.pick,
      );
      final appended = result.fold<Product?>(
        (failure) {
          emit(state.copyWith(message: failure.message));
          return null;
        },
        (product) => product,
      );
      if (appended != null) {
        emit(
          state.copyWith(
            linkedProduct: appended,
            productImageUrl: appended.coverImageUrl,
            message: 'تم رفع صورة الباب',
          ),
        );
        return;
      }
    }

    final loose = await _uploadPublicMedia(
      folder: 'cards/${state.orderId ?? 'loose'}/door',
      pick: event.pick,
    );
    loose.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (url) => emit(
        state.copyWith(productImageUrl: url, message: 'تم رفع صورة الباب'),
      ),
    );
  }

  Future<void> _onColorImagePicked(
    ManufacturingCardFormColorImagePicked event,
    Emitter<ManufacturingCardFormState> emit,
  ) async {
    emit(state.copyWith(message: null));
    final productId = state.linkedProduct?.id;
    final colorId = state.pickedProductColor?.id;
    if (productId != null && colorId != null) {
      final result = await _appendColorImage(
        productId: productId,
        colorId: colorId,
        pick: event.pick,
      );
      final appended = result.fold<Product?>(
        (failure) {
          emit(state.copyWith(message: failure.message));
          return null;
        },
        (product) => product,
      );
      if (appended != null) {
        final color = appended.colors.where((item) => item.id == colorId);
        emit(
          state.copyWith(
            linkedProduct: appended,
            pickedProductColor: color.isEmpty
                ? state.pickedProductColor
                : color.first,
            colorImageUrl: color.isEmpty
                ? state.colorImageUrl
                : color.first.coverImageUrl,
            message: 'تم رفع صورة اللون',
          ),
        );
        return;
      }
    }

    final loose = await _uploadPublicMedia(
      folder: 'cards/${state.orderId ?? 'loose'}/color',
      pick: event.pick,
    );
    loose.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (url) => emit(
        state.copyWith(colorImageUrl: url, message: 'تم رفع صورة اللون'),
      ),
    );
  }

  void _onProductImageCleared(
    ManufacturingCardFormProductImageCleared event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(productImageUrl: '', message: 'تم حذف صورة الباب'));
  }

  void _onColorImageCleared(
    ManufacturingCardFormColorImageCleared event,
    Emitter<ManufacturingCardFormState> emit,
  ) {
    emit(state.copyWith(colorImageUrl: '', message: 'تم حذف صورة اللون'));
  }

  Future<void> _onPropertyImagePicked(
    ManufacturingCardFormPropertyImagePicked event,
    Emitter<ManufacturingCardFormState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.properties.length) return;
    emit(state.copyWith(message: null));
    final result = await _uploadPublicMedia(
      folder: 'property-values/card-${state.orderId ?? 'loose'}',
      pick: event.pick,
    );
    result.fold((failure) => emit(state.copyWith(message: failure.message)), (
      url,
    ) {
      final props = [...state.properties];
      final current = props[event.index];
      props[event.index] = ManufacturingCardPropertyDraft(
        definitionId: current.definitionId,
        valueId: current.valueId,
        nameAr: current.nameAr,
        nameEn: current.nameEn,
        valueAr: current.valueAr,
        valueEn: current.valueEn,
        iconKey: current.iconKey,
        imageUrl: url,
        sortOrder: current.sortOrder,
      );
      emit(state.copyWith(properties: props, message: 'تم رفع صورة القيمة'));
    });
  }

  Future<void> _onSubmitted(
    ManufacturingCardFormSubmitted event,
    Emitter<ManufacturingCardFormState> emit,
  ) async {
    final orderId = state.orderId;
    final agreementId = state.agreementId;
    final lineId = state.targetLine?.id;
    final cardIndex = state.targetCardIndex;

    if (orderId == null ||
        agreementId == null ||
        lineId == null ||
        cardIndex == null)
      return;

    if (state.isReadOnly) {
      emit(
        state.copyWith(
          message: 'لا يمكن تعديل بطاقة التصنيع بعد اكتمال الطلب',
        ),
      );
      return;
    }

    final productImageUrl =
        state.productImageUrl ??
        state.linkedProduct?.coverImageUrl ??
        state.existingCard?.productImageUrl;

    final colorImageUrl =
        state.colorImageUrl ??
        state.pickedProductColor?.colorImageUrl ??
        (state.pickedProductColor != null &&
                state.pickedProductColor!.images.isNotEmpty
            ? state.pickedProductColor!.images.first.publicUrl
            : state.existingCard?.colorImageUrl);

    final draft = ManufacturingCardDraft(
      cardId: state.existingCard?.id,
      agreementLineId: lineId,
      cardIndex: cardIndex,
      productId: state.linkedProduct?.id ?? state.targetLine?.productId,
      modelNameAr: state.modelNameAr.trim(),
      modelNameEn: state.modelNameEn?.trim().isEmpty ?? true
          ? null
          : state.modelNameEn?.trim(),
      widthCm: state.widthCm,
      heightCm: state.heightCm,
      colorId: state.pickedProductColor?.id ?? state.existingCard?.colorId,
      colorNameAr: state.colorNameAr.trim().isEmpty
          ? null
          : state.colorNameAr.trim(),
      colorNameEn: state.colorNameEn?.trim().isEmpty ?? true
          ? null
          : state.colorNameEn?.trim(),
      colorCode: state.colorCode?.trim().isEmpty ?? true
          ? null
          : state.colorCode?.trim(),
      productImageUrl: productImageUrl,
      colorImageUrl: colorImageUrl,
      alertNote: state.alertNote.trim().isEmpty
          ? defaultManufacturingCardAlert
          : state.alertNote.trim(),
      notes: state.notes?.trim().isEmpty ?? true ? null : state.notes?.trim(),
      clientSigned: state.clientSigned,
      properties: state.properties,
      sortOrder: state.targetCardIndex ?? 0,
    );

    final validationError = draft.validationError;
    if (validationError != null) {
      dbgWorkOrders('card form blocked validation=$validationError');
      emit(state.copyWith(message: validationError));
      return;
    }

    emit(
      state.copyWith(status: ManufacturingCardFormStatus.saving, message: null),
    );

    final result = await _saveCard(
      orderId: orderId,
      agreementId: agreementId,
      draft: draft,
    );

    result.fold(
      (failure) {
        dbgWorkOrdersError('card save failed', error: failure.message);
        emit(
          state.copyWith(
            status: ManufacturingCardFormStatus.ready,
            message: failure.message,
          ),
        );
      },
      (card) {
        dbgWorkOrders('card saved id=${card.id}');
        emit(
          state.copyWith(
            status: ManufacturingCardFormStatus.success,
            savedCard: card,
            existingCard: card,
            message: 'تم حفظ البطاقة',
          ),
        );
      },
    );
  }

  List<ManufacturingCardPropertyDraft> _reindexed(
    List<ManufacturingCardPropertyDraft> props,
  ) {
    return [
      for (var i = 0; i < props.length; i++)
        ManufacturingCardPropertyDraft(
          definitionId: props[i].definitionId,
          valueId: props[i].valueId,
          nameAr: props[i].nameAr,
          nameEn: props[i].nameEn,
          valueAr: props[i].valueAr,
          valueEn: props[i].valueEn,
          iconKey: props[i].iconKey,
          imageUrl: props[i].imageUrl,
          sortOrder: i,
        ),
    ];
  }
}

// ── Events ──────────────────────────────────────────────────────────────────

sealed class ManufacturingCardFormEvent extends Equatable {
  const ManufacturingCardFormEvent();
  @override
  List<Object?> get props => [];
}

class ManufacturingCardFormStarted extends ManufacturingCardFormEvent {
  const ManufacturingCardFormStarted({
    required this.orderId,
    required this.agreementLineId,
    required this.cardIndex,
  });
  final String orderId;
  final String agreementLineId;
  final int cardIndex;
  @override
  List<Object?> get props => [orderId, agreementLineId, cardIndex];
}

class ManufacturingCardFormModelChanged extends ManufacturingCardFormEvent {
  const ManufacturingCardFormModelChanged({
    required this.modelNameAr,
    this.modelNameEn,
  });
  final String modelNameAr;
  final String? modelNameEn;
}

class ManufacturingCardFormDimsChanged extends ManufacturingCardFormEvent {
  const ManufacturingCardFormDimsChanged({
    required this.widthCm,
    required this.heightCm,
  });
  final double widthCm;
  final double heightCm;
}

class ManufacturingCardFormColorProductPicked
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormColorProductPicked(this.color);
  final ProductColor? color;
  @override
  List<Object?> get props => [color];
}

class ManufacturingCardFormColorManualChanged
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormColorManualChanged({
    required this.colorNameAr,
    this.colorNameEn,
    this.colorCode,
  });
  final String colorNameAr;
  final String? colorNameEn;
  final String? colorCode;
}

class ManufacturingCardFormPropertyAdded extends ManufacturingCardFormEvent {
  const ManufacturingCardFormPropertyAdded(this.property);
  final ManufacturingCardPropertyDraft property;
  @override
  List<Object?> get props => [property];
}

class ManufacturingCardFormPropertyUpdated extends ManufacturingCardFormEvent {
  const ManufacturingCardFormPropertyUpdated(this.index, this.property);
  final int index;
  final ManufacturingCardPropertyDraft property;
  @override
  List<Object?> get props => [index, property];
}

class ManufacturingCardFormPropertyRemoved extends ManufacturingCardFormEvent {
  const ManufacturingCardFormPropertyRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class ManufacturingCardFormPropertyAddedFromCatalog
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormPropertyAddedFromCatalog(this.definition);
  final ProductPropertyDefinition definition;
  @override
  List<Object?> get props => [definition];
}

class ManufacturingCardFormAlertNoteChanged extends ManufacturingCardFormEvent {
  const ManufacturingCardFormAlertNoteChanged(this.note);
  final String note;
}

class ManufacturingCardFormNotesChanged extends ManufacturingCardFormEvent {
  const ManufacturingCardFormNotesChanged(this.notes);
  final String notes;
}

class ManufacturingCardFormClientSignedToggled
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormClientSignedToggled();
}

class ManufacturingCardFormProductImagePicked
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormProductImagePicked(this.pick);
  final LocalMediaPick pick;
  @override
  List<Object?> get props => [pick];
}

class ManufacturingCardFormColorImagePicked extends ManufacturingCardFormEvent {
  const ManufacturingCardFormColorImagePicked(this.pick);
  final LocalMediaPick pick;
  @override
  List<Object?> get props => [pick];
}

class ManufacturingCardFormProductImageCleared
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormProductImageCleared();
}

class ManufacturingCardFormColorImageCleared
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormColorImageCleared();
}

class ManufacturingCardFormPropertyImagePicked
    extends ManufacturingCardFormEvent {
  const ManufacturingCardFormPropertyImagePicked(this.index, this.pick);
  final int index;
  final LocalMediaPick pick;
  @override
  List<Object?> get props => [index, pick];
}

class ManufacturingCardFormSubmitted extends ManufacturingCardFormEvent {
  const ManufacturingCardFormSubmitted();
}

// ── State ────────────────────────────────────────────────────────────────────

enum ManufacturingCardFormStatus {
  initial,
  loading,
  ready,
  saving,
  success,
  failure,
}

class ManufacturingCardFormState extends Equatable {
  const ManufacturingCardFormState({
    this.status = ManufacturingCardFormStatus.initial,
    this.orderId,
    this.agreementId,
    this.detail,
    this.targetLine,
    this.targetCardIndex,
    this.existingCard,
    this.linkedProduct,
    this.propertyDefinitions = const [],
    this.modelNameAr = '',
    this.modelNameEn,
    this.widthCm = 0,
    this.heightCm = 0,
    this.pickedProductColor,
    this.colorNameAr = '',
    this.colorNameEn,
    this.colorCode,
    this.colorImageUrl,
    this.productImageUrl,
    this.properties = const [],
    this.alertNote = defaultManufacturingCardAlert,
    this.notes,
    this.clientSigned = false,
    this.savedCard,
    this.message,
    String? targetLineId,
  }) : _targetLineId = targetLineId;

  final ManufacturingCardFormStatus status;
  final String? orderId;
  final String? agreementId;
  final CommercialOrderDetail? detail;
  final AgreementLine? targetLine;
  final int? targetCardIndex;
  final ManufacturingCard? existingCard;
  final Product? linkedProduct;
  final List<ProductPropertyDefinition> propertyDefinitions;
  final String modelNameAr;
  final String? modelNameEn;
  final double widthCm;
  final double heightCm;
  final ProductColor? pickedProductColor;
  final String colorNameAr;
  final String? colorNameEn;
  final String? colorCode;
  final String? colorImageUrl;
  final String? productImageUrl;
  final List<ManufacturingCardPropertyDraft> properties;
  final String alertNote;
  final String? notes;
  final bool clientSigned;
  final ManufacturingCard? savedCard;
  final String? message;
  final String? _targetLineId;

  bool get isEditing => existingCard != null;

  bool get isReadOnly => detail?.order.phase.isFinished ?? false;

  ManufacturingCardFormState copyWith({
    ManufacturingCardFormStatus? status,
    String? orderId,
    String? agreementId,
    CommercialOrderDetail? detail,
    AgreementLine? targetLine,
    int? targetCardIndex,
    ManufacturingCard? existingCard,
    Product? linkedProduct,
    List<ProductPropertyDefinition>? propertyDefinitions,
    String? modelNameAr,
    String? modelNameEn,
    double? widthCm,
    double? heightCm,
    ProductColor? pickedProductColor,
    bool clearPickedColor = false,
    String? colorNameAr,
    String? colorNameEn,
    bool clearColorNameEn = false,
    String? colorCode,
    bool clearColorCode = false,
    String? colorImageUrl,
    bool clearColorImageUrl = false,
    String? productImageUrl,
    List<ManufacturingCardPropertyDraft>? properties,
    String? alertNote,
    String? notes,
    bool? clientSigned,
    ManufacturingCard? savedCard,
    String? message,
    String? targetLineId,
  }) {
    return ManufacturingCardFormState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      agreementId: agreementId ?? this.agreementId,
      detail: detail ?? this.detail,
      targetLine: targetLine ?? this.targetLine,
      targetCardIndex: targetCardIndex ?? this.targetCardIndex,
      existingCard: existingCard ?? this.existingCard,
      linkedProduct: linkedProduct ?? this.linkedProduct,
      propertyDefinitions: propertyDefinitions ?? this.propertyDefinitions,
      modelNameAr: modelNameAr ?? this.modelNameAr,
      modelNameEn: modelNameEn ?? this.modelNameEn,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      pickedProductColor: clearPickedColor
          ? null
          : (pickedProductColor ?? this.pickedProductColor),
      colorNameAr: colorNameAr ?? this.colorNameAr,
      colorNameEn: clearColorNameEn ? null : (colorNameEn ?? this.colorNameEn),
      colorCode: clearColorCode ? null : (colorCode ?? this.colorCode),
      colorImageUrl: clearColorImageUrl
          ? null
          : (colorImageUrl ?? this.colorImageUrl),
      productImageUrl: productImageUrl ?? this.productImageUrl,
      properties: properties ?? this.properties,
      alertNote: alertNote ?? this.alertNote,
      notes: notes ?? this.notes,
      clientSigned: clientSigned ?? this.clientSigned,
      savedCard: savedCard ?? this.savedCard,
      message: message,
      targetLineId: targetLineId ?? _targetLineId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orderId,
    agreementId,
    detail,
    targetLine,
    targetCardIndex,
    existingCard,
    linkedProduct,
    propertyDefinitions,
    modelNameAr,
    modelNameEn,
    widthCm,
    heightCm,
    pickedProductColor,
    colorNameAr,
    colorNameEn,
    colorCode,
    colorImageUrl,
    productImageUrl,
    properties,
    alertNote,
    notes,
    clientSigned,
    savedCard,
    message,
    _targetLineId,
  ];
}
