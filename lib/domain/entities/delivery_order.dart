import 'package:equatable/equatable.dart';

enum ManufacturingOrderStatus {
  pending,
  inProduction,
  ready,
  delivered;

  static ManufacturingOrderStatus fromDbValue(String value) {
    return switch (value) {
      'pending' => ManufacturingOrderStatus.pending,
      'inProduction' => ManufacturingOrderStatus.inProduction,
      'ready' => ManufacturingOrderStatus.ready,
      'delivered' => ManufacturingOrderStatus.delivered,
      _ => throw ArgumentError('Unknown status: $value'),
    };
  }
}

extension ManufacturingOrderStatusX on ManufacturingOrderStatus {
  String get dbValue => switch (this) {
    ManufacturingOrderStatus.pending => 'pending',
    ManufacturingOrderStatus.inProduction => 'inProduction',
    ManufacturingOrderStatus.ready => 'ready',
    ManufacturingOrderStatus.delivered => 'delivered',
  };

  String get arabicLabel => switch (this) {
    ManufacturingOrderStatus.pending => 'أوامر جديدة',
    ManufacturingOrderStatus.inProduction => 'قيد التصنيع',
    ManufacturingOrderStatus.ready => 'جاهزة للتسليم',
    ManufacturingOrderStatus.delivered => 'تم تسليمها',
  };
}

class DeliveryOrder extends Equatable {
  const DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.status,
    this.readyAt,
    this.deliveredAt,
    this.deliveryNotes,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final ManufacturingOrderStatus status;
  final DateTime? readyAt;
  final DateTime? deliveredAt;
  final String? deliveryNotes;

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    customerName,
    customerPhone,
    customerAddress,
    status,
    readyAt,
    deliveredAt,
    deliveryNotes,
  ];
}
