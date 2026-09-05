import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/admin_report.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/usecases/admin_reports_usecases.dart';

class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  AdminReportsBloc({required FetchAdminReportsUseCase fetchReports})
    : _fetchReports = fetchReports,
      super(const AdminReportsState()) {
    on<AdminReportsStarted>(_onStarted);
    on<AdminReportsPeriodChanged>(_onPeriodChanged);
    on<AdminReportsCustomRangeChanged>(_onCustomRangeChanged);
    on<AdminReportsStaffRoleFilterChanged>(_onStaffRoleFilterChanged);
    on<AdminReportsSearchChanged>(_onSearchChanged);
    on<AdminReportsTabChanged>(_onTabChanged);
    on<AdminReportsRefreshed>(_onRefreshed);
    on<AdminReportsOrderFiltersChanged>(_onOrderFiltersChanged);
    on<AdminReportsOrderFiltersCleared>(_onOrderFiltersCleared);
  }

  final FetchAdminReportsUseCase _fetchReports;

  Future<void> _onStarted(
    AdminReportsStarted event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminReportsStatus.loading,
        range: const AdminReportDateRange(period: AdminReportPeriod.month),
      ),
    );
    await _load(emit);
  }

  Future<void> _onPeriodChanged(
    AdminReportsPeriodChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        range: AdminReportDateRange(
          period: event.period,
          from: state.range.from,
          to: state.range.to,
        ),
        status: state.bundle == null
            ? AdminReportsStatus.loading
            : AdminReportsStatus.refreshing,
      ),
    );
    await _load(emit);
  }

  Future<void> _onCustomRangeChanged(
    AdminReportsCustomRangeChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        range: AdminReportDateRange(
          period: AdminReportPeriod.custom,
          from: event.from,
          to: event.to,
        ),
        status: state.bundle == null
            ? AdminReportsStatus.loading
            : AdminReportsStatus.refreshing,
      ),
    );
    await _load(emit);
  }

  Future<void> _onStaffRoleFilterChanged(
    AdminReportsStaffRoleFilterChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        staffRoleFilter: event.role,
        clearStaffRoleFilter: event.role == null,
        status: state.bundle == null
            ? AdminReportsStatus.loading
            : AdminReportsStatus.refreshing,
      ),
    );
    await _load(emit);
  }

  void _onSearchChanged(
    AdminReportsSearchChanged event,
    Emitter<AdminReportsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onTabChanged(
    AdminReportsTabChanged event,
    Emitter<AdminReportsState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.index));
  }

  Future<void> _onRefreshed(
    AdminReportsRefreshed event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: state.bundle == null
            ? AdminReportsStatus.loading
            : AdminReportsStatus.refreshing,
      ),
    );
    await _load(emit);
  }

  void _onOrderFiltersChanged(
    AdminReportsOrderFiltersChanged event,
    Emitter<AdminReportsState> emit,
  ) {
    emit(
      state.copyWith(
        filterCustomerId: event.customerId,
        clearCustomerFilter: event.clearCustomer,
        filterStaffId: event.staffId,
        clearStaffFilter: event.clearStaff,
        filterFactoryId: event.factoryId,
        clearFactoryFilter: event.clearFactory,
        filterPhase: event.phase,
        clearPhaseFilter: event.clearPhase,
        tabIndex: event.tabIndex ?? state.tabIndex,
      ),
    );
  }

  void _onOrderFiltersCleared(
    AdminReportsOrderFiltersCleared event,
    Emitter<AdminReportsState> emit,
  ) {
    emit(
      state.copyWith(
        clearCustomerFilter: true,
        clearStaffFilter: true,
        clearFactoryFilter: true,
        clearPhaseFilter: true,
      ),
    );
  }

  Future<void> _load(Emitter<AdminReportsState> emit) async {
    final result = await _fetchReports(
      range: state.range,
      staffRole: state.staffRoleFilter,
    );
    result.fold(
      (failure) {
        dbgAdminError('admin reports load failed', error: failure.message);
        emit(
          state.copyWith(
            status: AdminReportsStatus.failure,
            message: failure.message,
          ),
        );
      },
      (bundle) {
        dbgAdmin(
          'admin reports loaded orders=${bundle.overview.ordersTotal} '
          'staff=${bundle.staff.length} customers=${bundle.customers.length}',
        );
        emit(
          state.copyWith(
            status: AdminReportsStatus.ready,
            bundle: bundle,
            message: null,
          ),
        );
      },
    );
  }
}

sealed class AdminReportsEvent extends Equatable {
  const AdminReportsEvent();
  @override
  List<Object?> get props => [];
}

class AdminReportsStarted extends AdminReportsEvent {
  const AdminReportsStarted();
}

class AdminReportsPeriodChanged extends AdminReportsEvent {
  const AdminReportsPeriodChanged(this.period);
  final AdminReportPeriod period;
  @override
  List<Object?> get props => [period];
}

class AdminReportsCustomRangeChanged extends AdminReportsEvent {
  const AdminReportsCustomRangeChanged({required this.from, required this.to});
  final DateTime from;
  final DateTime to;
  @override
  List<Object?> get props => [from, to];
}

class AdminReportsStaffRoleFilterChanged extends AdminReportsEvent {
  const AdminReportsStaffRoleFilterChanged(this.role);
  final UserRole? role;
  @override
  List<Object?> get props => [role];
}

class AdminReportsSearchChanged extends AdminReportsEvent {
  const AdminReportsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class AdminReportsTabChanged extends AdminReportsEvent {
  const AdminReportsTabChanged(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class AdminReportsRefreshed extends AdminReportsEvent {
  const AdminReportsRefreshed();
}

class AdminReportsOrderFiltersChanged extends AdminReportsEvent {
  const AdminReportsOrderFiltersChanged({
    this.customerId,
    this.clearCustomer = false,
    this.staffId,
    this.clearStaff = false,
    this.factoryId,
    this.clearFactory = false,
    this.phase,
    this.clearPhase = false,
    this.tabIndex,
  });

  final String? customerId;
  final bool clearCustomer;
  final String? staffId;
  final bool clearStaff;
  final String? factoryId;
  final bool clearFactory;
  final String? phase;
  final bool clearPhase;
  final int? tabIndex;

  @override
  List<Object?> get props => [
    customerId,
    clearCustomer,
    staffId,
    clearStaff,
    factoryId,
    clearFactory,
    phase,
    clearPhase,
    tabIndex,
  ];
}

class AdminReportsOrderFiltersCleared extends AdminReportsEvent {
  const AdminReportsOrderFiltersCleared();
}

enum AdminReportsStatus { initial, loading, refreshing, ready, failure }

class AdminReportsState extends Equatable {
  const AdminReportsState({
    this.status = AdminReportsStatus.initial,
    this.range = const AdminReportDateRange(period: AdminReportPeriod.month),
    this.staffRoleFilter,
    this.searchQuery = '',
    this.tabIndex = 0,
    this.bundle,
    this.message,
    this.filterCustomerId,
    this.filterStaffId,
    this.filterFactoryId,
    this.filterPhase,
  });

  final AdminReportsStatus status;
  final AdminReportDateRange range;
  final UserRole? staffRoleFilter;
  final String searchQuery;
  final int tabIndex;
  final AdminReportsBundle? bundle;
  final String? message;
  final String? filterCustomerId;
  final String? filterStaffId;
  final String? filterFactoryId;
  final String? filterPhase;

  bool get showBlockingSkeleton =>
      (status == AdminReportsStatus.loading ||
          status == AdminReportsStatus.initial) &&
      bundle == null;

  bool get hasOrderFilters =>
      filterCustomerId != null ||
      filterStaffId != null ||
      filterFactoryId != null ||
      filterPhase != null;

  List<StaffPerformanceRow> get filteredStaff {
    final rows = bundle?.staff ?? const <StaffPerformanceRow>[];
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows
        .where(
          (r) =>
              r.displayName.toLowerCase().contains(q) ||
              (r.phone?.contains(q) ?? false) ||
              r.role.arabicLabel.contains(searchQuery.trim()),
        )
        .toList(growable: false);
  }

  List<CustomerPerformanceRow> get filteredCustomers {
    final rows = bundle?.customers ?? const <CustomerPerformanceRow>[];
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows
        .where(
          (r) =>
              r.displayName.toLowerCase().contains(q) ||
              (r.phone?.contains(q) ?? false) ||
              '${r.customerNumber}'.contains(q) ||
              (r.governorate?.contains(searchQuery.trim()) ?? false),
        )
        .toList(growable: false);
  }

  List<AdminReportOrderRow> get filteredOrders {
    var rows = bundle?.orders ?? const <AdminReportOrderRow>[];
    if (filterCustomerId != null) {
      rows = rows.where((r) => r.customerId == filterCustomerId).toList();
    }
    if (filterStaffId != null) {
      rows = rows.where((r) => r.staffId == filterStaffId).toList();
    }
    if (filterFactoryId != null) {
      rows = rows.where((r) => r.factoryId == filterFactoryId).toList();
    }
    if (filterPhase != null) {
      rows = rows.where((r) => r.phase == filterPhase).toList();
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows
        .where(
          (r) =>
              r.orderNumber.toLowerCase().contains(q) ||
              r.customerName.toLowerCase().contains(q) ||
              (r.staffName?.toLowerCase().contains(q) ?? false) ||
              (r.factoryName?.toLowerCase().contains(q) ?? false) ||
              r.phaseLabel.contains(searchQuery.trim()),
        )
        .toList(growable: false);
  }

  AdminReportsState copyWith({
    AdminReportsStatus? status,
    AdminReportDateRange? range,
    UserRole? staffRoleFilter,
    bool clearStaffRoleFilter = false,
    String? searchQuery,
    int? tabIndex,
    AdminReportsBundle? bundle,
    String? message,
    String? filterCustomerId,
    bool clearCustomerFilter = false,
    String? filterStaffId,
    bool clearStaffFilter = false,
    String? filterFactoryId,
    bool clearFactoryFilter = false,
    String? filterPhase,
    bool clearPhaseFilter = false,
  }) {
    return AdminReportsState(
      status: status ?? this.status,
      range: range ?? this.range,
      staffRoleFilter: clearStaffRoleFilter
          ? null
          : (staffRoleFilter ?? this.staffRoleFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      tabIndex: tabIndex ?? this.tabIndex,
      bundle: bundle ?? this.bundle,
      message: message,
      filterCustomerId: clearCustomerFilter
          ? null
          : (filterCustomerId ?? this.filterCustomerId),
      filterStaffId: clearStaffFilter
          ? null
          : (filterStaffId ?? this.filterStaffId),
      filterFactoryId: clearFactoryFilter
          ? null
          : (filterFactoryId ?? this.filterFactoryId),
      filterPhase: clearPhaseFilter ? null : (filterPhase ?? this.filterPhase),
    );
  }

  @override
  List<Object?> get props => [
    status,
    range,
    staffRoleFilter,
    searchQuery,
    tabIndex,
    bundle,
    message,
    filterCustomerId,
    filterStaffId,
    filterFactoryId,
    filterPhase,
  ];
}
