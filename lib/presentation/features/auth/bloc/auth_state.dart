part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.message,
  });

  final AuthStatus status;
  final UserSession? session;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
