/// How manufacturing orders are listed for the current role.
enum OrdersListScope {
  /// Ready orders assigned to the signed-in delivery worker.
  deliveryWorker,

  /// All orders in the system (admin).
  adminAll,
}

const ordersPageSize = 20;
