part of 'customer_form_bloc.dart';

sealed class CustomerFormEvent extends Equatable {
  const CustomerFormEvent();

  @override
  List<Object?> get props => [];
}

final class CustomerFormTypeChanged extends CustomerFormEvent {
  const CustomerFormTypeChanged(this.type);

  final CustomerType type;

  @override
  List<Object?> get props => [type];
}

final class CustomerFormSubmitted extends CustomerFormEvent {
  const CustomerFormSubmitted({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.governorate,
    required this.companyName,
    required this.responsiblePerson,
    required this.commercialRegister,
    required this.notes,
  });

  final String fullName;
  final String phone;
  final String address;
  final String governorate;
  final String companyName;
  final String responsiblePerson;
  final String commercialRegister;
  final String notes;

  @override
  List<Object?> get props => [
    fullName,
    phone,
    address,
    governorate,
    companyName,
    responsiblePerson,
    commercialRegister,
    notes,
  ];
}
