import '../../domain/entities/company_settings.dart';
import '../../domain/repositories/company_settings_repository.dart';
import '../datasources/company_settings_remote_data_source.dart';

class CompanySettingsRepositoryImpl implements CompanySettingsRepository {
  CompanySettingsRepositoryImpl(this._remote);

  final CompanySettingsRemoteDataSource _remote;

  @override
  Future<CompanySettings> fetchSettings() => _remote.fetchSettings();

  @override
  Future<CompanySettings> updateVatRate(double vatRate) =>
      _remote.updateVatRate(vatRate);

  @override
  Future<CompanySettings> updateAgreementTerms(String terms) =>
      _remote.updateAgreementTerms(terms);

  @override
  Future<CompanySettings> savePhone(CompanyContactPhoneDraft draft) =>
      _remote.savePhone(draft);

  @override
  Future<CompanySettings> deletePhone(String phoneId) =>
      _remote.deletePhone(phoneId);
}
