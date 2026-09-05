import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/factory_profile.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';

class WorkOrderCreateBloc
    extends Bloc<WorkOrderCreateEvent, WorkOrderCreateState> {
  WorkOrderCreateBloc({
    required FetchFactoriesUseCase fetchFactories,
    required CreateCommercialOrderUseCase createOrder,
  }) : _fetchFactories = fetchFactories,
       _createOrder = createOrder,
       super(const WorkOrderCreateState()) {
    on<WorkOrderCreateStarted>(_onStarted);
    on<WorkOrderCreateCustomerSelected>(_onCustomerSelected);
    on<WorkOrderCreateFactorySelected>(_onFactorySelected);
    on<WorkOrderCreateNotesChanged>(_onNotesChanged);
    on<WorkOrderCreateSubmitted>(_onSubmitted);
  }

  final FetchFactoriesUseCase _fetchFactories;
  final CreateCommercialOrderUseCase _createOrder;

  Future<void> _onStarted(
    WorkOrderCreateStarted event,
    Emitter<WorkOrderCreateState> emit,
  ) async {
    emit(state.copyWith(status: WorkOrderCreateStatus.loading));
    final factoriesResult = await _fetchFactories();

    List<FactoryProfile> factories = const [];
    String? error;

    factoriesResult.fold((f) => error = f.message, (v) => factories = v);

    if (error != null) {
      emit(
        state.copyWith(status: WorkOrderCreateStatus.failure, message: error),
      );
      return;
    }

    final defaultFactory = event.requireFactory
        ? factories.cast<FactoryProfile?>().firstWhere(
            (f) => f!.isDefault,
            orElse: () => factories.isEmpty ? null : factories.first,
          )
        : null;

    dbgWorkOrders(
      'create ready factories=${factories.length} requireFactory=${event.requireFactory}',
    );

    emit(
      state.copyWith(
        status: WorkOrderCreateStatus.ready,
        factories: factories,
        selectedFactoryId: event.requireFactory
            ? (event.preselectedFactoryId ?? defaultFactory?.id)
            : null,
        requireFactory: event.requireFactory,
        message: null,
      ),
    );
  }

  void _onCustomerSelected(
    WorkOrderCreateCustomerSelected event,
    Emitter<WorkOrderCreateState> emit,
  ) {
    dbgWorkOrders('create customer selected id=${event.customer.id}');
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onFactorySelected(
    WorkOrderCreateFactorySelected event,
    Emitter<WorkOrderCreateState> emit,
  ) {
    emit(state.copyWith(selectedFactoryId: event.factoryId));
  }

  void _onNotesChanged(
    WorkOrderCreateNotesChanged event,
    Emitter<WorkOrderCreateState> emit,
  ) {
    emit(state.copyWith(notes: event.notes));
  }

  Future<void> _onSubmitted(
    WorkOrderCreateSubmitted event,
    Emitter<WorkOrderCreateState> emit,
  ) async {
    final customerId = state.selectedCustomer?.id;
    if (customerId == null) {
      emit(state.copyWith(message: 'اختر العميل أولاً'));
      return;
    }
    if (state.requireFactory && state.selectedFactoryId == null) {
      emit(state.copyWith(message: 'اختر المصنع'));
      return;
    }

    emit(
      state.copyWith(status: WorkOrderCreateStatus.submitting, message: null),
    );
    dbgWorkOrders('create submit customer=$customerId');

    final result = await _createOrder(
      CreateCommercialOrderInput(
        customerId: customerId,
        factoryId: state.requireFactory ? state.selectedFactoryId : null,
        notes: state.notes,
      ),
    );

    result.fold(
      (failure) {
        dbgWorkOrdersError('create failed', error: failure.message);
        emit(
          state.copyWith(
            status: WorkOrderCreateStatus.ready,
            message: failure.message,
          ),
        );
      },
      (detail) {
        dbgWorkOrders('create ok id=${detail.order.id}');
        emit(
          state.copyWith(
            status: WorkOrderCreateStatus.success,
            createdDetail: detail,
          ),
        );
      },
    );
  }
}

sealed class WorkOrderCreateEvent extends Equatable {
  const WorkOrderCreateEvent();
  @override
  List<Object?> get props => [];
}

class WorkOrderCreateStarted extends WorkOrderCreateEvent {
  const WorkOrderCreateStarted({
    this.preselectedCustomerId,
    this.preselectedFactoryId,
    this.requireFactory = true,
  });
  final String? preselectedCustomerId;
  final String? preselectedFactoryId;

  /// When false (delivery), factory is assigned later by operations manager.
  final bool requireFactory;
}

class WorkOrderCreateCustomerSelected extends WorkOrderCreateEvent {
  const WorkOrderCreateCustomerSelected(this.customer);
  final Customer customer;
  @override
  List<Object?> get props => [customer];
}

class WorkOrderCreateFactorySelected extends WorkOrderCreateEvent {
  const WorkOrderCreateFactorySelected(this.factoryId);
  final String factoryId;
  @override
  List<Object?> get props => [factoryId];
}

class WorkOrderCreateNotesChanged extends WorkOrderCreateEvent {
  const WorkOrderCreateNotesChanged(this.notes);
  final String notes;
  @override
  List<Object?> get props => [notes];
}

class WorkOrderCreateSubmitted extends WorkOrderCreateEvent {
  const WorkOrderCreateSubmitted();
}

enum WorkOrderCreateStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class WorkOrderCreateState extends Equatable {
  const WorkOrderCreateState({
    this.status = WorkOrderCreateStatus.initial,
    this.factories = const [],
    this.selectedCustomer,
    this.selectedFactoryId,
    this.requireFactory = true,
    this.notes,
    this.message,
    this.createdDetail,
  });

  final WorkOrderCreateStatus status;
  final List<FactoryProfile> factories;
  final Customer? selectedCustomer;
  final String? selectedFactoryId;
  final bool requireFactory;
  final String? notes;
  final String? message;
  final CommercialOrderDetail? createdDetail;

  bool get showBlockingSkeleton =>
      status == WorkOrderCreateStatus.loading ||
      status == WorkOrderCreateStatus.initial;

  String? get selectedCustomerId => selectedCustomer?.id;

  WorkOrderCreateState copyWith({
    WorkOrderCreateStatus? status,
    List<FactoryProfile>? factories,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    String? selectedFactoryId,
    bool? requireFactory,
    String? notes,
    String? message,
    CommercialOrderDetail? createdDetail,
  }) {
    return WorkOrderCreateState(
      status: status ?? this.status,
      factories: factories ?? this.factories,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      selectedFactoryId: selectedFactoryId ?? this.selectedFactoryId,
      requireFactory: requireFactory ?? this.requireFactory,
      notes: notes ?? this.notes,
      message: message,
      createdDetail: createdDetail ?? this.createdDetail,
    );
  }

  @override
  List<Object?> get props => [
    status,
    factories,
    selectedCustomer,
    selectedFactoryId,
    requireFactory,
    notes,
    message,
    createdDetail,
  ];
}
