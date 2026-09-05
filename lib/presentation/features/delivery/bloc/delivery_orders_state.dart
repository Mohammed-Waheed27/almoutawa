part of 'delivery_orders_bloc.dart';

enum DeliveryOrdersStatus { initial, loading, success, failure, delivering }

final class DeliveryOrdersState extends Equatable {
  const DeliveryOrdersState({
    this.status = DeliveryOrdersStatus.initial,
    this.orders = const [],
    this.page = -1,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.skeletonReload = false,
    this.selectedOrder,
    this.message,
    this.actionMessage,
  });

  final DeliveryOrdersStatus status;
  final List<DeliveryOrder> orders;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final bool skeletonReload;
  final DeliveryOrder? selectedOrder;
  final String? message;
  final String? actionMessage;

  bool get showBlockingSpinner => SkeletonRefresh.shouldShow(
    isLoading: status == DeliveryOrdersStatus.loading,
    isEmpty: orders.isEmpty,
    skeletonReload: skeletonReload,
  );

  DeliveryOrdersState copyWith({
    DeliveryOrdersStatus? status,
    List<DeliveryOrder>? orders,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    bool? skeletonReload,
    DeliveryOrder? selectedOrder,
    String? message,
    String? actionMessage,
    bool clearMessages = false,
    bool clearSelected = false,
  }) {
    return DeliveryOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      skeletonReload: skeletonReload ?? this.skeletonReload,
      selectedOrder: clearSelected
          ? null
          : (selectedOrder ?? this.selectedOrder),
      message: clearMessages ? null : (message ?? this.message),
      actionMessage: clearMessages
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    page,
    totalCount,
    hasMore,
    isLoadingMore,
    skeletonReload,
    selectedOrder,
    message,
    actionMessage,
  ];
}
