part of 'customers_list_bloc.dart';

enum CustomersListStatus { initial, loading, success, failure }

class CustomersListState extends Equatable {
  const CustomersListState({
    this.status = CustomersListStatus.initial,
    this.customers = const [],
    this.page = -1,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.skeletonReload = false,
    this.message,
    this.refreshTick = 0,
  });

  final CustomersListStatus status;
  final List<Customer> customers;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final bool skeletonReload;
  final String? message;
  final int refreshTick;

  bool get showBlockingSpinner => SkeletonRefresh.shouldShow(
    isLoading: status == CustomersListStatus.loading,
    isEmpty: customers.isEmpty,
    skeletonReload: skeletonReload,
  );

  CustomersListState copyWith({
    CustomersListStatus? status,
    List<Customer>? customers,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    bool? skeletonReload,
    String? message,
    bool clearMessage = false,
    int? refreshTick,
  }) {
    return CustomersListState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      skeletonReload: skeletonReload ?? this.skeletonReload,
      message: clearMessage ? null : message ?? this.message,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customers,
    page,
    totalCount,
    hasMore,
    isLoadingMore,
    skeletonReload,
    message,
    refreshTick,
  ];
}
