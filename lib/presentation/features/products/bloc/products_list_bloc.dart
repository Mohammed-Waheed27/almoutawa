import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/product_usecases.dart';

part 'products_list_event.dart';
part 'products_list_state.dart';

class ProductsListBloc extends Bloc<ProductsListEvent, ProductsListState> {
  ProductsListBloc({required FetchProductsPageUseCase fetchProductsPage})
    : _fetchProductsPage = fetchProductsPage,
      super(const ProductsListState()) {
    on<ProductsListStarted>(_onStarted);
    on<ProductsListRefreshRequested>(_onRefresh);
    on<ProductsListLoadMoreRequested>(_onLoadMore);
    on<ProductsListSearchChanged>(_onSearchChanged);
    on<ProductsListProductSaved>(_onProductSaved);
  }

  final FetchProductsPageUseCase _fetchProductsPage;
  int _refreshGen = 0;

  Future<void> _onStarted(
    ProductsListStarted event,
    Emitter<ProductsListState> emit,
  ) async {
    await _refresh(emit, reset: true);
  }

  Future<void> _onRefresh(
    ProductsListRefreshRequested event,
    Emitter<ProductsListState> emit,
  ) async {
    await _refresh(
      emit,
      reset: true,
      showSkeleton: event.showSkeleton,
    );
  }

  Future<void> _onLoadMore(
    ProductsListLoadMoreRequested event,
    Emitter<ProductsListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    await _refresh(emit, reset: false);
  }

  void _onSearchChanged(
    ProductsListSearchChanged event,
    Emitter<ProductsListState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onProductSaved(
    ProductsListProductSaved event,
    Emitter<ProductsListState> emit,
  ) {
    final saved = event.product;
    final index = state.products.indexWhere((item) => item.id == saved.id);
    final nextProducts = index == -1
        ? [saved, ...state.products]
        : state.products
              .map((item) => item.id == saved.id ? saved : item)
              .toList(growable: false);

    dbgProducts('list hydrated saved product id=${saved.id}');
    emit(
      state.copyWith(
        products: nextProducts,
        totalCount: index == -1 ? state.totalCount + 1 : state.totalCount,
        clearMessage: true,
      ),
    );
  }

  Future<void> _refresh(
    Emitter<ProductsListState> emit, {
    required bool reset,
    bool showSkeleton = false,
  }) async {
    final gen = ++_refreshGen;
    final nextPage = reset ? 0 : state.page + 1;

    if (reset && (state.products.isEmpty || showSkeleton)) {
      emit(
        state.copyWith(
          status: ProductsListStatus.loading,
          skeletonReload: showSkeleton,
        ),
      );
    } else if (!reset) {
      emit(state.copyWith(isLoadingMore: true));
    }

    try {
      final result = await _fetchProductsPage(page: nextPage);
      if (gen != _refreshGen) return;

      result.fold(
        (failure) {
          dbgProductsError('list fetch failed', error: failure.message);
          emit(
            state.copyWith(
              status: ProductsListStatus.failure,
              isLoadingMore: false,
              skeletonReload: false,
              message: failure.message,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
        (pageResult) {
          dbgProducts(
            'list fetch ok count=${pageResult.items.length} total=${pageResult.totalCount}',
          );
          final merged = reset
              ? pageResult.items
              : [...state.products, ...pageResult.items];
          emit(
            state.copyWith(
              status: ProductsListStatus.success,
              products: merged,
              page: nextPage,
              totalCount: pageResult.totalCount,
              isLoadingMore: false,
              skeletonReload: false,
              clearMessage: true,
              refreshTick: state.refreshTick + 1,
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      if (gen != _refreshGen) return;
      dbgProductsError(
        'list fetch unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: ProductsListStatus.failure,
          isLoadingMore: false,
          skeletonReload: false,
          message: 'تعذر تحميل المنتجات',
          refreshTick: state.refreshTick + 1,
        ),
      );
    }
  }
}
