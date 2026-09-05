part of 'customer_detail_bloc.dart';

sealed class CustomerDetailEvent extends Equatable {
  const CustomerDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CustomerDetailStarted extends CustomerDetailEvent {
  const CustomerDetailStarted(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

final class CustomerDetailRefreshRequested extends CustomerDetailEvent {
  const CustomerDetailRefreshRequested();
}
