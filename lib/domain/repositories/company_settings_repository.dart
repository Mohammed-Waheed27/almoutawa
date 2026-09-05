import '../entities/company_settings.dart';

abstract class CompanySettingsRepository {
  Future<CompanySettings> fetchSettings();

  Future<CompanySettings> updateVatRate(double vatRate);

  Future<CompanySettings> updateAgreementTerms(String terms);

  Future<CompanySettings> savePhone(CompanyContactPhoneDraft draft);

  Future<CompanySettings> deletePhone(String phoneId);
}
