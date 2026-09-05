import 'package:equatable/equatable.dart';

import 'user_role.dart';

class StaffProfile extends Equatable {
  const StaffProfile({
    required this.id,
    required this.userId,
    required this.role,
    required this.displayName,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final UserRole role;
  final String displayName;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    role,
    displayName,
    email,
    phone,
    isActive,
    createdAt,
  ];
}

class StaffProfileDraft extends Equatable {
  const StaffProfileDraft({
    required this.displayName,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
  });

  final String displayName;
  final String email;
  final String password;
  final UserRole role;
  final String? phone;

  String? get validationError {
    if (displayName.trim().isEmpty) {
      return role == UserRole.productionManager
          ? 'اسم مدير التشغيل مطلوب'
          : 'اسم المندوب مطلوب';
    }
    if (email.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    if (password.trim().length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (role != UserRole.deliveryWorker && role != UserRole.productionManager) {
      return 'دور غير مدعوم';
    }
    return null;
  }

  @override
  List<Object?> get props => [displayName, email, password, role, phone];
}

class StaffProfileUpdateDraft extends Equatable {
  const StaffProfileUpdateDraft({required this.displayName, this.phone});

  final String displayName;
  final String? phone;

  String? get validationError {
    if (displayName.trim().isEmpty) return 'الاسم مطلوب';
    return null;
  }

  @override
  List<Object?> get props => [displayName, phone];
}

const staffPageSize = 20;
