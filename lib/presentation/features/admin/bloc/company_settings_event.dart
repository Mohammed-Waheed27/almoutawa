part of 'company_settings_bloc.dart';

abstract class CompanySettingsEvent extends Equatable {
  const CompanySettingsEvent();

  @override
  List<Object?> get props => [];
}

class CompanySettingsStarted extends CompanySettingsEvent {
  const CompanySettingsStarted();
}

class CompanySettingsVatSaved extends CompanySettingsEvent {
  const CompanySettingsVatSaved(this.vatRate);

  final double vatRate;

  @override
  List<Object?> get props => [vatRate];
}

class CompanySettingsTermsSaved extends CompanySettingsEvent {
  const CompanySettingsTermsSaved(this.terms);

  final String terms;

  @override
  List<Object?> get props => [terms];
}

class CompanySettingsPhoneSaved extends CompanySettingsEvent {
  const CompanySettingsPhoneSaved(this.draft);

  final CompanyContactPhoneDraft draft;

  @override
  List<Object?> get props => [draft];
}

class CompanySettingsPhoneDeleted extends CompanySettingsEvent {
  const CompanySettingsPhoneDeleted(this.phoneId);

  final String phoneId;

  @override
  List<Object?> get props => [phoneId];
}
