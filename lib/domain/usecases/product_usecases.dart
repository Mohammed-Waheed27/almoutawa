import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/local_media_pick.dart';
import '../entities/paged_result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FetchProductsPageUseCase {
  FetchProductsPageUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, PagedResult<Product>>> call({
    required int page,
    int pageSize = productsPageSize,
  }) async {
    try {
      final result = await _repository.fetchProductsPage(
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'FetchProductsPageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchProductDetailUseCase {
  FetchProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call(String productId) async {
    try {
      final product = await _repository.fetchProductById(productId);
      return Right(product);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'FetchProductDetailUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class CreateProductUseCase {
  CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call(ProductDraft draft) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final product = await _repository.createProduct(draft);
      return Right(product);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'CreateProductUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call({
    required String productId,
    required ProductDraft draft,
    required Product baseline,
  }) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final product = await _repository.updateProduct(
        productId: productId,
        draft: draft,
        baseline: baseline,
      );
      return Right(product);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'UpdateProductUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class AppendProductImageUseCase {
  AppendProductImageUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call({
    required String productId,
    required LocalMediaPick pick,
  }) async {
    try {
      final product = await _repository.appendProductImage(
        productId: productId,
        pick: pick,
      );
      return Right(product);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'AppendProductImageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UploadPublicMediaUseCase {
  UploadPublicMediaUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, String>> call({
    required String folder,
    required LocalMediaPick pick,
  }) async {
    try {
      final url = await _repository.uploadPublicMedia(
        folder: folder,
        pick: pick,
      );
      return Right(url);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'UploadPublicMediaUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class AppendColorImageUseCase {
  AppendColorImageUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Product>> call({
    required String productId,
    required String colorId,
    required LocalMediaPick pick,
  }) async {
    try {
      final product = await _repository.appendColorImage(
        productId: productId,
        colorId: colorId,
        pick: pick,
      );
      return Right(product);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'AppendColorImageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
