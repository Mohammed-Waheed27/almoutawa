import 'package:equatable/equatable.dart';

/// Application user roles — operational parties.
enum UserRole {
  /// Sales representative (مندوب مبيعات).
  salesRep,

  /// System administrator (مدير النظام).
  admin,

  /// Factory operations manager (مدير التشغيل).
  productionManager,

  /// Field delivery worker (مندوب تسليم).
  deliveryWorker;

  static UserRole fromDbValue(String value) {
    return switch (value) {
      'sales_rep' => UserRole.salesRep,
      'admin' => UserRole.admin,
      'production_manager' => UserRole.productionManager,
      'delivery_worker' => UserRole.deliveryWorker,
      _ => throw ArgumentError('Unknown role: $value'),
    };
  }
}

extension UserRoleX on UserRole {
  String get arabicLabel => switch (this) {
    UserRole.salesRep => 'مندوب مبيعات',
    UserRole.admin => 'مدير النظام',
    UserRole.productionManager => 'مدير التشغيل',
    UserRole.deliveryWorker => 'مندوب تسليم',
  };

  String get routeName => switch (this) {
    UserRole.salesRep => 'sales',
    UserRole.admin => 'admin',
    UserRole.productionManager => 'production',
    UserRole.deliveryWorker => 'delivery',
  };

  String get dbValue => switch (this) {
    UserRole.salesRep => 'sales_rep',
    UserRole.admin => 'admin',
    UserRole.productionManager => 'production_manager',
    UserRole.deliveryWorker => 'delivery_worker',
  };
}

/// Minimal session snapshot for routing and auth flows.
class UserSession extends Equatable {
  const UserSession({
    required this.userId,
    required this.profileId,
    required this.displayName,
    required this.role,
  });

  final String userId;
  final String profileId;
  final String displayName;
  final UserRole role;

  @override
  List<Object?> get props => [userId, profileId, displayName, role];
}
