import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/usecases/customer_usecases.dart';

part 'customer_form_event.dart';
part 'customer_form_state.dart';

class CustomerFormBloc extends Bloc<CustomerFormEvent, CustomerFormState> {
  CustomerFormBloc({
    required CreateCustomerUseCase createCustomer,
    required UpdateCustomerUseCase updateCustomer,
    Customer? existing,
  }) : _createCustomer = createCustomer,
       _updateCustomer = updateCustomer,
       super(CustomerFormState.fromExisting(existing)) {
    on<CustomerFormTypeChanged>(_onTypeChanged);
    on<CustomerFormSubmitted>(_onSubmitted);
  }

  final CreateCustomerUseCase _createCustomer;
  final UpdateCustomerUseCase _updateCustomer;

  void _onTypeChanged(
    CustomerFormTypeChanged event,
    Emitter<CustomerFormState> emit,
  ) {
    emit(state.copyWith(type: event.type, clearMessage: true));
  }

  Future<void> _onSubmitted(
    CustomerFormSubmitted event,
    Emitter<CustomerFormState> emit,
  ) async {
    emit(
      state.copyWith(status: CustomerFormStatus.submitting, clearMessage: true),
    );

    final draft = CustomerDraft(
      type: state.type,
      fullName: event.fullName,
      phone: event.phone,
      address: event.address,
      governorate: event.governorate,
      companyName: event.companyName,
      responsiblePerson: event.responsiblePerson,
      commercialRegister: event.commercialRegister,
      notes: event.notes,
    );

    final result = state.isEditing
        ? await _updateCustomer(customerId: state.customerId!, draft: draft)
        : await _createCustomer(draft);

    result.fold(
      (failure) {
        dbgCustomersError('form submit failed', error: failure.message);
        emit(
          state.copyWith(
            status: CustomerFormStatus.failure,
            message: failure.message,
          ),
        );
      },
      (customer) {
        dbgCustomers('form submit ok id=${customer.id}');
        emit(
          state.copyWith(
            status: CustomerFormStatus.success,
            savedCustomer: customer,
          ),
        );
      },
    );
  }
}
