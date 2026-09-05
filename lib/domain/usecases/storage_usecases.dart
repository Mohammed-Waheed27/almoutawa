import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/storage_quota.dart';
import '../repositories/storage_repository.dart';

class FetchStorageQuotaUseCase {
  FetchStorageQuotaUseCase(this._repository);

  final StorageRepository _repository;

  Future<Either<Failure, StorageQuota>> call() async {
    try {
      final quota = await _repository.fetchStorageQuota();
      return Right(quota);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'FetchStorageQuotaUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
