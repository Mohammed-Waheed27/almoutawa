import 'package:dartz/dartz.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/company_settings.dart';
import '../repositories/company_settings_repository.dart';

class FetchCompanySettingsUseCase {
  FetchCompanySettingsUseCase(this._repository);

  final CompanySettingsRepository _repository;

  Future<Either<Failure, CompanySettings>> call() async {
    try {
      final settings = await _repository.fetchSettings();
      return Right(settings);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'FetchCompanySettingsUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UpdateCompanyVatRateUseCase {
  UpdateCompanyVatRateUseCase(this._repository);

  final CompanySettingsRepository _repository;

  Future<Either<Failure, CompanySettings>> call(double vatRate) async {
    dbgAdmin('UpdateCompanyVatRate start rate=$vatRate');
    try {
      final settings = await _repository.updateVatRate(vatRate);
      return Right(settings);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'UpdateCompanyVatRateUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UpdateCompanyAgreementTermsUseCase {
  UpdateCompanyAgreementTermsUseCase(this._repository);

  final CompanySettingsRepository _repository;

  Future<Either<Failure, CompanySettings>> call(String terms) async {
    dbgAdmin('UpdateCompanyAgreementTerms start');
    try {
      final settings = await _repository.updateAgreementTerms(terms);
      return Right(settings);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'UpdateCompanyAgreementTermsUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SaveCompanyPhoneUseCase {
  SaveCompanyPhoneUseCase(this._repository);

  final CompanySettingsRepository _repository;

  Future<Either<Failure, CompanySettings>> call(
    CompanyContactPhoneDraft draft,
  ) async {
    final error = draft.validationError;
    if (error != null) return Left(ServerFailure(error));
    try {
      final settings = await _repository.savePhone(draft);
      return Right(settings);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'SaveCompanyPhoneUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class DeleteCompanyPhoneUseCase {
  DeleteCompanyPhoneUseCase(this._repository);

  final CompanySettingsRepository _repository;

  Future<Either<Failure, CompanySettings>> call(String phoneId) async {
    try {
      final settings = await _repository.deletePhone(phoneId);
      return Right(settings);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'DeleteCompanyPhoneUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
