import '../utils/pretty_logger.dart';

void dbgAuth(String message) {
  PrettyLogger.info(message, tag: 'AuthFlow');
}

void dbgAuthError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'AuthFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}

void dbgDelivery(String message) {
  PrettyLogger.info(message, tag: 'DeliveryFlow');
}

void dbgDeliveryError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'DeliveryFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}

void dbgCustomers(String message) {
  PrettyLogger.info(message, tag: 'CustomersFlow');
}

void dbgCustomersError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'CustomersFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}

void dbgAdmin(String message) {
  PrettyLogger.info(message, tag: 'AdminFlow');
}

void dbgAdminError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'AdminFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}

void dbgProducts(String message) {
  PrettyLogger.info(message, tag: 'ProductsFlow');
}

void dbgProductsError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'ProductsFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}

void dbgWorkOrders(String message) {
  PrettyLogger.info(message, tag: 'WorkOrdersFlow');
}

void dbgWorkOrdersError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Object? data,
}) {
  PrettyLogger.error(
    message,
    tag: 'WorkOrdersFlow',
    error: error,
    stackTrace: stackTrace,
    data: data,
  );
}
