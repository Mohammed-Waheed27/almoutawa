import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/paged_result.dart';
import '../entities/staff_profile.dart';
import '../entities/user_role.dart';
import '../repositories/staff_repository.dart';

class FetchDeliveryWorkersPageUseCase {
  FetchDeliveryWorkersPageUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, PagedResult<StaffProfile>>> call({
    required int page,
    int pageSize = staffPageSize,
    UserRole role = UserRole.deliveryWorker,
  }) async {
    try {
      final result = await _repository.fetchStaffPage(
        role: role,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'FetchDeliveryWorkersPageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class CreateDeliveryWorkerUseCase {
  CreateDeliveryWorkerUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, StaffProfile>> call(StaffProfileDraft draft) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final profile = await _repository.createDeliveryWorker(draft);
      return Right(profile);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'CreateDeliveryWorkerUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UpdateDeliveryWorkerUseCase {
  UpdateDeliveryWorkerUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, StaffProfile>> call({
    required String profileId,
    required StaffProfileUpdateDraft draft,
  }) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final profile = await _repository.updateDeliveryWorker(
        profileId: profileId,
        draft: draft,
      );
      return Right(profile);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'UpdateDeliveryWorkerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'profileId': profileId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SuspendDeliveryWorkerUseCase {
  SuspendDeliveryWorkerUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, StaffProfile>> call(String profileId) async {
    try {
      final profile = await _repository.suspendDeliveryWorker(profileId);
      return Right(profile);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'SuspendDeliveryWorkerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'profileId': profileId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class ReactivateDeliveryWorkerUseCase {
  ReactivateDeliveryWorkerUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, StaffProfile>> call(String profileId) async {
    try {
      final profile = await _repository.reactivateDeliveryWorker(profileId);
      return Right(profile);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'ReactivateDeliveryWorkerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'profileId': profileId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class DeleteDeliveryWorkerUseCase {
  DeleteDeliveryWorkerUseCase(this._repository);

  final StaffRepository _repository;

  Future<Either<Failure, void>> call(String profileId) async {
    try {
      await _repository.deleteDeliveryWorker(profileId);
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'DeleteDeliveryWorkerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'profileId': profileId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
