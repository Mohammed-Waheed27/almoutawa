import 'package:equatable/equatable.dart';

import 'user_role.dart';

enum CustomerType {
  individual,
  company;

  static CustomerType fromDbValue(String value) => switch (value) {
    'individual' => CustomerType.individual,
    'company' => CustomerType.company,
    _ => throw ArgumentError('Unknown customer type: $value'),
  };
}

extension CustomerTypeX on CustomerType {
  String get dbValue => switch (this) {
    CustomerType.individual => 'individual',
    CustomerType.company => 'company',
  };

  String get arabicLabel => switch (this) {
    CustomerType.individual => 'فرد',
    CustomerType.company => 'مؤسسة',
  };
}

enum LedgerEntryType {
  debit,
  credit;

  static LedgerEntryType fromDbValue(String value) => switch (value) {
    'debit' => LedgerEntryType.debit,
    'credit' => LedgerEntryType.credit,
    _ => throw ArgumentError('Unknown ledger entry type: $value'),
  };
}

extension LedgerEntryTypeX on LedgerEntryType {
  String get dbValue => switch (this) {
    LedgerEntryType.debit => 'debit',
    LedgerEntryType.credit => 'credit',
  };

  String get arabicLabel => switch (this) {
    LedgerEntryType.debit => 'مدين',
    LedgerEntryType.credit => 'دائن',
  };
}

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.customerNumber,
    required this.type,
    this.fullName,
    this.phone,
    this.address,
    this.governorate,
    this.companyName,
    this.responsiblePerson,
    this.commercialRegister,
    this.notes,
    required this.createdByProfileId,
    this.createdByDisplayName,
    this.createdByRoleLabel,
    this.assignedSalesRepId,
    required this.accountBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int customerNumber;
  final CustomerType type;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? governorate;
  final String? companyName;
  final String? responsiblePerson;
  final String? commercialRegister;
  final String? notes;
  final String createdByProfileId;
  final String? createdByDisplayName;
  final String? createdByRoleLabel;
  final String? assignedSalesRepId;
  final double accountBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => switch (type) {
    CustomerType.individual => fullName ?? '—',
    CustomerType.company => companyName ?? '—',
  };

  String get primaryPhone => phone ?? '—';

  bool canEdit(UserSession session) => switch (session.role) {
    UserRole.admin => true,
    UserRole.salesRep =>
      createdByProfileId == session.profileId ||
          assignedSalesRepId == session.profileId,
    UserRole.deliveryWorker => createdByProfileId == session.profileId,
    UserRole.productionManager => false,
  };

  @override
  List<Object?> get props => [
    id,
    customerNumber,
    type,
    fullName,
    phone,
    address,
    governorate,
    companyName,
    responsiblePerson,
    commercialRegister,
    notes,
    createdByProfileId,
    createdByDisplayName,
    createdByRoleLabel,
    assignedSalesRepId,
    accountBalance,
    createdAt,
    updatedAt,
  ];
}

class CustomerAccountEntry extends Equatable {
  const CustomerAccountEntry({
    required this.id,
    required this.customerId,
    required this.entryType,
    required this.amount,
    required this.description,
    required this.occurredAt,
    this.commercialOrderId,
    this.orderNumber,
    this.collectedByProfileId,
    this.collectedByName,
    this.entryKind,
  });

  final String id;
  final String customerId;
  final LedgerEntryType entryType;
  final double amount;
  final String description;
  final DateTime occurredAt;
  final String? commercialOrderId;
  final String? orderNumber;
  final String? collectedByProfileId;
  final String? collectedByName;
  final String? entryKind;

  @override
  List<Object?> get props => [
    id,
    customerId,
    entryType,
    amount,
    description,
    occurredAt,
    commercialOrderId,
    orderNumber,
    collectedByProfileId,
    collectedByName,
    entryKind,
  ];
}

class CustomerDraft extends Equatable {
  const CustomerDraft({
    required this.type,
    this.fullName,
    this.phone,
    this.address,
    this.governorate,
    this.companyName,
    this.responsiblePerson,
    this.commercialRegister,
    this.notes,
  });

  final CustomerType type;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? governorate;
  final String? companyName;
  final String? responsiblePerson;
  final String? commercialRegister;
  final String? notes;

  String? get validationError {
    if (type == CustomerType.individual) {
      if (fullName == null || fullName!.trim().isEmpty) {
        return 'اسم العميل مطلوب';
      }
    } else {
      if (companyName == null || companyName!.trim().isEmpty) {
        return 'اسم المؤسسة مطلوب';
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    type,
    fullName,
    phone,
    address,
    governorate,
    companyName,
    responsiblePerson,
    commercialRegister,
    notes,
  ];
}
