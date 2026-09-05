part of 'customer_detail_bloc.dart';

enum CustomerDetailStatus { initial, loading, success, failure }

class CustomerDetailState extends Equatable {
  const CustomerDetailState({
    this.status = CustomerDetailStatus.initial,
    this.customer,
    this.ledgerEntries = const [],
    this.orders = const [],
    this.message,
    this.refreshTick = 0,
  });

  final CustomerDetailStatus status;
  final Customer? customer;
  final List<CustomerAccountEntry> ledgerEntries;
  final List<CommercialOrderSummary> orders;
  final String? message;
  final int refreshTick;

  bool get showBlockingSpinner =>
      status == CustomerDetailStatus.loading && customer == null;

  CustomerDetailState copyWith({
    CustomerDetailStatus? status,
    Customer? customer,
    List<CustomerAccountEntry>? ledgerEntries,
    List<CommercialOrderSummary>? orders,
    String? message,
    bool clearMessage = false,
    int? refreshTick,
  }) {
    return CustomerDetailState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      ledgerEntries: ledgerEntries ?? this.ledgerEntries,
      orders: orders ?? this.orders,
      message: clearMessage ? null : message ?? this.message,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customer,
    ledgerEntries,
    orders,
    message,
    refreshTick,
  ];
}
