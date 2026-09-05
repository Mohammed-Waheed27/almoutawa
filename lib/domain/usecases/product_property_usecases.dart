import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/product_property.dart';
import '../repositories/product_property_repository.dart';

class FetchProductPropertyDefinitionsUseCase {
  FetchProductPropertyDefinitionsUseCase(this._repository);

  final ProductPropertyRepository _repository;

  Future<Either<Failure, List<ProductPropertyDefinition>>> call() async {
    try {
      final definitions = await _repository.fetchDefinitions();
      return Right(definitions);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'FetchProductPropertyDefinitionsUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SaveProductPropertyDefinitionUseCase {
  SaveProductPropertyDefinitionUseCase(this._repository);

  final ProductPropertyRepository _repository;

  Future<Either<Failure, ProductPropertyDefinition>> call({
    required ProductPropertyDefinitionDraft draft,
    String? definitionId,
  }) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final saved = definitionId == null
          ? await _repository.createDefinition(draft)
          : await _repository.updateDefinition(definitionId, draft);
      return Right(saved);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'SaveProductPropertyDefinitionUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
