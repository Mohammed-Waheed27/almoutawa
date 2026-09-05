part of 'customers_list_bloc.dart';

sealed class CustomersListEvent extends Equatable {
  const CustomersListEvent();

  @override
  List<Object?> get props => [];
}

final class CustomersListStarted extends CustomersListEvent {
  const CustomersListStarted();
}

final class CustomersListRefreshRequested extends CustomersListEvent {
  const CustomersListRefreshRequested({this.showSkeleton = false});

  final bool showSkeleton;

  @override
  List<Object?> get props => [showSkeleton];
}

final class CustomersListLoadMoreRequested extends CustomersListEvent {
  const CustomersListLoadMoreRequested();
}
