import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/local_media_pick.dart';
import '../../../../domain/entities/product_property.dart';
import '../../../../domain/usecases/product_property_usecases.dart';
import '../../../../domain/usecases/product_usecases.dart';

part 'property_definition_form_event.dart';
part 'property_definition_form_state.dart';

class PropertyDefinitionFormBloc
    extends Bloc<PropertyDefinitionFormEvent, PropertyDefinitionFormState> {
  PropertyDefinitionFormBloc({
    required SaveProductPropertyDefinitionUseCase saveDefinition,
    required UploadPublicMediaUseCase uploadPublicMedia,
    ProductPropertyDefinition? existing,
  }) : _saveDefinition = saveDefinition,
       _uploadPublicMedia = uploadPublicMedia,
       super(PropertyDefinitionFormState.fromExisting(existing)) {
    on<PropertyDefinitionFormSubmitted>(_onSubmitted);
    on<PropertyDefinitionFormValueAdded>(_onValueAdded);
    on<PropertyDefinitionFormValueUpdated>(_onValueUpdated);
    on<PropertyDefinitionFormValueRemoved>(_onValueRemoved);
    on<PropertyDefinitionFormIconChanged>(_onIconChanged);
    on<PropertyDefinitionFormValueImagePicked>(_onValueImagePicked);
  }

  final SaveProductPropertyDefinitionUseCase _saveDefinition;
  final UploadPublicMediaUseCase _uploadPublicMedia;

  Future<void> _onSubmitted(
    PropertyDefinitionFormSubmitted event,
    Emitter<PropertyDefinitionFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PropertyDefinitionFormStatus.submitting,
        clearMessage: true,
      ),
    );

    final draft = ProductPropertyDefinitionDraft(
      definitionId: state.definitionId,
      nameAr: event.nameAr,
      nameEn: event.nameEn,
      iconKey: state.iconKey,
      values: state.values,
    );

    final result = await _saveDefinition(
      draft: draft,
      definitionId: state.definitionId,
    );

    result.fold(
      (failure) {
        dbgProductsError(
          'property definition save failed',
          error: failure.message,
        );
        emit(
          state.copyWith(
            status: PropertyDefinitionFormStatus.failure,
            message: failure.message,
          ),
        );
      },
      (saved) {
        dbgProducts('property definition save ok id=${saved.id}');
        emit(
          state.copyWith(
            status: PropertyDefinitionFormStatus.success,
            savedDefinition: saved,
          ),
        );
      },
    );
  }

  void _onValueAdded(
    PropertyDefinitionFormValueAdded event,
    Emitter<PropertyDefinitionFormState> emit,
  ) {
    final valueAr = event.valueAr.trim();
    final valueEn = event.valueEn.trim();
    if (valueAr.isEmpty || valueEn.isEmpty) return;

    final nextCounter = state.valueCounter + 1;
    emit(
      state.copyWith(
        values: [
          ...state.values,
          ProductPropertyValueDraft(
            valueAr: valueAr,
            valueEn: valueEn,
            imageUrl: event.imageUrl ?? state.pendingValueImageUrl,
          ),
        ],
        valueCounter: nextCounter,
        clearPendingValueImage: true,
        clearMessage: true,
      ),
    );
  }

  void _onValueUpdated(
    PropertyDefinitionFormValueUpdated event,
    Emitter<PropertyDefinitionFormState> emit,
  ) {
    final next = state.values
        .map(
          (value) => value == event.target
              ? ProductPropertyValueDraft(
                  valueId: value.valueId,
                  valueAr: event.valueAr.trim(),
                  valueEn: event.valueEn.trim(),
                  imageUrl: event.imageUrl ?? value.imageUrl,
                )
              : value,
        )
        .toList(growable: false);
    emit(state.copyWith(values: next, clearMessage: true));
  }

  void _onValueRemoved(
    PropertyDefinitionFormValueRemoved event,
    Emitter<PropertyDefinitionFormState> emit,
  ) {
    emit(
      state.copyWith(
        values: state.values
            .where((value) => value != event.target)
            .toList(growable: false),
        clearMessage: true,
      ),
    );
  }

  void _onIconChanged(
    PropertyDefinitionFormIconChanged event,
    Emitter<PropertyDefinitionFormState> emit,
  ) {
    emit(state.copyWith(iconKey: event.iconKey, clearMessage: true));
  }

  Future<void> _onValueImagePicked(
    PropertyDefinitionFormValueImagePicked event,
    Emitter<PropertyDefinitionFormState> emit,
  ) async {
    final result = await _uploadPublicMedia(
      folder: 'property-values/${state.definitionId ?? 'new'}',
      pick: event.pick,
    );
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (url) {
        if (event.target == null) {
          emit(state.copyWith(pendingValueImageUrl: url, clearMessage: true));
          return;
        }
        final next = state.values
            .map(
              (value) => value == event.target
                  ? ProductPropertyValueDraft(
                      valueId: value.valueId,
                      valueAr: value.valueAr,
                      valueEn: value.valueEn,
                      imageUrl: url,
                    )
                  : value,
            )
            .toList(growable: false);
        emit(state.copyWith(values: next, clearMessage: true));
      },
    );
  }
}
