import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/entities/orders_list_scope.dart';
import '../../domain/entities/paged_result.dart';

class DeliveryOrdersRemoteDataSource {
  DeliveryOrdersRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _orderSelect =
      'id, order_number, customer_name, customer_phone, customer_address, status, ready_at, delivered_at, delivery_notes';

  Future<PagedResult<DeliveryOrder>> fetchOrdersPage({
    required OrdersListScope scope,
    required int page,
    required int pageSize,
  }) async {
    dbgDelivery('fetchOrdersPage start scope=$scope page=$page');
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      var query = _client.from('manufacturing_orders').select(_orderSelect);

      if (scope == OrdersListScope.deliveryWorker) {
        query = query.eq('status', ManufacturingOrderStatus.ready.dbValue);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final rows = response.data as List<dynamic>;
      final totalCount = response.count;

      final orders = rows
          .map((row) => _mapOrder(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgDelivery(
        'fetchOrdersPage ok scope=$scope count=${orders.length} total=$totalCount',
      );
      return PagedResult(
        items: orders,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'fetchOrdersPage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'fetchOrdersPage unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<DeliveryOrder> markDelivered({
    required String orderId,
    String? deliveryNotes,
  }) async {
    dbgDelivery('markDelivered start orderId=$orderId');
    try {
      final row = await _client
          .from('manufacturing_orders')
          .update({
            'status': ManufacturingOrderStatus.delivered.dbValue,
            'delivered_at': DateTime.now().toUtc().toIso8601String(),
            'delivery_notes': deliveryNotes,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('status', ManufacturingOrderStatus.ready.dbValue)
          .select(_orderSelect)
          .maybeSingle();

      if (row == null) {
        dbgDeliveryError(
          'markDelivered: no row updated (RLS or stale status)',
          data: {'orderId': orderId},
        );
        throw const ServerFailure(
          'تعذر تحديث الطلب — تحقق من الصلاحيات أو حالة الطلب',
        );
      }

      dbgDelivery('markDelivered ok orderId=$orderId');
      return _mapOrder(row);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'markDelivered',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'DeliveryFlow',
        step: 'markDelivered unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  DeliveryOrder _mapOrder(Map<String, dynamic> row) {
    return DeliveryOrder(
      id: row['id'] as String,
      orderNumber: row['order_number'] as String,
      customerName: row['customer_name'] as String,
      customerPhone: (row['customer_phone'] as String?) ?? '',
      customerAddress: (row['customer_address'] as String?) ?? '',
      status: ManufacturingOrderStatus.fromDbValue(row['status'] as String),
      readyAt: row['ready_at'] == null
          ? null
          : DateTime.parse(row['ready_at'] as String),
      deliveredAt: row['delivered_at'] == null
          ? null
          : DateTime.parse(row['delivered_at'] as String),
      deliveryNotes: row['delivery_notes'] as String?,
    );
  }
}
