import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/entities/user_role.dart';

class CustomersRemoteDataSource {
  CustomersRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _customerSelect =
      'id, customer_number, customer_type, full_name, phone, address, governorate, '
      'company_name, responsible_person, commercial_register, notes, '
      'created_by, assigned_sales_rep_id, created_at, updated_at, '
      'creator:profiles!customers_created_by_fkey(display_name, role)';

  Future<PagedResult<Customer>> fetchCustomersPage({
    required int page,
    required int pageSize,
  }) async {
    dbgCustomers('fetchCustomersPage start page=$page');
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from('customers')
          .select(_customerSelect)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final rows = response.data as List<dynamic>;
      final totalCount = response.count;
      final balances = await _fetchBalanceMap();

      final customers = rows
          .map(
            (row) => _mapCustomer(
              row as Map<String, dynamic>,
              balance: balances[row['id'] as String] ?? 0,
            ),
          )
          .toList(growable: false);

      dbgCustomers(
        'fetchCustomersPage ok count=${customers.length} total=$totalCount',
      );
      return PagedResult(
        items: customers,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'fetchCustomersPage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'fetchCustomersPage unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Customer> fetchCustomerById(String customerId) async {
    dbgCustomers('fetchCustomerById start id=$customerId');
    try {
      final row = await _client
          .from('customers')
          .select(_customerSelect)
          .eq('id', customerId)
          .eq('is_active', true)
          .maybeSingle();

      if (row == null) {
        throw const ServerFailure('لم يتم العثور على العميل');
      }

      final balances = await _fetchBalanceMap();
      final customer = _mapCustomer(row, balance: balances[customerId] ?? 0);
      dbgCustomers('fetchCustomerById ok id=$customerId');
      return customer;
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'fetchCustomerById',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<List<CustomerAccountEntry>> fetchAccountEntries(
    String customerId,
  ) async {
    dbgCustomers('fetchAccountEntries start customerId=$customerId');
    try {
      final rows = await _client
          .from('customer_account_entries')
          .select(
            'id, customer_id, entry_type, amount, description, occurred_at, '
            'commercial_order_id, collected_by_profile_id, entry_kind, '
            'collector:profiles!collected_by_profile_id(display_name), '
            'order:commercial_orders!commercial_order_id(order_number)',
          )
          .eq('customer_id', customerId)
          .order('occurred_at', ascending: false);

      final entries = (rows as List<dynamic>)
          .map((row) => _mapLedgerEntry(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgCustomers('fetchAccountEntries ok count=${entries.length}');
      return entries;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'fetchAccountEntries',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Customer> createCustomer(CustomerDraft draft) async {
    dbgCustomers('createCustomer start type=${draft.type.dbValue}');
    try {
      final row = await _client
          .from('customers')
          .insert(_draftToPayload(draft))
          .select(_customerSelect)
          .single();

      dbgCustomers('createCustomer ok id=${row['id']}');
      return _mapCustomer(row, balance: 0);
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'createCustomer',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Customer> updateCustomer({
    required String customerId,
    required CustomerDraft draft,
  }) async {
    dbgCustomers('updateCustomer start id=$customerId');
    try {
      final row = await _client
          .from('customers')
          .update(_draftToPayload(draft))
          .eq('id', customerId)
          .select(_customerSelect)
          .maybeSingle();

      if (row == null) {
        throw const ServerFailure('تعذر تحديث العميل — تحقق من الصلاحيات');
      }

      final balances = await _fetchBalanceMap();
      dbgCustomers('updateCustomer ok id=$customerId');
      return _mapCustomer(row, balance: balances[customerId] ?? 0);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'updateCustomer',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Map<String, double>> _fetchBalanceMap() async {
    try {
      final rows = await _client
          .from('customer_account_balances')
          .select('customer_id, balance');
      final map = <String, double>{};
      for (final row in rows as List<dynamic>) {
        final data = row as Map<String, dynamic>;
        map[data['customer_id'] as String] = _parseAmount(data['balance']);
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic> _draftToPayload(CustomerDraft draft) {
    return {
      'customer_type': draft.type.dbValue,
      'full_name': draft.fullName?.trim(),
      'phone': draft.phone?.trim(),
      'address': draft.address?.trim(),
      'governorate': draft.governorate?.trim(),
      'company_name': draft.companyName?.trim(),
      'responsible_person': draft.responsiblePerson?.trim(),
      'commercial_register': draft.commercialRegister?.trim(),
      'notes': draft.notes?.trim(),
    };
  }

  Customer _mapCustomer(Map<String, dynamic> row, {required double balance}) {
    final creator = row['creator'] as Map<String, dynamic>?;
    final creatorRole = creator?['role'] as String?;
    return Customer(
      id: row['id'] as String,
      customerNumber: (row['customer_number'] as num).toInt(),
      type: CustomerType.fromDbValue(row['customer_type'] as String),
      fullName: row['full_name'] as String?,
      phone: row['phone'] as String?,
      address: row['address'] as String?,
      governorate: row['governorate'] as String?,
      companyName: row['company_name'] as String?,
      responsiblePerson: row['responsible_person'] as String?,
      commercialRegister: row['commercial_register'] as String?,
      notes: row['notes'] as String?,
      createdByProfileId: row['created_by'] as String,
      createdByDisplayName: creator?['display_name'] as String?,
      createdByRoleLabel: creatorRole == null
          ? null
          : UserRole.fromDbValue(creatorRole).arabicLabel,
      assignedSalesRepId: row['assigned_sales_rep_id'] as String?,
      accountBalance: balance,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  CustomerAccountEntry _mapLedgerEntry(Map<String, dynamic> row) {
    final collector = _asMap(row['collector']);
    final order = _asMap(row['order']);
    return CustomerAccountEntry(
      id: row['id'] as String,
      customerId: row['customer_id'] as String,
      entryType: LedgerEntryType.fromDbValue(row['entry_type'] as String),
      amount: _parseAmount(row['amount']),
      description: row['description'] as String,
      occurredAt: DateTime.parse(row['occurred_at'] as String),
      commercialOrderId: row['commercial_order_id'] as String?,
      orderNumber: order?['order_number'] as String?,
      collectedByProfileId: row['collected_by_profile_id'] as String?,
      collectedByName: collector?['display_name'] as String?,
      entryKind: row['entry_kind'] as String?,
    );
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }

  double _parseAmount(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
