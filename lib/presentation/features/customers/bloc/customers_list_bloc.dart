import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/usecases/customer_usecases.dart';

part 'customers_list_event.dart';
part 'customers_list_state.dart';

class CustomersListBloc extends Bloc<CustomersListEvent, CustomersListState> {
  CustomersListBloc({required FetchCustomersPageUseCase fetchCustomersPage})
    : _fetchCustomersPage = fetchCustomersPage,
      super(const CustomersListState()) {
    on<CustomersListStarted>(_onStarted);
    on<CustomersListRefreshRequested>(_onRefresh);
    on<CustomersListLoadMoreRequested>(_onLoadMore);
  }

  final FetchCustomersPageUseCase _fetchCustomersPage;
  int _refreshGen = 0;

  Future<void> _onStarted(
    CustomersListStarted event,
    Emitter<CustomersListState> emit,
  ) async {
    await _refresh(emit, reset: true);
  }

  Future<void> _onRefresh(
    CustomersListRefreshRequested event,
    Emitter<CustomersListState> emit,
  ) async {
    await _refresh(
      emit,
      reset: true,
      showSkeleton: event.showSkeleton,
    );
  }

  Future<void> _onLoadMore(
    CustomersListLoadMoreRequested event,
    Emitter<CustomersListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    await _refresh(emit, reset: false);
  }

  Future<void> _refresh(
    Emitter<CustomersListState> emit, {
    required bool reset,
    bool showSkeleton = false,
  }) async {
    final gen = ++_refreshGen;
    final nextPage = reset ? 0 : state.page + 1;

    if (reset && (state.customers.isEmpty || showSkeleton)) {
      emit(
        state.copyWith(
          status: CustomersListStatus.loading,
          skeletonReload: showSkeleton,
        ),
      );
    } else if (!reset) {
      emit(state.copyWith(isLoadingMore: true));
    }

    try {
      final result = await _fetchCustomersPage(page: nextPage);
      if (gen != _refreshGen) return;

      result.fold(
        (failure) {
          dbgCustomersError('list fetch failed', error: failure.message);
          emit(
            state.copyWith(
              status: CustomersListStatus.failure,
              isLoadingMore: false,
              skeletonReload: false,
              message: failure.message,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
        (pageResult) {
          dbgCustomers(
            'list fetch ok count=${pageResult.items.length} total=${pageResult.totalCount}',
          );
          final merged = reset
              ? pageResult.items
              : [...state.customers, ...pageResult.items];
          emit(
            state.copyWith(
              status: CustomersListStatus.success,
              customers: merged,
              page: nextPage,
              totalCount: pageResult.totalCount,
              hasMore: pageResult.hasMore,
              isLoadingMore: false,
              skeletonReload: false,
              clearMessage: true,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
      );
    } catch (error) {
      if (gen != _refreshGen) return;
      dbgCustomersError('list fetch unexpected error', error: error);
      emit(
        state.copyWith(
          status: CustomersListStatus.failure,
          isLoadingMore: false,
          skeletonReload: false,
          message: error.toString(),
          refreshTick: state.refreshTick + 1,
        ),
      );
    }
  }
}
