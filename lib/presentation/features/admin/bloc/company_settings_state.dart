part of 'company_settings_bloc.dart';

enum CompanySettingsStatus { initial, loading, ready, failure }

class CompanySettingsState extends Equatable {
  const CompanySettingsState({
    this.status = CompanySettingsStatus.initial,
    this.settings,
    this.busy = false,
    this.message,
  });

  final CompanySettingsStatus status;
  final CompanySettings? settings;
  final bool busy;
  final String? message;

  CompanySettingsState copyWith({
    CompanySettingsStatus? status,
    CompanySettings? settings,
    bool? busy,
    String? message,
  }) {
    return CompanySettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      busy: busy ?? this.busy,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, settings, busy, message];
}
