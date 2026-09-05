part of 'delivery_worker_form_bloc.dart';

enum DeliveryWorkerFormStatus { initial, submitting, success, failure }

class DeliveryWorkerFormState extends Equatable {
  const DeliveryWorkerFormState({
    this.status = DeliveryWorkerFormStatus.initial,
    this.isEditing = false,
    this.displayName = '',
    this.email = '',
    this.phone = '',
    this.staffRole = UserRole.deliveryWorker,
    this.message,
  });

  final DeliveryWorkerFormStatus status;
  final bool isEditing;
  final String displayName;
  final String email;
  final String phone;
  final UserRole staffRole;
  final String? message;

  DeliveryWorkerFormState copyWith({
    DeliveryWorkerFormStatus? status,
    bool? isEditing,
    String? displayName,
    String? email,
    String? phone,
    UserRole? staffRole,
    String? message,
  }) {
    return DeliveryWorkerFormState(
      status: status ?? this.status,
      isEditing: isEditing ?? this.isEditing,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      staffRole: staffRole ?? this.staffRole,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isEditing,
    displayName,
    email,
    phone,
    staffRole,
    message,
  ];
}
