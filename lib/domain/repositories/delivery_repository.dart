import '../entities/delivery_order.dart';
import '../entities/orders_list_scope.dart';
import '../entities/paged_result.dart';

abstract class DeliveryRepository {
  Future<PagedResult<DeliveryOrder>> fetchOrdersPage({
    required OrdersListScope scope,
    required int page,
    int pageSize = ordersPageSize,
  });

  Future<DeliveryOrder> markDelivered({
    required String orderId,
    String? deliveryNotes,
  });
}
