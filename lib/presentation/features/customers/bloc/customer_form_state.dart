part of 'customer_form_bloc.dart';

enum CustomerFormStatus { initial, submitting, success, failure }

class CustomerFormState extends Equatable {
  const CustomerFormState({
    this.status = CustomerFormStatus.initial,
    this.type = CustomerType.individual,
    this.customerId,
    this.savedCustomer,
    this.message,
  });

  final CustomerFormStatus status;
  final CustomerType type;
  final String? customerId;
  final Customer? savedCustomer;
  final String? message;

  bool get isEditing => customerId != null;

  factory CustomerFormState.fromExisting(Customer? existing) {
    if (existing == null) {
      return const CustomerFormState();
    }
    return CustomerFormState(type: existing.type, customerId: existing.id);
  }

  CustomerFormState copyWith({
    CustomerFormStatus? status,
    CustomerType? type,
    String? customerId,
    Customer? savedCustomer,
    String? message,
    bool clearMessage = false,
  }) {
    return CustomerFormState(
      status: status ?? this.status,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      savedCustomer: savedCustomer ?? this.savedCustomer,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, type, customerId, savedCustomer, message];
}
