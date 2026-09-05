import '../../core/debug/debug_flow_logs.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../core/storage/session_cache.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SessionCache sessionCache,
  }) : _remote = remote,
       _sessionCache = sessionCache;

  final AuthRemoteDataSource _remote;
  final SessionCache _sessionCache;

  @override
  Future<UserSession?> getCurrentSession() async {
    dbgAuth('repository getCurrentSession');
    final cached = await _sessionCache.read();
    final remote = await _remote.restoreSession();

    if (remote != null) {
      await _sessionCache.write(remote);
      return remote;
    }

    if (cached != null) {
      await _sessionCache.clear();
    }
    return null;
  }

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    dbgAuth('repository signIn email=$email');
    final session = await _remote.signIn(email: email, password: password);
    await _sessionCache.write(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    await _sessionCache.clear();
    dbgAuth('session cache cleared');
  }
}
