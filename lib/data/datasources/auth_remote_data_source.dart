import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/user_role.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    dbgAuth('signIn start email=$email');
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('تعذر تسجيل الدخول');
      }
      dbgAuth('signIn auth ok userId=${user.id}');
      final session = await _fetchProfile(user.id);
      dbgAuth('signIn ok role=${session.role.dbValue}');
      return session;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'signInWithPassword',
        error: error,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      throw AuthFailure(SupabaseErrorMapper.userMessage(error));
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'signIn profile fetch',
        error: error,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      throw AuthFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'signIn unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      throw AuthFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<UserSession?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      dbgAuth('restoreSession: no auth user');
      return null;
    }

    try {
      dbgAuth('restoreSession start userId=${user.id}');
      final session = await _fetchProfile(user.id);
      dbgAuth('restoreSession ok role=${session.role.dbValue}');
      return session;
    } on AuthFailure catch (failure) {
      dbgAuthError('restoreSession profile rejected', error: failure.message);
      return null;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'restoreSession profile fetch',
        error: error,
        stackTrace: stackTrace,
        context: {'userId': user.id},
      );
      return null;
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'restoreSession unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'userId': user.id},
      );
      return null;
    }
  }

  Future<void> signOut() async {
    dbgAuth('signOut');
    try {
      await _client.auth.signOut();
      dbgAuth('signOut ok');
    } on AuthException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'signOut',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserSession> _fetchProfile(String userId) async {
    dbgAuth('fetchProfile start userId=$userId');
    try {
      final row = await _client
          .from('profiles')
          .select('id, user_id, role, display_name, is_active')
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        dbgAuthError(
          'fetchProfile: no row (RLS or missing profile)',
          data: {'userId': userId},
        );
        throw const AuthFailure('لم يتم العثور على ملف المستخدم');
      }

      if (row['is_active'] != true) {
        dbgAuthError(
          'fetchProfile: inactive account',
          data: {'userId': userId},
        );
        throw const AuthFailure('الحساب غير مفعّل');
      }

      final session = UserSession(
        userId: row['user_id'] as String,
        profileId: row['id'] as String,
        displayName: row['display_name'] as String,
        role: UserRole.fromDbValue(row['role'] as String),
      );
      dbgAuth(
        'fetchProfile ok role=${session.role.dbValue} displayName=${session.displayName}',
      );
      return session;
    } on AuthFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'fetchProfile',
        error: error,
        stackTrace: stackTrace,
        context: {'userId': userId},
      );
      throw AuthFailure(SupabaseErrorMapper.userMessage(error));
    }
  }
}
