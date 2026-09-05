import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/company_settings.dart';
import '../../../../domain/usecases/company_settings_usecases.dart';

part 'company_settings_event.dart';
part 'company_settings_state.dart';

class CompanySettingsBloc
    extends Bloc<CompanySettingsEvent, CompanySettingsState> {
  CompanySettingsBloc({
    required FetchCompanySettingsUseCase fetchSettings,
    required UpdateCompanyVatRateUseCase updateVatRate,
    required UpdateCompanyAgreementTermsUseCase updateAgreementTerms,
    required SaveCompanyPhoneUseCase savePhone,
    required DeleteCompanyPhoneUseCase deletePhone,
  }) : _fetchSettings = fetchSettings,
       _updateVatRate = updateVatRate,
       _updateAgreementTerms = updateAgreementTerms,
       _savePhone = savePhone,
       _deletePhone = deletePhone,
       super(const CompanySettingsState()) {
    on<CompanySettingsStarted>(_onStarted);
    on<CompanySettingsVatSaved>(_onVatSaved);
    on<CompanySettingsTermsSaved>(_onTermsSaved);
    on<CompanySettingsPhoneSaved>(_onPhoneSaved);
    on<CompanySettingsPhoneDeleted>(_onPhoneDeleted);
  }

  final FetchCompanySettingsUseCase _fetchSettings;
  final UpdateCompanyVatRateUseCase _updateVatRate;
  final UpdateCompanyAgreementTermsUseCase _updateAgreementTerms;
  final SaveCompanyPhoneUseCase _savePhone;
  final DeleteCompanyPhoneUseCase _deletePhone;

  Future<void> _onStarted(
    CompanySettingsStarted event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(state.copyWith(status: CompanySettingsStatus.loading, message: null));
    final result = await _fetchSettings();
    result.fold(
      (failure) {
        dbgAdminError('company settings load failed', error: failure.message);
        emit(
          state.copyWith(
            status: CompanySettingsStatus.failure,
            message: failure.message,
          ),
        );
      },
      (settings) => emit(
        state.copyWith(
          status: CompanySettingsStatus.ready,
          settings: settings,
          message: null,
        ),
      ),
    );
  }

  Future<void> _onVatSaved(
    CompanySettingsVatSaved event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true, message: null));
    final result = await _updateVatRate(event.vatRate);
    result.fold(
      (failure) => emit(
        state.copyWith(busy: false, message: failure.message),
      ),
      (settings) {
        dbgAdmin('vat rate saved ${settings.vatPercent}');
        emit(
          state.copyWith(
            busy: false,
            settings: settings,
            message: 'تم حفظ نسبة الضريبة',
          ),
        );
      },
    );
  }

  Future<void> _onTermsSaved(
    CompanySettingsTermsSaved event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true, message: null));
    final result = await _updateAgreementTerms(event.terms);
    result.fold(
      (failure) => emit(
        state.copyWith(busy: false, message: failure.message),
      ),
      (settings) => emit(
        state.copyWith(
          busy: false,
          settings: settings,
          message: 'تم حفظ شروط الاتفاقية',
        ),
      ),
    );
  }

  Future<void> _onPhoneSaved(
    CompanySettingsPhoneSaved event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true, message: null));
    final result = await _savePhone(event.draft);
    result.fold(
      (failure) => emit(
        state.copyWith(busy: false, message: failure.message),
      ),
      (settings) => emit(
        state.copyWith(
          busy: false,
          settings: settings,
          message: event.draft.id == null
              ? 'تم إضافة رقم الهاتف'
              : 'تم تحديث رقم الهاتف',
        ),
      ),
    );
  }

  Future<void> _onPhoneDeleted(
    CompanySettingsPhoneDeleted event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true, message: null));
    final result = await _deletePhone(event.phoneId);
    result.fold(
      (failure) => emit(
        state.copyWith(busy: false, message: failure.message),
      ),
      (settings) => emit(
        state.copyWith(
          busy: false,
          settings: settings,
          message: 'تم حذف رقم الهاتف',
        ),
      ),
    );
  }
}
