part of 'delivery_orders_bloc.dart';

sealed class DeliveryOrdersEvent extends Equatable {
  const DeliveryOrdersEvent();

  @override
  List<Object?> get props => [];
}

final class DeliveryOrdersStarted extends DeliveryOrdersEvent {
  const DeliveryOrdersStarted();
}

final class DeliveryOrdersRefreshRequested extends DeliveryOrdersEvent {
  const DeliveryOrdersRefreshRequested({this.showSkeleton = false});

  /// When true (app-bar reload), UI shows skeleton even if rows exist.
  final bool showSkeleton;

  @override
  List<Object?> get props => [showSkeleton];
}

final class DeliveryOrdersLoadMoreRequested extends DeliveryOrdersEvent {
  const DeliveryOrdersLoadMoreRequested();
}

final class DeliveryOrderSelected extends DeliveryOrdersEvent {
  const DeliveryOrderSelected(this.order);

  final DeliveryOrder order;

  @override
  List<Object?> get props => [order];
}

final class DeliveryOrderDeliverRequested extends DeliveryOrdersEvent {
  const DeliveryOrderDeliverRequested({
    required this.orderId,
    this.deliveryNotes,
  });

  final String orderId;
  final String? deliveryNotes;

  @override
  List<Object?> get props => [orderId, deliveryNotes];
}
