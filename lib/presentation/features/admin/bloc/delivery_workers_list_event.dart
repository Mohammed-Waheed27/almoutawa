part of 'delivery_workers_list_bloc.dart';

sealed class DeliveryWorkersListEvent extends Equatable {
  const DeliveryWorkersListEvent();

  @override
  List<Object?> get props => [];
}

final class DeliveryWorkersListStarted extends DeliveryWorkersListEvent {
  const DeliveryWorkersListStarted({this.role = UserRole.deliveryWorker});

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

final class DeliveryWorkersListRoleChanged extends DeliveryWorkersListEvent {
  const DeliveryWorkersListRoleChanged(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

final class DeliveryWorkersListRefreshRequested
    extends DeliveryWorkersListEvent {
  const DeliveryWorkersListRefreshRequested({this.showSkeleton = false});

  final bool showSkeleton;

  @override
  List<Object?> get props => [showSkeleton];
}

final class DeliveryWorkersListLoadMoreRequested
    extends DeliveryWorkersListEvent {
  const DeliveryWorkersListLoadMoreRequested();
}

final class DeliveryWorkerSuspendRequested extends DeliveryWorkersListEvent {
  const DeliveryWorkerSuspendRequested(this.profileId);

  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

final class DeliveryWorkerReactivateRequested extends DeliveryWorkersListEvent {
  const DeliveryWorkerReactivateRequested(this.profileId);

  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

final class DeliveryWorkerDeleteRequested extends DeliveryWorkersListEvent {
  const DeliveryWorkerDeleteRequested(this.profileId);

  final String profileId;

  @override
  List<Object?> get props => [profileId];
}
