import 'package:equatable/equatable.dart';

class CompanyContactPhone extends Equatable {
  const CompanyContactPhone({
    required this.id,
    required this.label,
    required this.phone,
    required this.sortOrder,
    required this.showOnPdf,
  });

  final String id;
  final String label;
  final String phone;
  final int sortOrder;
  final bool showOnPdf;

  @override
  List<Object?> get props => [id, label, phone, sortOrder, showOnPdf];
}

class CompanySettings extends Equatable {
  const CompanySettings({
    required this.vatRate,
    required this.phones,
    this.agreementTermsAr = '',
  });

  /// Stored as a fraction (0.15 = 15%).
  final double vatRate;
  final List<CompanyContactPhone> phones;
  final String agreementTermsAr;

  double get vatPercent => vatRate * 100;

  List<CompanyContactPhone> get pdfPhones =>
      phones.where((phone) => phone.showOnPdf).toList(growable: false);

  @override
  List<Object?> get props => [vatRate, phones, agreementTermsAr];
}

class CompanyContactPhoneDraft extends Equatable {
  const CompanyContactPhoneDraft({
    this.id,
    required this.label,
    required this.phone,
    this.sortOrder = 0,
    this.showOnPdf = true,
  });

  final String? id;
  final String label;
  final String phone;
  final int sortOrder;
  final bool showOnPdf;

  String? get validationError {
    if (label.trim().isEmpty) return 'وصف الرقم مطلوب';
    if (phone.trim().isEmpty) return 'رقم الهاتف مطلوب';
    return null;
  }

  @override
  List<Object?> get props => [id, label, phone, sortOrder, showOnPdf];
}
