import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../entities/customer.dart';
import '../entities/paged_result.dart';
import '../repositories/customer_repository.dart';

class FetchCustomersPageUseCase {
  FetchCustomersPageUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<Failure, PagedResult<Customer>>> call({
    required int page,
    int pageSize = customersPageSize,
  }) async {
    try {
      final result = await _repository.fetchCustomersPage(
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'FetchCustomersPageUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class FetchCustomerDetailUseCase {
  FetchCustomerDetailUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<Failure, CustomerDetailBundle>> call(String customerId) async {
    try {
      final customer = await _repository.fetchCustomerById(customerId);
      final entries = await _repository.fetchAccountEntries(customerId);
      return Right(
        CustomerDetailBundle(customer: customer, ledgerEntries: entries),
      );
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'FetchCustomerDetailUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class CreateCustomerUseCase {
  CreateCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<Failure, Customer>> call(CustomerDraft draft) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final customer = await _repository.createCustomer(draft);
      return Right(customer);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'CreateCustomerUseCase',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class UpdateCustomerUseCase {
  UpdateCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<Either<Failure, Customer>> call({
    required String customerId,
    required CustomerDraft draft,
  }) async {
    final validationError = draft.validationError;
    if (validationError != null) {
      return Left(ServerFailure(validationError));
    }

    try {
      final customer = await _repository.updateCustomer(
        customerId: customerId,
        draft: draft,
      );
      return Right(customer);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'CustomersFlow',
        step: 'UpdateCustomerUseCase',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}

class CustomerDetailBundle {
  const CustomerDetailBundle({
    required this.customer,
    required this.ledgerEntries,
  });

  final Customer customer;
  final List<CustomerAccountEntry> ledgerEntries;
}
