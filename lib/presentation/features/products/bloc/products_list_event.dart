part of 'products_list_bloc.dart';

abstract class ProductsListEvent extends Equatable {
  const ProductsListEvent();

  @override
  List<Object?> get props => [];
}

class ProductsListStarted extends ProductsListEvent {
  const ProductsListStarted();
}

class ProductsListRefreshRequested extends ProductsListEvent {
  const ProductsListRefreshRequested({this.showSkeleton = false});

  final bool showSkeleton;

  @override
  List<Object?> get props => [showSkeleton];
}

class ProductsListLoadMoreRequested extends ProductsListEvent {
  const ProductsListLoadMoreRequested();
}

class ProductsListSearchChanged extends ProductsListEvent {
  const ProductsListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ProductsListProductSaved extends ProductsListEvent {
  const ProductsListProductSaved(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}
