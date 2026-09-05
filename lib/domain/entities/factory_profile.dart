import 'package:equatable/equatable.dart';

class FactoryProfile extends Equatable {
  const FactoryProfile({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.shortNameAr,
    required this.shortNameEn,
    this.addressAr,
    this.addressEn,
    this.phone,
    this.mobile,
    required this.website,
    required this.instagram,
    this.vatNumber,
    this.commercialRegister,
    this.bankName,
    this.bankAccountName,
    this.iban,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// Compact label for pickers (keeps full [nameAr] for PDF letterhead).
  final String shortNameAr;
  final String shortNameEn;
  final String? addressAr;
  final String? addressEn;
  final String? phone;
  final String? mobile;
  final String website;
  final String instagram;
  final String? vatNumber;
  final String? commercialRegister;
  final String? bankName;
  final String? bankAccountName;
  final String? iban;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// UI picker label — short name with 2-line wrap support in widgets.
  String get displayName => shortNameAr.trim().isEmpty ? nameAr : shortNameAr;

  String get addressLine => addressAr ?? addressEn ?? '—';

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    shortNameAr,
    shortNameEn,
    addressAr,
    addressEn,
    phone,
    mobile,
    website,
    instagram,
    vatNumber,
    commercialRegister,
    bankName,
    bankAccountName,
    iban,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
