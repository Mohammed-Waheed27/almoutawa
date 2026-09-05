import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/orders_list_scope.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/delivery_repository.dart';

class FetchOrdersPageUseCase {
  FetchOrdersPageUseCase(this._repository);

  final DeliveryRepository _repository;

  Future<Either<Failure, PagedResult<DeliveryOrder>>> call({
    required OrdersListScope scope,
    required int page,
    int pageSize = ordersPageSize,
  }) async {
    try {
      final pageResult = await _repository.fetchOrdersPage(
        scope: scope,
        page: page,
        pageSize: pageSize,
      );
      return Right(pageResult);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'FetchOrdersPageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class MarkOrderDeliveredUseCase {
  MarkOrderDeliveredUseCase(this._repository);

  final DeliveryRepository _repository;

  Future<Either<Failure, DeliveryOrder>> call({
    required String orderId,
    String? deliveryNotes,
  }) async {
    try {
      final order = await _repository.markDelivered(
        orderId: orderId,
        deliveryNotes: deliveryNotes,
      );
      return Right(order);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'MarkOrderDeliveredUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
