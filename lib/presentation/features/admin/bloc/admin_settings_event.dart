part of 'admin_settings_bloc.dart';

abstract class AdminSettingsEvent extends Equatable {
  const AdminSettingsEvent();

  @override
  List<Object?> get props => [];
}

class AdminSettingsStarted extends AdminSettingsEvent {
  const AdminSettingsStarted();
}

class AdminSettingsRefreshRequested extends AdminSettingsEvent {
  const AdminSettingsRefreshRequested();
}
