part of 'delivery_worker_form_bloc.dart';

sealed class DeliveryWorkerFormEvent extends Equatable {
  const DeliveryWorkerFormEvent();

  @override
  List<Object?> get props => [];
}

final class DeliveryWorkerFormSubmitted extends DeliveryWorkerFormEvent {
  const DeliveryWorkerFormSubmitted({
    required this.displayName,
    required this.email,
    required this.password,
    this.phone,
  });

  final String displayName;
  final String email;
  final String password;
  final String? phone;

  @override
  List<Object?> get props => [displayName, email, password, phone];
}
