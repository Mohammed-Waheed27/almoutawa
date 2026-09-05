import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/product_usecases.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({required FetchProductDetailUseCase fetchDetail})
    : _fetchDetail = fetchDetail,
      super(const ProductDetailState()) {
    on<ProductDetailStarted>(_onStarted);
    on<ProductDetailRefreshRequested>(_onRefresh);
    on<ProductDetailSavedProductReceived>(_onSavedProduct);
  }

  final FetchProductDetailUseCase _fetchDetail;
  int _refreshGen = 0;
  String? _productId;

  void showSavedProduct(Product product) {
    add(ProductDetailSavedProductReceived(product));
  }

  Future<void> _onStarted(
    ProductDetailStarted event,
    Emitter<ProductDetailState> emit,
  ) async {
    _productId = event.productId;

    if (event.initialProduct != null) {
      dbgProducts('detail hydrated from navigation id=${event.productId}');
      emit(
        state.copyWith(
          status: ProductDetailStatus.success,
          product: event.initialProduct,
        ),
      );
    }

    await _refresh(emit, event.productId);
  }

  Future<void> _onRefresh(
    ProductDetailRefreshRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    final id = state.product?.id ?? _productId;
    if (id == null) {
      emit(state.copyWith(refreshTick: state.refreshTick + 1));
      return;
    }
    await _refresh(emit, id);
  }

  void _onSavedProduct(
    ProductDetailSavedProductReceived event,
    Emitter<ProductDetailState> emit,
  ) {
    _productId = event.product.id;
    dbgProducts('detail showSavedProduct id=${event.product.id}');
    emit(
      state.copyWith(
        status: ProductDetailStatus.success,
        product: event.product,
        clearMessage: true,
      ),
    );
    add(const ProductDetailRefreshRequested());
  }

  Future<void> _refresh(
    Emitter<ProductDetailState> emit,
    String productId,
  ) async {
    final gen = ++_refreshGen;
    if (state.product == null) {
      emit(state.copyWith(status: ProductDetailStatus.loading));
    }

    try {
      final result = await _fetchDetail(productId);
      if (gen != _refreshGen) return;

      result.fold(
        (failure) {
          dbgProductsError('detail fetch failed', error: failure.message);
          emit(
            state.copyWith(
              status: ProductDetailStatus.failure,
              message: failure.message,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
        (product) {
          dbgProducts('detail fetch ok id=$productId');
          emit(
            state.copyWith(
              status: ProductDetailStatus.success,
              product: product,
              clearMessage: true,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
      );
    } catch (error) {
      if (gen != _refreshGen) return;
      dbgProductsError('detail fetch unexpected error', error: error);
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          message: error.toString(),
          refreshTick: state.refreshTick + 1,
        ),
      );
    }
  }
}
