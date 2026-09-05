import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../domain/entities/delivery_order.dart';
import '../../../../domain/entities/orders_list_scope.dart';
import '../../../../domain/usecases/delivery_usecases.dart';

part 'delivery_orders_event.dart';
part 'delivery_orders_state.dart';

class DeliveryOrdersBloc
    extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  DeliveryOrdersBloc({
    required FetchOrdersPageUseCase fetchOrdersPage,
    required MarkOrderDeliveredUseCase markOrderDelivered,
    required OrdersListScope scope,
  }) : _fetchOrdersPage = fetchOrdersPage,
       _markOrderDelivered = markOrderDelivered,
       _scope = scope,
       super(const DeliveryOrdersState()) {
    on<DeliveryOrdersStarted>(_onStarted);
    on<DeliveryOrdersRefreshRequested>(_onRefresh);
    on<DeliveryOrdersLoadMoreRequested>(_onLoadMore);
    on<DeliveryOrderSelected>(_onSelected);
    on<DeliveryOrderDeliverRequested>(_onDeliver);
  }

  final FetchOrdersPageUseCase _fetchOrdersPage;
  final MarkOrderDeliveredUseCase _markOrderDelivered;
  final OrdersListScope _scope;
  int _refreshGen = 0;

  Future<void> _onStarted(
    DeliveryOrdersStarted event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    await _refresh(emit, reset: true);
  }

  Future<void> _onRefresh(
    DeliveryOrdersRefreshRequested event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    await _refresh(
      emit,
      reset: true,
      showSkeleton: event.showSkeleton,
    );
  }

  Future<void> _onLoadMore(
    DeliveryOrdersLoadMoreRequested event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    await _refresh(emit, reset: false);
  }

  void _onSelected(
    DeliveryOrderSelected event,
    Emitter<DeliveryOrdersState> emit,
  ) {
    emit(state.copyWith(selectedOrder: event.order, clearMessages: true));
  }

  Future<void> _refresh(
    Emitter<DeliveryOrdersState> emit, {
    required bool reset,
    bool showSkeleton = false,
  }) async {
    final gen = ++_refreshGen;
    final nextPage = reset ? 0 : state.page + 1;

    if (reset && (state.orders.isEmpty || showSkeleton)) {
      emit(
        state.copyWith(
          status: DeliveryOrdersStatus.loading,
          skeletonReload: showSkeleton,
          clearMessages: true,
        ),
      );
    } else if (!reset) {
      emit(state.copyWith(isLoadingMore: true, clearMessages: true));
    }

    final result = await _fetchOrdersPage(scope: _scope, page: nextPage);
    if (gen != _refreshGen) return;

    result.fold(
      (failure) {
        dbgDeliveryError('fetch failed', error: failure.message);
        emit(
          state.copyWith(
            status: DeliveryOrdersStatus.failure,
            isLoadingMore: false,
            skeletonReload: false,
            message: failure.message,
          ),
        );
      },
      (pageResult) {
        dbgDelivery(
          'fetch ok count=${pageResult.items.length} total=${pageResult.totalCount}',
        );
        final merged = reset
            ? pageResult.items
            : [...state.orders, ...pageResult.items];
        emit(
          state.copyWith(
            status: DeliveryOrdersStatus.success,
            orders: merged,
            page: nextPage,
            totalCount: pageResult.totalCount,
            hasMore: pageResult.hasMore,
            isLoadingMore: false,
            skeletonReload: false,
            clearMessages: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeliver(
    DeliveryOrderDeliverRequested event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeliveryOrdersStatus.delivering,
        clearMessages: true,
      ),
    );

    final result = await _markOrderDelivered(
      orderId: event.orderId,
      deliveryNotes: event.deliveryNotes,
    );

    result.fold(
      (failure) {
        dbgDeliveryError('deliver failed', error: failure.message);
        emit(
          state.copyWith(
            status: DeliveryOrdersStatus.failure,
            message: failure.message,
          ),
        );
      },
      (_) {
        final remaining = state.orders
            .where((order) => order.id != event.orderId)
            .toList(growable: false);
        emit(
          state.copyWith(
            status: DeliveryOrdersStatus.success,
            orders: remaining,
            totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
            clearSelected: true,
            actionMessage: 'تم تأكيد التسليم بنجاح',
          ),
        );
      },
    );
  }
}
