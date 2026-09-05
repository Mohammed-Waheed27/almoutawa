part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.message,
    this.refreshTick = 0,
  });

  final ProductDetailStatus status;
  final Product? product;
  final String? message;
  final int refreshTick;

  bool get showBlockingSpinner =>
      status == ProductDetailStatus.loading && product == null;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    String? message,
    bool clearMessage = false,
    int? refreshTick,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      message: clearMessage ? null : message ?? this.message,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => [status, product, message, refreshTick];
}
