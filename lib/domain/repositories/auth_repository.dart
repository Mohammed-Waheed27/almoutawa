import '../entities/user_role.dart';

/// Auth contract — data layer implements via Supabase.
abstract class AuthRepository {
  Future<UserSession?> getCurrentSession();

  Future<UserSession> signIn({required String email, required String password});

  Future<void> signOut();
}
