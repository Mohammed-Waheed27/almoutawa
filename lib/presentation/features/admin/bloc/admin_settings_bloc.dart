import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/storage_quota.dart';
import '../../../../domain/usecases/storage_usecases.dart';

part 'admin_settings_event.dart';
part 'admin_settings_state.dart';

class AdminSettingsBloc extends Bloc<AdminSettingsEvent, AdminSettingsState> {
  AdminSettingsBloc({required FetchStorageQuotaUseCase fetchStorageQuota})
    : _fetchStorageQuota = fetchStorageQuota,
      super(const AdminSettingsState()) {
    on<AdminSettingsStarted>(_onStarted);
    on<AdminSettingsRefreshRequested>(_onRefresh);
  }

  final FetchStorageQuotaUseCase _fetchStorageQuota;

  Future<void> _onStarted(
    AdminSettingsStarted event,
    Emitter<AdminSettingsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefresh(
    AdminSettingsRefreshRequested event,
    Emitter<AdminSettingsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<AdminSettingsState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    final result = await _fetchStorageQuota();
    result.fold(
      (failure) {
        dbgAdminError('settings storage load failed', error: failure.message);
        emit(
          state.copyWith(
            isLoading: false,
            message: failure.message,
          ),
        );
      },
      (quota) => emit(
        state.copyWith(isLoading: false, storageQuota: quota, clearMessage: true),
      ),
    );
  }
}
