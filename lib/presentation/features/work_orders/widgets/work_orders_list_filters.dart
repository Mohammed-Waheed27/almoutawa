import '../../../../domain/entities/commercial_order.dart';

/// Quick bucket used by KPI taps (نشطة / منتهية).
enum WorkOrderActivityFilter { all, active, finished }

extension WorkOrderActivityFilterX on WorkOrderActivityFilter {
  String get arabicLabel => switch (this) {
    WorkOrderActivityFilter.all => 'الكل',
    WorkOrderActivityFilter.active => 'نشطة',
    WorkOrderActivityFilter.finished => 'منتهية',
  };

  bool matches(CommercialOrderSummary summary) {
    return switch (this) {
      WorkOrderActivityFilter.all => true,
      WorkOrderActivityFilter.active => summary.order.phase.isActive,
      WorkOrderActivityFilter.finished => summary.order.phase.isFinished,
    };
  }
}

/// Combinable list filters — phase + document status + customer (+ activity).
class WorkOrdersListFilters {
  const WorkOrdersListFilters({
    this.activity = WorkOrderActivityFilter.all,
    this.phase,
    this.documentStatus,
    this.customerId,
  });

  final WorkOrderActivityFilter activity;
  final CommercialOrderPhase? phase;
  final DocumentIssueStatus? documentStatus;
  final String? customerId;

  static const empty = WorkOrdersListFilters();

  bool get hasActiveFilters =>
      activity != WorkOrderActivityFilter.all ||
      phase != null ||
      documentStatus != null ||
      customerId != null;

  WorkOrdersListFilters copyWith({
    WorkOrderActivityFilter? activity,
    CommercialOrderPhase? phase,
    bool clearPhase = false,
    DocumentIssueStatus? documentStatus,
    bool clearDocumentStatus = false,
    String? customerId,
    bool clearCustomerId = false,
  }) {
    return WorkOrdersListFilters(
      activity: activity ?? this.activity,
      phase: clearPhase ? null : (phase ?? this.phase),
      documentStatus: clearDocumentStatus
          ? null
          : (documentStatus ?? this.documentStatus),
      customerId: clearCustomerId ? null : (customerId ?? this.customerId),
    );
  }

  bool matches(CommercialOrderSummary summary) {
    if (!activity.matches(summary)) return false;
    if (phase != null && summary.order.phase != phase) return false;
    if (customerId != null && summary.customer.id != customerId) return false;
    if (documentStatus != null && !_matchesDocumentStatus(summary)) {
      return false;
    }
    return true;
  }

  bool _matchesDocumentStatus(CommercialOrderSummary summary) {
    final status = switch (summary.order.phase) {
      CommercialOrderPhase.quote => summary.quoteStatus,
      CommercialOrderPhase.agreement => summary.agreementStatus,
      _ => summary.agreementStatus ?? summary.quoteStatus,
    };
    return status == documentStatus;
  }
}

class WorkOrderCustomerFilterOption {
  const WorkOrderCustomerFilterOption({required this.id, required this.label});

  final String id;
  final String label;
}

List<WorkOrderCustomerFilterOption> customerOptionsFromOrders(
  List<CommercialOrderSummary> items,
) {
  final map = <String, WorkOrderCustomerFilterOption>{};
  for (final item in items) {
    map.putIfAbsent(
      item.customer.id,
      () => WorkOrderCustomerFilterOption(
        id: item.customer.id,
        label: '${item.customer.displayName} · ${item.customer.customerNumber}',
      ),
    );
  }
  final list = map.values.toList()..sort((a, b) => a.label.compareTo(b.label));
  return list;
}
