import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/commercial_order.dart';
import '../entities/factory_profile.dart';
import '../entities/manufacturing_card.dart';
import '../entities/paged_result.dart';
import '../repositories/commercial_order_repository.dart';

class FetchFactoriesUseCase {
  FetchFactoriesUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, List<FactoryProfile>>> call() async {
    try {
      final factories = await _repository.fetchFactories();
      return Right(factories);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'FetchFactoriesUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchCommercialOrdersPageUseCase {
  FetchCommercialOrdersPageUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, PagedResult<CommercialOrderSummary>>> call({
    required int page,
    int pageSize = commercialOrdersPageSize,
  }) async {
    try {
      final result = await _repository.fetchOrdersPage(
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'FetchCommercialOrdersPageUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'page': page, 'pageSize': pageSize},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchCommercialOrdersForCustomerUseCase {
  FetchCommercialOrdersForCustomerUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, List<CommercialOrderSummary>>> call(
    String customerId,
  ) async {
    try {
      final items = await _repository.fetchOrdersForCustomer(customerId);
      return Right(items);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'FetchCommercialOrdersForCustomerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchCommercialOrderDetailUseCase {
  FetchCommercialOrderDetailUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, CommercialOrderDetail>> call(String orderId) async {
    try {
      final detail = await _repository.fetchOrderDetail(orderId);
      return Right(detail);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'FetchCommercialOrderDetailUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class CreateCommercialOrderUseCase {
  CreateCommercialOrderUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, CommercialOrderDetail>> call(
    CreateCommercialOrderInput input,
  ) async {
    try {
      final detail = await _repository.createOrder(input);
      return Right(detail);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'CreateCommercialOrderUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': input.customerId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SaveQuoteUseCase {
  SaveQuoteUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, OrderQuote>> call({
    required String orderId,
    required QuoteDraft draft,
  }) async {
    try {
      final quote = await _repository.saveQuote(orderId: orderId, draft: draft);
      return Right(quote);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'SaveQuoteUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SaveAgreementUseCase {
  SaveAgreementUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, OrderAgreement>> call({
    required String orderId,
    required AgreementDraft draft,
  }) async {
    try {
      final agreement = await _repository.saveAgreement(
        orderId: orderId,
        draft: draft,
      );
      return Right(agreement);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'SaveAgreementUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class AdvanceCommercialOrderPhaseUseCase {
  AdvanceCommercialOrderPhaseUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String orderId,
    required CommercialOrderPhase phase,
  }) async {
    try {
      await _repository.advancePhase(orderId: orderId, phase: phase);
      return const Right(unit);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'AdvanceCommercialOrderPhaseUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'phase': phase.dbValue},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class AssignCommercialOrderFactoryUseCase {
  AssignCommercialOrderFactoryUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, CommercialOrderDetail>> call({
    required String orderId,
    required String factoryId,
  }) async {
    try {
      final detail = await _repository.assignFactory(
        orderId: orderId,
        factoryId: factoryId,
      );
      return Right(detail);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'AssignCommercialOrderFactoryUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'factoryId': factoryId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchManufacturingCardsUseCase {
  FetchManufacturingCardsUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, List<ManufacturingCard>>> call(String orderId) async {
    try {
      final cards = await _repository.fetchManufacturingCards(orderId);
      return Right(cards);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'FetchManufacturingCardsUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class SaveManufacturingCardUseCase {
  SaveManufacturingCardUseCase(this._repository);

  final CommercialOrderRepository _repository;

  Future<Either<Failure, ManufacturingCard>> call({
    required String orderId,
    required String agreementId,
    required ManufacturingCardDraft draft,
  }) async {
    try {
      final card = await _repository.saveManufacturingCard(
        orderId: orderId,
        agreementId: agreementId,
        draft: draft,
      );
      return Right(card);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'SaveManufacturingCardUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'agreementId': agreementId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class DefaultQuoteOtherCommentsUseCase {
  DefaultQuoteOtherCommentsUseCase(this._repository);

  final CommercialOrderRepository _repository;

  String call() => _repository.defaultQuoteOtherComments();
}
