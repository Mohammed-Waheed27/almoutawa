import '../../domain/entities/user_role.dart';

/// Global route paths for the door-manufacturing ERP.
abstract final class AppRoutes {
  static const login = '/login';
  static const bootstrap = '/bootstrap';
  static const salesDashboard = '/sales';
  static const adminDashboard = '/admin';
  static const adminHome = '/admin/home';
  static const adminOrders = '/admin/orders';
  static const adminReports = '/admin/reports';
  static const adminSettings = '/admin/settings';
  static const adminCustomers = '/admin/customers';
  static const adminWorkers = '/admin/workers';
  static const adminProductForm = '/admin/new';
  static const adminProductDetail = '/admin/product/:productId';
  static const adminPropertyDefinitions = '/admin/settings/properties';
  static const adminCompanySettings = '/admin/settings/company';
  static const adminPropertyDefinitionForm = '/admin/settings/properties/new';
  static const adminWorkerForm = '/admin/workers/new';
  static const adminOrderDetail = '/admin/order/:orderId';
  static const productionDashboard = '/production';
  static const productionOrders = '/production/orders';
  static const deliveryDashboard = '/delivery';
  static const deliveryOrders = '/delivery/orders';
  static const deliveryWorkOrders = '/delivery/work-orders';
  static const deliveryCustomers = '/delivery/customers';
  static const deliveryOrderDetail = '/delivery/order/:orderId';
  static const deliveryCustomerDetail = '/delivery/customers/:customerId';
  static const deliveryCustomerForm = '/delivery/customers/new';
  static const deliveryCustomerEdit = '/delivery/customers/:customerId/edit';

  static const adminWorkOrders = '/admin/work-orders';

  static String deliveryOrderDetailPath(String orderId) =>
      '/delivery/order/$orderId';

  static String deliveryWorkOrderDetailPath(String orderId) =>
      '/delivery/work-orders/$orderId';

  static String deliveryWorkOrderQuotePath(String orderId) =>
      '/delivery/work-orders/$orderId/quote';

  static String deliveryWorkOrderAgreementPath(String orderId) =>
      '/delivery/work-orders/$orderId/agreement';

  static String deliveryWorkOrderNewPath() => '/delivery/work-orders/new';

  static String adminOrderDetailPath(String orderId) => '/admin/order/$orderId';

  static String adminWorkOrderDetailPath(String orderId) =>
      '/admin/work-orders/$orderId';

  static String adminWorkOrderQuotePath(String orderId) =>
      '/admin/work-orders/$orderId/quote';

  static String adminWorkOrderAgreementPath(String orderId) =>
      '/admin/work-orders/$orderId/agreement';

  static String adminWorkOrderNewPath() => '/admin/work-orders/new';

  static String workOrderCreatePath(String rolePrefix) =>
      '/$rolePrefix/work-orders/new';

  static String workOrderCustomerPickPath(String rolePrefix) =>
      '/$rolePrefix/work-orders/new/pick-customer';

  static String workOrderProductPickPath(String rolePrefix) =>
      '/$rolePrefix/work-orders/pick-product';

  static String workOrderProductDetailPath(
    String rolePrefix,
    String productId,
  ) => '/$rolePrefix/work-orders/product/$productId';

  static String workOrderDetailPath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId';

  static String workOrderQuotePath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId/quote';

  static String workOrderQuoteViewPath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId/quote-view';

  static String workOrderAgreementPath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId/agreement';

  static String workOrderAgreementViewPath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId/agreement-view';

  static String workOrderManufacturingPath(String rolePrefix, String orderId) =>
      '/$rolePrefix/work-orders/$orderId/manufacturing';

  static String workOrderManufacturingCardPath(
    String rolePrefix,
    String orderId,
    String lineId,
    int cardIndex,
  ) => '/$rolePrefix/work-orders/$orderId/manufacturing/line/$lineId/card/$cardIndex';

  static String adminProductEditPath(String productId) =>
      '/admin/product/$productId/edit';

  static String adminProductDetailPath(String productId) =>
      '/admin/product/$productId';

  static String adminWorkerEditPath(String profileId) =>
      '/admin/workers/$profileId/edit';

  static String adminPropertyDefinitionEditPath(String definitionId) =>
      '/admin/settings/properties/$definitionId/edit';

  static String customerDetailPath(String rolePrefix, String customerId) =>
      '/$rolePrefix/customers/$customerId';

  static String customerFormPath(String rolePrefix) =>
      '/$rolePrefix/customers/new';

  static String customerEditPath(String rolePrefix, String customerId) =>
      '/$rolePrefix/customers/$customerId/edit';

  static String homeForRole(UserRole role) => switch (role) {
    UserRole.salesRep => salesDashboard,
    UserRole.admin => adminHome,
    UserRole.productionManager => productionDashboard,
    UserRole.deliveryWorker => deliveryDashboard,
  };

  static UserRole? roleForPath(String path) {
    if (path.startsWith(salesDashboard)) return UserRole.salesRep;
    if (path.startsWith(adminDashboard)) return UserRole.admin;
    if (path.startsWith(productionDashboard)) return UserRole.productionManager;
    if (path.startsWith(deliveryDashboard)) return UserRole.deliveryWorker;
    return null;
  }
}
