part of 'products_list_bloc.dart';

enum ProductsListStatus { initial, loading, success, failure }

class ProductsListState extends Equatable {
  const ProductsListState({
    this.status = ProductsListStatus.initial,
    this.products = const [],
    this.page = 0,
    this.totalCount = 0,
    this.isLoadingMore = false,
    this.skeletonReload = false,
    this.searchQuery = '',
    this.message,
    this.refreshTick = 0,
  });

  final ProductsListStatus status;
  final List<Product> products;
  final int page;
  final int totalCount;
  final bool isLoadingMore;
  final bool skeletonReload;
  final String searchQuery;
  final String? message;
  final int refreshTick;

  bool get showBlockingSpinner => SkeletonRefresh.shouldShow(
    isLoading: status == ProductsListStatus.loading,
    isEmpty: products.isEmpty,
    skeletonReload: skeletonReload,
  );

  bool get hasMore => products.length < totalCount;

  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              (product.description?.toLowerCase().contains(query) ?? false),
        )
        .toList(growable: false);
  }

  ProductsListState copyWith({
    ProductsListStatus? status,
    List<Product>? products,
    int? page,
    int? totalCount,
    bool? isLoadingMore,
    bool? skeletonReload,
    String? message,
    int? refreshTick,
    String? searchQuery,
    bool clearMessage = false,
  }) {
    return ProductsListState(
      status: status ?? this.status,
      products: products ?? this.products,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      skeletonReload: skeletonReload ?? this.skeletonReload,
      searchQuery: searchQuery ?? this.searchQuery,
      message: clearMessage ? null : (message ?? this.message),
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    page,
    totalCount,
    isLoadingMore,
    skeletonReload,
    searchQuery,
    message,
    refreshTick,
  ];
}
