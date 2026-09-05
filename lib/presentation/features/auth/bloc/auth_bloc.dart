import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required RestoreSessionUseCase restoreSession,
    required SignInUseCase signIn,
    required SignOutUseCase signOut,
  }) : _restoreSession = restoreSession,
       _signIn = signIn,
       _signOut = signOut,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final RestoreSessionUseCase _restoreSession;
  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    dbgAuth('AuthStarted');
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _restoreSession();
    result.fold(
      (failure) {
        dbgAuthError('restore failed', error: failure.message);
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            session: null,
            message: failure.message,
          ),
        );
      },
      (session) {
        if (session == null) {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              session: null,
              clearMessage: true,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: session,
            clearMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _signIn(email: event.email, password: event.password);
    result.fold(
      (failure) {
        dbgAuthError('signIn failed', error: failure.message);
        emit(
          state.copyWith(status: AuthStatus.failure, message: failure.message),
        );
      },
      (session) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: session,
            clearMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    await _signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
