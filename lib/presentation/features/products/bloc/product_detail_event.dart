part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

final class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted(this.productId, {this.initialProduct});

  final String productId;
  final Product? initialProduct;

  @override
  List<Object?> get props => [productId, initialProduct];
}

final class ProductDetailRefreshRequested extends ProductDetailEvent {
  const ProductDetailRefreshRequested();
}

final class ProductDetailSavedProductReceived extends ProductDetailEvent {
  const ProductDetailSavedProductReceived(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}
