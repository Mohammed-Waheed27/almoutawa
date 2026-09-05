part of 'delivery_workers_list_bloc.dart';

enum DeliveryWorkersListStatus { initial, loading, success, failure }

class DeliveryWorkersListState extends Equatable {
  const DeliveryWorkersListState({
    this.status = DeliveryWorkersListStatus.initial,
    this.role = UserRole.deliveryWorker,
    this.workers = const [],
    this.page = -1,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.skeletonReload = false,
    this.message,
    this.actionMessage,
  });

  final DeliveryWorkersListStatus status;
  final UserRole role;
  final List<StaffProfile> workers;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final bool skeletonReload;
  final String? message;
  final String? actionMessage;

  bool get showBlockingSpinner => SkeletonRefresh.shouldShow(
    isLoading: status == DeliveryWorkersListStatus.loading,
    isEmpty: workers.isEmpty,
    skeletonReload: skeletonReload,
  );

  DeliveryWorkersListState copyWith({
    DeliveryWorkersListStatus? status,
    UserRole? role,
    List<StaffProfile>? workers,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    bool? skeletonReload,
    String? message,
    String? actionMessage,
    bool clearMessage = false,
  }) {
    return DeliveryWorkersListState(
      status: status ?? this.status,
      role: role ?? this.role,
      workers: workers ?? this.workers,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      skeletonReload: skeletonReload ?? this.skeletonReload,
      message: clearMessage ? null : message ?? this.message,
      actionMessage: clearMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    role,
    workers,
    page,
    totalCount,
    hasMore,
    isLoadingMore,
    skeletonReload,
    message,
    actionMessage,
  ];
}
