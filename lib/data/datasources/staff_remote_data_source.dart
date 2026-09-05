import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/entities/staff_profile.dart';
import '../../domain/entities/user_role.dart';

class StaffRemoteDataSource {
  StaffRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _profileSelect =
      'id, user_id, role, display_name, phone, email, is_active, created_at';

  Future<PagedResult<StaffProfile>> fetchDeliveryWorkersPage({
    required int page,
    required int pageSize,
  }) {
    return fetchStaffPage(
      role: UserRole.deliveryWorker,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<PagedResult<StaffProfile>> fetchStaffPage({
    required UserRole role,
    required int page,
    required int pageSize,
  }) async {
    dbgAdmin('fetchStaffPage start role=${role.dbValue} page=$page');
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from('profiles')
          .select(_profileSelect)
          .eq('role', role.dbValue)
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final rows = response.data as List<dynamic>;
      final totalCount = response.count;
      final profiles = rows
          .map((row) => _mapProfile(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgAdmin('fetchStaffPage ok count=${profiles.length} total=$totalCount');
      return PagedResult(
        items: profiles,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'fetchStaffPage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<StaffProfile> createDeliveryWorker(StaffProfileDraft draft) async {
    return _invokeStaffAction(
      action: 'create',
      body: {
        'email': draft.email.trim(),
        'password': draft.password.trim(),
        'displayName': draft.displayName.trim(),
        'phone': draft.phone?.trim(),
        'role': draft.role.dbValue,
      },
    );
  }

  Future<StaffProfile> updateDeliveryWorker({
    required String profileId,
    required StaffProfileUpdateDraft draft,
  }) async {
    return _invokeStaffAction(
      action: 'update',
      body: {
        'profileId': profileId,
        'displayName': draft.displayName.trim(),
        'phone': draft.phone?.trim(),
      },
    );
  }

  Future<StaffProfile> suspendDeliveryWorker(String profileId) async {
    return _invokeStaffAction(
      action: 'suspend',
      body: {'profileId': profileId},
    );
  }

  Future<StaffProfile> reactivateDeliveryWorker(String profileId) async {
    return _invokeStaffAction(
      action: 'reactivate',
      body: {'profileId': profileId},
    );
  }

  Future<void> deleteDeliveryWorker(String profileId) async {
    dbgAdmin('admin-staff action=delete profileId=$profileId');
    try {
      final response = await _client.functions.invoke(
        'admin-staff',
        body: {'action': 'delete', 'profileId': profileId},
      );

      if (response.status != 200) {
        throw ServerFailure(_extractError(response.data));
      }
      dbgAdmin('admin-staff action=delete ok');
    } on ServerFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'admin-staff delete',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<StaffProfile> _invokeStaffAction({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    dbgAdmin('admin-staff action=$action');
    try {
      final response = await _client.functions.invoke(
        'admin-staff',
        body: {'action': action, ...body},
      );

      if (response.status != 200) {
        final message = _extractError(response.data);
        throw ServerFailure(message);
      }

      final data = response.data as Map<String, dynamic>;
      final profileJson = data['profile'] as Map<String, dynamic>;
      dbgAdmin('admin-staff action=$action ok profileId=${profileJson['id']}');
      return _mapProfile(profileJson);
    } on ServerFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'admin-staff $action',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'admin-staff $action unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  String _extractError(Object? data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    return 'تعذر تنفيذ العملية';
  }

  StaffProfile _mapProfile(Map<String, dynamic> row) {
    return StaffProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      role: UserRole.fromDbValue(row['role'] as String),
      displayName: row['display_name'] as String,
      email: row['email'] as String?,
      phone: row['phone'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
