import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/staff_profile.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/usecases/staff_usecases.dart';

part 'delivery_worker_form_event.dart';
part 'delivery_worker_form_state.dart';

class DeliveryWorkerFormBloc
    extends Bloc<DeliveryWorkerFormEvent, DeliveryWorkerFormState> {
  DeliveryWorkerFormBloc({
    required CreateDeliveryWorkerUseCase createWorker,
    required UpdateDeliveryWorkerUseCase updateWorker,
    StaffProfile? existing,
    UserRole staffRole = UserRole.deliveryWorker,
  }) : _createWorker = createWorker,
       _updateWorker = updateWorker,
       _existing = existing,
       _staffRole = existing?.role ?? staffRole,
       super(
         DeliveryWorkerFormState(
           isEditing: existing != null,
           displayName: existing?.displayName ?? '',
           email: existing?.email ?? '',
           phone: existing?.phone ?? '',
           staffRole: existing?.role ?? staffRole,
         ),
       ) {
    on<DeliveryWorkerFormSubmitted>(_onSubmitted);
  }

  final CreateDeliveryWorkerUseCase _createWorker;
  final UpdateDeliveryWorkerUseCase _updateWorker;
  final StaffProfile? _existing;
  final UserRole _staffRole;

  Future<void> _onSubmitted(
    DeliveryWorkerFormSubmitted event,
    Emitter<DeliveryWorkerFormState> emit,
  ) async {
    emit(state.copyWith(status: DeliveryWorkerFormStatus.submitting));

    if (_existing != null) {
      final draft = StaffProfileUpdateDraft(
        displayName: event.displayName,
        phone: event.phone,
      );
      final result = await _updateWorker(
        profileId: _existing!.id,
        draft: draft,
      );
      result.fold(
        (failure) {
          dbgAdminError('update worker failed', error: failure.message);
          emit(
            state.copyWith(
              status: DeliveryWorkerFormStatus.failure,
              message: failure.message,
            ),
          );
        },
        (_) {
          dbgAdmin('update worker ok profileId=${_existing!.id}');
          emit(
            state.copyWith(
              status: DeliveryWorkerFormStatus.success,
              message: 'تم تحديث البيانات',
            ),
          );
        },
      );
      return;
    }

    final draft = StaffProfileDraft(
      displayName: event.displayName,
      email: event.email,
      password: event.password,
      phone: event.phone,
      role: _staffRole,
    );
    final result = await _createWorker(draft);
    result.fold(
      (failure) {
        dbgAdminError('create worker failed', error: failure.message);
        emit(
          state.copyWith(
            status: DeliveryWorkerFormStatus.failure,
            message: failure.message,
          ),
        );
      },
      (_) {
        dbgAdmin(
          'create staff ok role=${_staffRole.dbValue} email=${event.email}',
        );
        emit(
          state.copyWith(
            status: DeliveryWorkerFormStatus.success,
            message: _staffRole == UserRole.productionManager
                ? 'تم إضافة مدير التشغيل'
                : 'تم إضافة مندوب التسليم',
          ),
        );
      },
    );
  }
}
