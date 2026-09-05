part of 'admin_settings_bloc.dart';

class AdminSettingsState extends Equatable {
  const AdminSettingsState({
    this.isLoading = false,
    this.storageQuota,
    this.message,
  });

  final bool isLoading;
  final StorageQuota? storageQuota;
  final String? message;

  AdminSettingsState copyWith({
    bool? isLoading,
    StorageQuota? storageQuota,
    String? message,
    bool clearMessage = false,
  }) {
    return AdminSettingsState(
      isLoading: isLoading ?? this.isLoading,
      storageQuota: storageQuota ?? this.storageQuota,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [isLoading, storageQuota, message];
}
