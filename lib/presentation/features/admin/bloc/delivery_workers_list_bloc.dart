import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../domain/entities/staff_profile.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/usecases/staff_usecases.dart';

part 'delivery_workers_list_event.dart';
part 'delivery_workers_list_state.dart';

class DeliveryWorkersListBloc
    extends Bloc<DeliveryWorkersListEvent, DeliveryWorkersListState> {
  DeliveryWorkersListBloc({
    required FetchDeliveryWorkersPageUseCase fetchWorkers,
    required SuspendDeliveryWorkerUseCase suspendWorker,
    required ReactivateDeliveryWorkerUseCase reactivateWorker,
    required DeleteDeliveryWorkerUseCase deleteWorker,
  }) : _fetchWorkers = fetchWorkers,
       _suspendWorker = suspendWorker,
       _reactivateWorker = reactivateWorker,
       _deleteWorker = deleteWorker,
       super(const DeliveryWorkersListState()) {
    on<DeliveryWorkersListStarted>(_onStarted);
    on<DeliveryWorkersListRoleChanged>(_onRoleChanged);
    on<DeliveryWorkersListRefreshRequested>(_onRefresh);
    on<DeliveryWorkersListLoadMoreRequested>(_onLoadMore);
    on<DeliveryWorkerSuspendRequested>(_onSuspend);
    on<DeliveryWorkerReactivateRequested>(_onReactivate);
    on<DeliveryWorkerDeleteRequested>(_onDelete);
  }

  final FetchDeliveryWorkersPageUseCase _fetchWorkers;
  final SuspendDeliveryWorkerUseCase _suspendWorker;
  final ReactivateDeliveryWorkerUseCase _reactivateWorker;
  final DeleteDeliveryWorkerUseCase _deleteWorker;
  int _refreshGen = 0;

  Future<void> _onStarted(
    DeliveryWorkersListStarted event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    emit(state.copyWith(role: event.role, workers: const [], page: -1));
    await _refresh(emit, reset: true);
  }

  Future<void> _onRoleChanged(
    DeliveryWorkersListRoleChanged event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    // Kept for compatibility — tab UI no longer clears lists on switch.
    if (event.role == state.role) return;
    emit(state.copyWith(role: event.role));
  }

  Future<void> _onRefresh(
    DeliveryWorkersListRefreshRequested event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    await _refresh(emit, reset: true, showSkeleton: event.showSkeleton);
  }

  Future<void> _onLoadMore(
    DeliveryWorkersListLoadMoreRequested event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    await _refresh(emit, reset: false);
  }

  Future<void> _refresh(
    Emitter<DeliveryWorkersListState> emit, {
    required bool reset,
    bool showSkeleton = false,
  }) async {
    final gen = ++_refreshGen;
    final nextPage = reset ? 0 : state.page + 1;

    if (reset && (state.workers.isEmpty || showSkeleton)) {
      emit(
        state.copyWith(
          status: DeliveryWorkersListStatus.loading,
          skeletonReload: showSkeleton,
          clearMessage: true,
        ),
      );
    } else if (!reset) {
      emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    }

    final result = await _fetchWorkers(page: nextPage, role: state.role);
    if (gen != _refreshGen) return;

    result.fold(
      (failure) {
        dbgAdminError('workers list failed', error: failure.message);
        emit(
          state.copyWith(
            status: DeliveryWorkersListStatus.failure,
            isLoadingMore: false,
            skeletonReload: false,
            message: failure.message,
          ),
        );
      },
      (pageResult) {
        dbgAdmin(
          'workers list ok role=${state.role.dbValue} count=${pageResult.items.length} total=${pageResult.totalCount}',
        );
        final merged = reset
            ? pageResult.items
            : [...state.workers, ...pageResult.items];
        emit(
          state.copyWith(
            status: DeliveryWorkersListStatus.success,
            workers: merged,
            page: nextPage,
            totalCount: pageResult.totalCount,
            hasMore: pageResult.hasMore,
            isLoadingMore: false,
            skeletonReload: false,
            clearMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onSuspend(
    DeliveryWorkerSuspendRequested event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    final result = await _suspendWorker(event.profileId);
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (profile) => _replaceWorker(emit, profile, 'تم إيقاف الحساب'),
    );
  }

  Future<void> _onReactivate(
    DeliveryWorkerReactivateRequested event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    final result = await _reactivateWorker(event.profileId);
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (profile) => _replaceWorker(emit, profile, 'تم تفعيل الحساب'),
    );
  }

  Future<void> _onDelete(
    DeliveryWorkerDeleteRequested event,
    Emitter<DeliveryWorkersListState> emit,
  ) async {
    final result = await _deleteWorker(event.profileId);
    result.fold((failure) => emit(state.copyWith(message: failure.message)), (
      _,
    ) {
      final remaining = state.workers
          .where((worker) => worker.id != event.profileId)
          .toList(growable: false);
      emit(
        state.copyWith(
          workers: remaining,
          totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
          actionMessage: 'تم حذف الحساب',
          clearMessage: true,
        ),
      );
    });
  }

  void _replaceWorker(
    Emitter<DeliveryWorkersListState> emit,
    StaffProfile profile,
    String message,
  ) {
    final updated = state.workers
        .map((worker) => worker.id == profile.id ? profile : worker)
        .toList(growable: false);
    emit(
      state.copyWith(
        workers: updated,
        actionMessage: message,
        clearMessage: true,
      ),
    );
  }
}
