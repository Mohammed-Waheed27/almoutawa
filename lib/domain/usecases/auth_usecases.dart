import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserSession>> call({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      return Right(session);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'SignInUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() async {
    try {
      await _repository.signOut();
      return const Right(null);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'SignOutUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class RestoreSessionUseCase {
  RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserSession?>> call() async {
    try {
      final session = await _repository.getCurrentSession().timeout(
        const Duration(seconds: 12),
      );
      return Right(session);
    } on TimeoutException {
      return const Left(
        ServerFailure('انتهت مهلة استعادة الجلسة — تحقق من الاتصال'),
      );
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AuthFlow',
        step: 'RestoreSessionUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
