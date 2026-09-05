import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/product_property.dart';
import '../../../../domain/usecases/product_property_usecases.dart';

part 'property_definitions_list_event.dart';
part 'property_definitions_list_state.dart';

class PropertyDefinitionsListBloc
    extends Bloc<PropertyDefinitionsListEvent, PropertyDefinitionsListState> {
  PropertyDefinitionsListBloc({
    required FetchProductPropertyDefinitionsUseCase fetchDefinitions,
  }) : _fetchDefinitions = fetchDefinitions,
       super(const PropertyDefinitionsListState()) {
    on<PropertyDefinitionsListStarted>(_onStarted);
    on<PropertyDefinitionsListRefreshRequested>(_onRefresh);
    on<PropertyDefinitionsListSearchChanged>(_onSearchChanged);
  }

  final FetchProductPropertyDefinitionsUseCase _fetchDefinitions;
  int _refreshGen = 0;

  Future<void> _onStarted(
    PropertyDefinitionsListStarted event,
    Emitter<PropertyDefinitionsListState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefresh(
    PropertyDefinitionsListRefreshRequested event,
    Emitter<PropertyDefinitionsListState> emit,
  ) async {
    await _load(emit);
  }

  void _onSearchChanged(
    PropertyDefinitionsListSearchChanged event,
    Emitter<PropertyDefinitionsListState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _load(Emitter<PropertyDefinitionsListState> emit) async {
    final gen = ++_refreshGen;
    if (state.definitions.isEmpty) {
      emit(state.copyWith(status: PropertyDefinitionsListStatus.loading));
    }

    final result = await _fetchDefinitions();
    if (gen != _refreshGen) return;

    result.fold(
      (failure) {
        dbgProductsError(
          'property definitions fetch failed',
          error: failure.message,
        );
        emit(
          state.copyWith(
            status: PropertyDefinitionsListStatus.failure,
            message: failure.message,
          ),
        );
      },
      (definitions) {
        dbgProducts(
          'property definitions fetch ok count=${definitions.length}',
        );
        emit(
          state.copyWith(
            status: PropertyDefinitionsListStatus.success,
            definitions: definitions,
            clearMessage: true,
          ),
        );
      },
    );
  }
}
