import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';

class WorkOrdersListBloc
    extends Bloc<WorkOrdersListEvent, WorkOrdersListState> {
  WorkOrdersListBloc({
    required FetchCommercialOrdersPageUseCase fetchOrdersPage,
  }) : _fetchOrdersPage = fetchOrdersPage,
       super(const WorkOrdersListState()) {
    on<WorkOrdersListStarted>(_onStarted);
    on<WorkOrdersListRefreshRequested>(_onRefresh);
    on<WorkOrdersListHydrated>(_onHydrated);
  }

  final FetchCommercialOrdersPageUseCase _fetchOrdersPage;
  int _refreshGen = 0;

  Future<void> _onStarted(
    WorkOrdersListStarted event,
    Emitter<WorkOrdersListState> emit,
  ) async {
    await _refresh(emit);
  }

  Future<void> _onRefresh(
    WorkOrdersListRefreshRequested event,
    Emitter<WorkOrdersListState> emit,
  ) async {
    await _refresh(emit);
  }

  void _onHydrated(
    WorkOrdersListHydrated event,
    Emitter<WorkOrdersListState> emit,
  ) {
    final existing = [...state.items];
    final index = existing.indexWhere(
      (e) => e.order.id == event.summary.order.id,
    );
    if (index >= 0) {
      existing[index] = event.summary;
    } else {
      existing.insert(0, event.summary);
    }
    emit(state.copyWith(items: existing, status: WorkOrdersListStatus.success));
  }

  Future<void> _refresh(Emitter<WorkOrdersListState> emit) async {
    final gen = ++_refreshGen;
    if (state.items.isEmpty) {
      emit(state.copyWith(status: WorkOrdersListStatus.loading));
    }
    final result = await _fetchOrdersPage(page: 0);
    if (gen != _refreshGen) return;
    result.fold(
      (failure) {
        dbgWorkOrdersError('list failed', error: failure.message);
        emit(
          state.copyWith(
            status: WorkOrdersListStatus.failure,
            message: failure.message,
            refreshTick: state.refreshTick + 1,
          ),
        );
      },
      (page) {
        dbgWorkOrders(
          'list ok count=${page.items.length} total=${page.totalCount}',
        );
        emit(
          state.copyWith(
            status: WorkOrdersListStatus.success,
            items: page.items,
            totalCount: page.totalCount,
            message: null,
            refreshTick: state.refreshTick + 1,
          ),
        );
      },
    );
  }
}

sealed class WorkOrdersListEvent extends Equatable {
  const WorkOrdersListEvent();
  @override
  List<Object?> get props => [];
}

class WorkOrdersListStarted extends WorkOrdersListEvent {
  const WorkOrdersListStarted();
}

class WorkOrdersListRefreshRequested extends WorkOrdersListEvent {
  const WorkOrdersListRefreshRequested();
}

class WorkOrdersListHydrated extends WorkOrdersListEvent {
  const WorkOrdersListHydrated(this.summary);
  final CommercialOrderSummary summary;
  @override
  List<Object?> get props => [summary];
}

enum WorkOrdersListStatus { initial, loading, success, failure }

class WorkOrdersListState extends Equatable {
  const WorkOrdersListState({
    this.status = WorkOrdersListStatus.initial,
    this.items = const [],
    this.totalCount = 0,
    this.message,
    this.refreshTick = 0,
  });

  final WorkOrdersListStatus status;
  final List<CommercialOrderSummary> items;
  final int totalCount;
  final String? message;
  final int refreshTick;

  bool get showBlockingSpinner =>
      status == WorkOrdersListStatus.loading && items.isEmpty;

  WorkOrdersListState copyWith({
    WorkOrdersListStatus? status,
    List<CommercialOrderSummary>? items,
    int? totalCount,
    String? message,
    int? refreshTick,
  }) {
    return WorkOrdersListState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      message: message,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => [status, items, totalCount, message, refreshTick];
}
