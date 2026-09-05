import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';
import '../../../../domain/usecases/customer_usecases.dart';

part 'customer_detail_event.dart';
part 'customer_detail_state.dart';

class CustomerDetailBloc
    extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  CustomerDetailBloc({
    required FetchCustomerDetailUseCase fetchDetail,
    required FetchCommercialOrdersForCustomerUseCase fetchOrders,
  }) : _fetchDetail = fetchDetail,
       _fetchOrders = fetchOrders,
       super(const CustomerDetailState()) {
    on<CustomerDetailStarted>(_onStarted);
    on<CustomerDetailRefreshRequested>(_onRefresh);
  }

  final FetchCustomerDetailUseCase _fetchDetail;
  final FetchCommercialOrdersForCustomerUseCase _fetchOrders;
  int _refreshGen = 0;
  String? _customerId;

  Future<void> _onStarted(
    CustomerDetailStarted event,
    Emitter<CustomerDetailState> emit,
  ) async {
    _customerId = event.customerId;
    await _refresh(emit, event.customerId);
  }

  Future<void> _onRefresh(
    CustomerDetailRefreshRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final id = state.customer?.id ?? _customerId;
    if (id == null) {
      emit(state.copyWith(refreshTick: state.refreshTick + 1));
      return;
    }
    await _refresh(emit, id);
  }

  Future<void> _refresh(
    Emitter<CustomerDetailState> emit,
    String customerId,
  ) async {
    final gen = ++_refreshGen;
    if (state.customer == null) {
      emit(state.copyWith(status: CustomerDetailStatus.loading));
    }

    try {
      dbgCustomers('detail fetch start id=$customerId');
      final detailFuture = _fetchDetail(customerId);
      final ordersFuture = _fetchOrders(customerId);
      final detailResult = await detailFuture;
      final ordersResult = await ordersFuture;
      if (gen != _refreshGen) return;

      var orders = const <CommercialOrderSummary>[];
      String? ordersMessage;
      ordersResult.fold(
        (failure) {
          dbgCustomersError(
            'detail orders fetch failed',
            error: failure.message,
          );
          ordersMessage = failure.message;
        },
        (items) {
          orders = items;
          dbgCustomers(
            'detail orders fetch ok id=$customerId count=${orders.length}',
          );
        },
      );

      detailResult.fold(
        (failure) {
          dbgCustomersError('detail fetch failed', error: failure.message);
          emit(
            state.copyWith(
              status: CustomerDetailStatus.failure,
              message: failure.message,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
        (bundle) {
          dbgCustomers('detail fetch ok id=$customerId');
          emit(
            state.copyWith(
              status: CustomerDetailStatus.success,
              customer: bundle.customer,
              ledgerEntries: bundle.ledgerEntries,
              orders: orders,
              message: ordersMessage,
              clearMessage: ordersMessage == null,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
      );
    } catch (error) {
      if (gen != _refreshGen) return;
      dbgCustomersError('detail fetch unexpected error', error: error);
      emit(
        state.copyWith(
          status: CustomerDetailStatus.failure,
          message: error.toString(),
          refreshTick: state.refreshTick + 1,
        ),
      );
    }
  }
}
