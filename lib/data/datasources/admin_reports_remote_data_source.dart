import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/admin_report.dart';
import '../../domain/entities/user_role.dart';

/// Loads admin performance reports via RPCs when available,
/// with a client-side aggregation fallback on existing tables.
class AdminReportsRemoteDataSource {
  AdminReportsRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<AdminReportsBundle> fetchReports({
    required AdminReportDateRange range,
    UserRole? staffRole,
  }) async {
    final bounds = range.resolve();
    final from = bounds.$1;
    final to = bounds.$2;

    dbgAdmin(
      'admin reports fetch period=${range.period.name} '
      'from=$from to=$to role=${staffRole?.dbValue}',
    );

    try {
      final rpcBundle = await _tryFetchViaRpc(
        range: range,
        from: from,
        to: to,
        staffRole: staffRole,
      );
      if (rpcBundle != null) {
        dbgAdmin(
          'admin reports rpc ok staff=${rpcBundle.staff.length} '
          'customers=${rpcBundle.customers.length}',
        );
        return rpcBundle;
      }
    } catch (error, stackTrace) {
      dbgAdminError(
        'admin reports rpc unavailable — using table fallback',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final fallback = await _fetchViaTables(
      range: range,
      from: from,
      to: to,
      staffRole: staffRole,
    );
    dbgAdmin(
      'admin reports fallback ok staff=${fallback.staff.length} '
      'customers=${fallback.customers.length}',
    );
    return fallback;
  }

  Future<AdminReportsBundle?> _tryFetchViaRpc({
    required AdminReportDateRange range,
    required DateTime? from,
    required DateTime? to,
    UserRole? staffRole,
  }) async {
    final overviewRaw = await _client.rpc(
      'admin_reports_overview',
      params: {
        'p_from': from?.toUtc().toIso8601String(),
        'p_to': to?.toUtc().toIso8601String(),
      },
    );
    final staffRaw = await _client.rpc(
      'admin_reports_staff',
      params: {
        'p_from': from?.toUtc().toIso8601String(),
        'p_to': to?.toUtc().toIso8601String(),
        'p_role': staffRole?.dbValue,
      },
    );
    final customersRaw = await _client.rpc(
      'admin_reports_customers',
      params: {
        'p_from': from?.toUtc().toIso8601String(),
        'p_to': to?.toUtc().toIso8601String(),
      },
    );
    List<AdminReportOrderRow> orders = const [];
    try {
      final ordersRaw = await _client.rpc(
        'admin_reports_orders',
        params: {
          'p_from': from?.toUtc().toIso8601String(),
          'p_to': to?.toUtc().toIso8601String(),
        },
      );
      orders = _mapOrdersList(ordersRaw);
    } catch (error, stackTrace) {
      dbgAdminError(
        'admin reports orders rpc skipped',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return AdminReportsBundle(
      range: range,
      overview: _mapOverview(overviewRaw),
      staff: _mapStaffList(staffRaw),
      customers: _mapCustomerList(customersRaw),
      orders: orders,
    );
  }

  Future<AdminReportsBundle> _fetchViaTables({
    required AdminReportDateRange range,
    required DateTime? from,
    required DateTime? to,
    UserRole? staffRole,
  }) async {
    try {
      var ordersQuery = _client
          .from('commercial_orders')
          .select(
            'id, order_number, phase, created_at, updated_at, created_by, '
            'customer_id, factory_id, '
            'creator:profiles!commercial_orders_created_by_fkey('
            'id, display_name, role, phone, is_active'
            '), '
            'customer:customers('
            'id, customer_number, customer_type, full_name, company_name, '
            'phone, governorate'
            '), '
            'factory:factories(id, short_name_ar), '
            'quote:order_quotes(grand_total), '
            'agreement:order_agreements(grand_total, down_payment)',
          );

      if (from != null) {
        ordersQuery = ordersQuery.gte(
          'created_at',
          from.toUtc().toIso8601String(),
        );
      }
      if (to != null) {
        ordersQuery = ordersQuery.lte(
          'created_at',
          to.toUtc().toIso8601String(),
        );
      }

      final orderRows =
          (await ordersQuery.order('created_at', ascending: false))
              as List<dynamic>;

      var staffQuery = _client
          .from('profiles')
          .select('id, display_name, role, phone, is_active')
          .inFilter('role', [
            UserRole.deliveryWorker.dbValue,
            UserRole.productionManager.dbValue,
          ]);

      if (staffRole != null) {
        staffQuery = staffQuery.eq('role', staffRole.dbValue);
      }

      final staffRows =
          (await staffQuery.order('display_name')) as List<dynamic>;

      return _aggregateFromRows(
        range: range,
        orderRows: orderRows,
        staffRows: staffRows,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'adminReportsFallback',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'adminReportsFallback unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  AdminReportsBundle _aggregateFromRows({
    required AdminReportDateRange range,
    required List<dynamic> orderRows,
    required List<dynamic> staffRows,
  }) {
    var quoteCount = 0;
    var agreementCount = 0;
    var manufacturingCount = 0;
    var manufacturingDraftCount = 0;
    var completedCount = 0;
    var deliveredCount = 0;
    var cancelledCount = 0;
    var quoteValue = 0.0;
    var agreementValue = 0.0;
    var downPayments = 0.0;
    final customerIds = <String>{};
    final creatorIds = <String>{};

    final staffAgg = <String, _StaffAgg>{};
    for (final raw in staffRows) {
      final row = raw as Map<String, dynamic>;
      final id = row['id'] as String;
      staffAgg[id] = _StaffAgg(
        profileId: id,
        displayName: (row['display_name'] as String?)?.trim().isNotEmpty == true
            ? row['display_name'] as String
            : 'بدون اسم',
        role: UserRole.fromDbValue(row['role'] as String),
        phone: row['phone'] as String?,
        isActive: row['is_active'] as bool? ?? true,
      );
    }

    final customerAgg = <String, _CustomerAgg>{};
    final mappedOrders = <AdminReportOrderRow>[];

    for (final raw in orderRows) {
      final row = raw as Map<String, dynamic>;
      final phase = row['phase'] as String? ?? 'quote';
      final createdBy = row['created_by'] as String?;
      final customerId = row['customer_id'] as String?;
      final quote = _firstMap(row['quote']);
      final agreement = _firstMap(row['agreement']);
      final qTotal = _asDouble(quote?['grand_total']);
      final aTotal = _asDouble(agreement?['grand_total']);
      final down = _asDouble(agreement?['down_payment']);

      switch (phase) {
        case 'quote':
          quoteCount++;
        case 'agreement':
          agreementCount++;
        case 'manufacturing_draft':
          manufacturingDraftCount++;
        case 'manufacturing':
          manufacturingCount++;
        case 'completed':
          completedCount++;
        case 'delivered':
          deliveredCount++;
        case 'cancelled':
          cancelledCount++;
      }
      quoteValue += qTotal;
      agreementValue += aTotal;
      downPayments += down;
      if (customerId != null) customerIds.add(customerId);
      if (createdBy != null) creatorIds.add(createdBy);

      if (createdBy != null) {
        final agg = staffAgg.putIfAbsent(createdBy, () {
          final creator = _firstMap(row['creator']);
          return _StaffAgg(
            profileId: createdBy,
            displayName:
                (creator?['display_name'] as String?)?.trim().isNotEmpty == true
                ? creator!['display_name'] as String
                : 'موظف',
            role: UserRole.fromDbValue(
              (creator?['role'] as String?) ?? UserRole.deliveryWorker.dbValue,
            ),
            phone: creator?['phone'] as String?,
            isActive: creator?['is_active'] as bool? ?? true,
          );
        });
        agg.ordersCreated++;
        if (phase == 'completed') agg.completedOrders++;
        if (phase == 'cancelled') agg.cancelledOrders++;
        agg.agreementValue += aTotal;
        agg.downPayments += down;
      }

      final customer = _firstMap(row['customer']);
      final factory = _firstMap(row['factory']);
      final creator = _firstMap(row['creator']);
      final customerType = customer?['customer_type'] as String? ?? 'individual';
      final customerName = customerType == 'company'
          ? (customer?['company_name'] as String? ?? '—')
          : (customer?['full_name'] as String? ?? '—');

      if (customerId != null) {
        final agg = customerAgg.putIfAbsent(
          customerId,
          () => _CustomerAgg(
            customerId: customerId,
            customerNumber: _asInt(customer?['customer_number']),
            customerTypeLabel: customerType == 'company' ? 'مؤسسة' : 'فرد',
            displayName: customerName,
            phone: customer?['phone'] as String?,
            governorate: customer?['governorate'] as String?,
          ),
        );
        agg.ordersCount++;
        if (phase == 'completed') agg.completedOrders++;
        if (phase == 'cancelled') agg.cancelledOrders++;
        if (phase == 'quote' ||
            phase == 'agreement' ||
            phase == 'manufacturing_draft' ||
            phase == 'manufacturing') {
          agg.activeOrders++;
        }
        agg.agreementValue += aTotal;
        agg.downPayments += down;
        final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
        if (createdAt != null &&
            (agg.lastOrderAt == null || createdAt.isAfter(agg.lastOrderAt!))) {
          agg.lastOrderAt = createdAt;
        }
      }

      final orderValue = aTotal > 0 ? aTotal : qTotal;
      mappedOrders.add(
        AdminReportOrderRow(
          orderId: (row['id'] as String?) ?? '',
          orderNumber: (row['order_number'] as String?) ?? '—',
          phase: phase,
          createdAt:
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          updatedAt:
              DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          customerId: customerId ?? '',
          customerName: customerId == null ? '—' : customerName,
          customerPhone: customer?['phone'] as String?,
          staffId: createdBy,
          staffName: creator?['display_name'] as String?,
          factoryId: row['factory_id'] as String?,
          factoryName: factory?['short_name_ar'] as String?,
          orderValue: orderValue,
          downPayment: down,
          remaining: orderValue - down,
        ),
      );
    }

    final staff =
        staffAgg.values
            .map(
              (a) => StaffPerformanceRow(
                profileId: a.profileId,
                displayName: a.displayName,
                role: a.role,
                phone: a.phone,
                isActive: a.isActive,
                ordersCreated: a.ordersCreated,
                opsActions: a.opsActions,
                completedOrders: a.completedOrders,
                cancelledOrders: a.cancelledOrders,
                agreementValue: a.agreementValue,
                downPayments: a.downPayments,
              ),
            )
            .toList()
          ..sort((a, b) {
            final byOrders = b.ordersCreated.compareTo(a.ordersCreated);
            if (byOrders != 0) return byOrders;
            return a.displayName.compareTo(b.displayName);
          });

    final customers =
        customerAgg.values
            .map(
              (a) => CustomerPerformanceRow(
                customerId: a.customerId,
                customerNumber: a.customerNumber,
                customerTypeLabel: a.customerTypeLabel,
                displayName: a.displayName,
                phone: a.phone,
                governorate: a.governorate,
                ordersCount: a.ordersCount,
                completedOrders: a.completedOrders,
                cancelledOrders: a.cancelledOrders,
                activeOrders: a.activeOrders,
                agreementValue: a.agreementValue,
                downPayments: a.downPayments,
                lastOrderAt: a.lastOrderAt,
              ),
            )
            .toList()
          ..sort((a, b) {
            final byOrders = b.ordersCount.compareTo(a.ordersCount);
            if (byOrders != 0) return byOrders;
            return a.displayName.compareTo(b.displayName);
          });

    return AdminReportsBundle(
      range: range,
      overview: AdminReportsOverview(
        ordersTotal: orderRows.length,
        ordersQuote: quoteCount,
        ordersAgreement: agreementCount,
        ordersManufacturing: manufacturingCount,
        ordersManufacturingDraft: manufacturingDraftCount,
        ordersCompleted: completedCount,
        ordersDelivered: deliveredCount,
        ordersCancelled: cancelledCount,
        quoteValue: quoteValue,
        agreementValue: agreementValue,
        downPayments: downPayments,
        activeCustomers: customerIds.length,
        activeStaff: creatorIds.length,
      ),
      staff: staff,
      customers: customers,
      orders: mappedOrders,
    );
  }

  AdminReportsOverview _mapOverview(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return AdminReportsOverview(
      ordersTotal: _asInt(map['orders_total']),
      ordersQuote: _asInt(map['orders_quote']),
      ordersAgreement: _asInt(map['orders_agreement']),
      ordersManufacturing: _asInt(map['orders_manufacturing']),
      ordersManufacturingDraft: _asInt(map['orders_manufacturing_draft']),
      ordersCompleted: _asInt(map['orders_completed']),
      ordersDelivered: _asInt(map['orders_delivered']),
      ordersCancelled: _asInt(map['orders_cancelled']),
      quoteValue: _asDouble(map['quote_value']),
      agreementValue: _asDouble(map['agreement_value']),
      downPayments: _asDouble(map['down_payments']),
      activeCustomers: _asInt(map['active_customers']),
      activeStaff: _asInt(map['active_staff']),
    );
  }

  List<StaffPerformanceRow> _mapStaffList(dynamic raw) {
    final list = raw is List ? raw : const [];
    return list
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return StaffPerformanceRow(
            profileId: map['profile_id'] as String,
            displayName: (map['display_name'] as String?) ?? '—',
            role: UserRole.fromDbValue(
              (map['role'] as String?) ?? UserRole.deliveryWorker.dbValue,
            ),
            phone: map['phone'] as String?,
            isActive: map['is_active'] as bool? ?? true,
            ordersCreated: _asInt(map['orders_created']),
            opsActions: _asInt(map['ops_actions']),
            completedOrders: _asInt(map['completed_orders']),
            cancelledOrders: _asInt(map['cancelled_orders']),
            agreementValue: _asDouble(map['agreement_value']),
            downPayments: _asDouble(
              map['deposits_collected'] ?? map['down_payments'],
            ),
          );
        })
        .toList(growable: false);
  }

  List<CustomerPerformanceRow> _mapCustomerList(dynamic raw) {
    final list = raw is List ? raw : const [];
    return list
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final type = map['customer_type'] as String? ?? 'individual';
          return CustomerPerformanceRow(
            customerId: map['customer_id'] as String,
            customerNumber: _asInt(map['customer_number']),
            customerTypeLabel: type == 'company' ? 'مؤسسة' : 'فرد',
            displayName: (map['display_name'] as String?) ?? '—',
            phone: map['phone'] as String?,
            governorate: map['governorate'] as String?,
            ordersCount: _asInt(map['orders_count']),
            completedOrders: _asInt(map['completed_orders']),
            cancelledOrders: _asInt(map['cancelled_orders']),
            activeOrders: _asInt(map['active_orders']),
            agreementValue: _asDouble(map['agreement_value']),
            downPayments: _asDouble(map['down_payments']),
            lastOrderAt: DateTime.tryParse(
              map['last_order_at'] as String? ?? '',
            ),
          );
        })
        .toList(growable: false);
  }

  List<AdminReportOrderRow> _mapOrdersList(dynamic raw) {
    final list = raw is List ? raw : const [];
    return list
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final typeName = (map['company_name'] as String?)?.trim();
          final fullName = (map['full_name'] as String?)?.trim();
          return AdminReportOrderRow(
            orderId: map['id'] as String,
            orderNumber: (map['order_number'] as String?) ?? '—',
            phase: (map['phase'] as String?) ?? 'quote',
            createdAt:
                DateTime.tryParse(map['created_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
            updatedAt:
                DateTime.tryParse(map['updated_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
            customerId: (map['customer_id'] as String?) ?? '',
            customerName: (typeName != null && typeName.isNotEmpty)
                ? typeName
                : (fullName == null || fullName.isEmpty ? '—' : fullName),
            customerPhone: map['customer_phone'] as String?,
            staffId: map['created_by'] as String?,
            staffName: map['staff_name'] as String?,
            factoryId: map['factory_id'] as String?,
            factoryName: map['factory_name'] as String?,
            orderValue: _asDouble(map['order_value']),
            downPayment: _asDouble(map['down_payment']),
            remaining: _asDouble(map['remaining']),
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic>? _firstMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class _StaffAgg {
  _StaffAgg({
    required this.profileId,
    required this.displayName,
    required this.role,
    this.phone,
    required this.isActive,
  });

  final String profileId;
  final String displayName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  int ordersCreated = 0;
  int opsActions = 0;
  int completedOrders = 0;
  int cancelledOrders = 0;
  double agreementValue = 0;
  double downPayments = 0;
}

class _CustomerAgg {
  _CustomerAgg({
    required this.customerId,
    required this.customerNumber,
    required this.customerTypeLabel,
    required this.displayName,
    this.phone,
    this.governorate,
  });

  final String customerId;
  final int customerNumber;
  final String customerTypeLabel;
  final String displayName;
  final String? phone;
  final String? governorate;
  int ordersCount = 0;
  int completedOrders = 0;
  int cancelledOrders = 0;
  int activeOrders = 0;
  double agreementValue = 0;
  double downPayments = 0;
  DateTime? lastOrderAt;
}
