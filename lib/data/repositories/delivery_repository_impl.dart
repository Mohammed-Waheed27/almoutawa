import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/orders_list_scope.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_orders_remote_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._remote);

  final DeliveryOrdersRemoteDataSource _remote;

  @override
  Future<PagedResult<DeliveryOrder>> fetchOrdersPage({
    required OrdersListScope scope,
    required int page,
    int pageSize = ordersPageSize,
  }) {
    return _remote.fetchOrdersPage(
      scope: scope,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<DeliveryOrder> markDelivered({
    required String orderId,
    String? deliveryNotes,
  }) {
    return _remote.markDelivered(
      orderId: orderId,
      deliveryNotes: deliveryNotes,
    );
  }
}
