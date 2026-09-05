import 'package:equatable/equatable.dart';

import 'commercial_order.dart';
import 'user_role.dart';

/// Preset date windows for admin reports.
enum AdminReportPeriod {
  today,
  week,
  month,
  quarter,
  year,
  all,
  custom;

  String get arabicLabel => switch (this) {
    AdminReportPeriod.today => 'اليوم',
    AdminReportPeriod.week => 'آخر ٧ أيام',
    AdminReportPeriod.month => 'هذا الشهر',
    AdminReportPeriod.quarter => 'هذا الربع',
    AdminReportPeriod.year => 'هذه السنة',
    AdminReportPeriod.all => 'الكل',
    AdminReportPeriod.custom => 'مخصص',
  };
}

class AdminReportDateRange extends Equatable {
  const AdminReportDateRange({required this.period, this.from, this.to});

  final AdminReportPeriod period;
  final DateTime? from;
  final DateTime? to;

  /// Inclusive UTC-ish local bounds used for filtering.
  (DateTime?, DateTime?) resolve() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    switch (period) {
      case AdminReportPeriod.today:
        return (DateTime(now.year, now.month, now.day), end);
      case AdminReportPeriod.week:
        return (end.subtract(const Duration(days: 6)), end);
      case AdminReportPeriod.month:
        return (DateTime(now.year, now.month, 1), end);
      case AdminReportPeriod.quarter:
        final qStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return (DateTime(now.year, qStartMonth, 1), end);
      case AdminReportPeriod.year:
        return (DateTime(now.year, 1, 1), end);
      case AdminReportPeriod.all:
        return (null, null);
      case AdminReportPeriod.custom:
        final f = from == null
            ? null
            : DateTime(from!.year, from!.month, from!.day);
        final t = to == null
            ? null
            : DateTime(to!.year, to!.month, to!.day, 23, 59, 59, 999);
        return (f, t);
    }
  }

  @override
  List<Object?> get props => [period, from, to];
}

class AdminReportsOverview extends Equatable {
  const AdminReportsOverview({
    required this.ordersTotal,
    required this.ordersQuote,
    required this.ordersAgreement,
    required this.ordersManufacturing,
    required this.ordersManufacturingDraft,
    required this.ordersCompleted,
    required this.ordersDelivered,
    required this.ordersCancelled,
    required this.quoteValue,
    required this.agreementValue,
    required this.downPayments,
    required this.activeCustomers,
    required this.activeStaff,
  });

  final int ordersTotal;
  final int ordersQuote;
  final int ordersAgreement;
  final int ordersManufacturing;
  final int ordersManufacturingDraft;
  final int ordersCompleted;
  final int ordersDelivered;
  final int ordersCancelled;
  final double quoteValue;
  final double agreementValue;
  final double downPayments;
  final int activeCustomers;
  final int activeStaff;

  @override
  List<Object?> get props => [
    ordersTotal,
    ordersQuote,
    ordersAgreement,
    ordersManufacturing,
    ordersManufacturingDraft,
    ordersCompleted,
    ordersDelivered,
    ordersCancelled,
    quoteValue,
    agreementValue,
    downPayments,
    activeCustomers,
    activeStaff,
  ];
}

class StaffPerformanceRow extends Equatable {
  const StaffPerformanceRow({
    required this.profileId,
    required this.displayName,
    required this.role,
    this.phone,
    required this.isActive,
    required this.ordersCreated,
    required this.opsActions,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.agreementValue,
    required this.downPayments,
  });

  final String profileId;
  final String displayName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final int ordersCreated;
  final int opsActions;
  final int completedOrders;
  final int cancelledOrders;
  final double agreementValue;
  final double downPayments;

  int get totalActivity => ordersCreated + opsActions;

  @override
  List<Object?> get props => [
    profileId,
    displayName,
    role,
    phone,
    isActive,
    ordersCreated,
    opsActions,
    completedOrders,
    cancelledOrders,
    agreementValue,
    downPayments,
  ];
}

class CustomerPerformanceRow extends Equatable {
  const CustomerPerformanceRow({
    required this.customerId,
    required this.customerNumber,
    required this.customerTypeLabel,
    required this.displayName,
    this.phone,
    this.governorate,
    required this.ordersCount,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.activeOrders,
    required this.agreementValue,
    required this.downPayments,
    this.lastOrderAt,
  });

  final String customerId;
  final int customerNumber;
  final String customerTypeLabel;
  final String displayName;
  final String? phone;
  final String? governorate;
  final int ordersCount;
  final int completedOrders;
  final int cancelledOrders;
  final int activeOrders;
  final double agreementValue;
  final double downPayments;
  final DateTime? lastOrderAt;

  @override
  List<Object?> get props => [
    customerId,
    customerNumber,
    customerTypeLabel,
    displayName,
    phone,
    governorate,
    ordersCount,
    completedOrders,
    cancelledOrders,
    activeOrders,
    agreementValue,
    downPayments,
    lastOrderAt,
  ];
}

class AdminReportOrderRow extends Equatable {
  const AdminReportOrderRow({
    required this.orderId,
    required this.orderNumber,
    required this.phase,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.staffId,
    this.staffName,
    this.factoryId,
    this.factoryName,
    required this.orderValue,
    required this.downPayment,
    required this.remaining,
  });

  final String orderId;
  final String orderNumber;
  final String phase;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? staffId;
  final String? staffName;
  final String? factoryId;
  final String? factoryName;
  final double orderValue;
  final double downPayment;
  final double remaining;

  String get phaseLabel =>
      CommercialOrderPhase.fromDbValue(phase).arabicLabel;

  @override
  List<Object?> get props => [
    orderId,
    orderNumber,
    phase,
    createdAt,
    updatedAt,
    customerId,
    customerName,
    customerPhone,
    staffId,
    staffName,
    factoryId,
    factoryName,
    orderValue,
    downPayment,
    remaining,
  ];
}

class AdminReportsBundle extends Equatable {
  const AdminReportsBundle({
    required this.range,
    required this.overview,
    required this.staff,
    required this.customers,
    this.orders = const [],
  });

  final AdminReportDateRange range;
  final AdminReportsOverview overview;
  final List<StaffPerformanceRow> staff;
  final List<CustomerPerformanceRow> customers;
  final List<AdminReportOrderRow> orders;

  AdminReportsBundle copyWith({List<AdminReportOrderRow>? orders}) {
    return AdminReportsBundle(
      range: range,
      overview: overview,
      staff: staff,
      customers: customers,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [range, overview, staff, customers, orders];
}
