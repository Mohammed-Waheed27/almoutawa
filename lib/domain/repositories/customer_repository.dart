import '../entities/customer.dart';
import '../entities/paged_result.dart';

const customersPageSize = 20;

abstract class CustomerRepository {
  Future<PagedResult<Customer>> fetchCustomersPage({
    required int page,
    int pageSize = customersPageSize,
  });

  Future<Customer> fetchCustomerById(String customerId);

  Future<List<CustomerAccountEntry>> fetchAccountEntries(String customerId);

  Future<Customer> createCustomer(CustomerDraft draft);

  Future<Customer> updateCustomer({
    required String customerId,
    required CustomerDraft draft,
  });
}
