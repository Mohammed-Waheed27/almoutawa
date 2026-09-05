import '../../domain/entities/customer.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customers_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._remote);

  final CustomersRemoteDataSource _remote;

  @override
  Future<PagedResult<Customer>> fetchCustomersPage({
    required int page,
    int pageSize = customersPageSize,
  }) {
    return _remote.fetchCustomersPage(page: page, pageSize: pageSize);
  }

  @override
  Future<Customer> fetchCustomerById(String customerId) {
    return _remote.fetchCustomerById(customerId);
  }

  @override
  Future<List<CustomerAccountEntry>> fetchAccountEntries(String customerId) {
    return _remote.fetchAccountEntries(customerId);
  }

  @override
  Future<Customer> createCustomer(CustomerDraft draft) {
    return _remote.createCustomer(draft);
  }

  @override
  Future<Customer> updateCustomer({
    required String customerId,
    required CustomerDraft draft,
  }) {
    return _remote.updateCustomer(customerId: customerId, draft: draft);
  }
}
