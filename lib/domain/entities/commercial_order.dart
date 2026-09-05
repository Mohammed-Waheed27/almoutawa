import 'package:equatable/equatable.dart';

import 'factory_profile.dart';

const double defaultVatRate = 0.15;

const String defaultQuoteOtherCommentsText =
    '• العرض صالح لمدة 7 أيام\n'
    '• مدة التصنيع 45 يوم عمل من تاريخ اعتماد المخطط والدفعة المقدمة\n'
    '• شروط الدفع: 50% عند الاتفاق، 50% قبل التسليم\n'
    '• البنك الأهلي السعودي، الحساب باسم: ورشة محمد ياسين المطاوعة للحدادة\n'
    '• IBAN: SA0910000001400007101301\n'
    '• ملاحظة: يتم احتساب السعر النهائي حسب المقاسات النهائية بعد التركيب\n'
    '• النقل خارج نطاق الدمام غير مشمول في العرض\n'
    '• الكالونات والمقابض والإكسسوارات من مسؤولية العميل ما لم يُذكر خلاف ذلك';

double _round2(double value) => double.parse(value.toStringAsFixed(2));

enum CommercialOrderPhase {
  quote,
  agreement,
  manufacturingDraft,
  manufacturing,
  completed,
  delivered,
  cancelled;

  static CommercialOrderPhase fromDbValue(String value) => switch (value) {
    'quote' => CommercialOrderPhase.quote,
    'agreement' => CommercialOrderPhase.agreement,
    'manufacturing_draft' => CommercialOrderPhase.manufacturingDraft,
    'manufacturing' => CommercialOrderPhase.manufacturing,
    'completed' => CommercialOrderPhase.completed,
    'delivered' => CommercialOrderPhase.delivered,
    'cancelled' => CommercialOrderPhase.cancelled,
    _ => CommercialOrderPhase.quote,
  };
}

extension CommercialOrderPhaseX on CommercialOrderPhase {
  String get dbValue => switch (this) {
    CommercialOrderPhase.quote => 'quote',
    CommercialOrderPhase.agreement => 'agreement',
    CommercialOrderPhase.manufacturingDraft => 'manufacturing_draft',
    CommercialOrderPhase.manufacturing => 'manufacturing',
    CommercialOrderPhase.completed => 'completed',
    CommercialOrderPhase.delivered => 'delivered',
    CommercialOrderPhase.cancelled => 'cancelled',
  };

  String get arabicLabel => switch (this) {
    CommercialOrderPhase.quote => 'عرض سعر',
    CommercialOrderPhase.agreement => 'اتفاقية',
    CommercialOrderPhase.manufacturingDraft => 'مسودة تصنيع',
    CommercialOrderPhase.manufacturing => 'قيد التصنيع',
    CommercialOrderPhase.completed => 'مكتمل التصنيع',
    CommercialOrderPhase.delivered => 'تم التسليم',
    CommercialOrderPhase.cancelled => 'ملغي',
  };

  bool get isActive =>
      this == CommercialOrderPhase.quote ||
      this == CommercialOrderPhase.agreement ||
      this == CommercialOrderPhase.manufacturingDraft ||
      this == CommercialOrderPhase.manufacturing;

  bool get isFinished =>
      this == CommercialOrderPhase.completed ||
      this == CommercialOrderPhase.delivered ||
      this == CommercialOrderPhase.cancelled;
}

class DocumentExtraCharge extends Equatable {
  const DocumentExtraCharge({
    this.id,
    required this.name,
    required this.amount,
    this.sortOrder = 0,
  });

  final String? id;
  final String name;
  final double amount;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, amount, sortOrder];
}

class DocumentFinance {
  const DocumentFinance._();

  static double taxableBase({
    required double linesSubtotal,
    required double extrasTotal,
  }) => _round2(linesSubtotal + extrasTotal);

  static double vatAmount({
    required double taxable,
    required double vatRate,
  }) => _round2(taxable * vatRate);

  /// Discount is subtracted from the taxed total.
  static double grandTotal({
    required double taxable,
    required double vatAmount,
    required double discountAmount,
  }) {
    final total = taxable + vatAmount - discountAmount;
    return _round2(total < 0 ? 0 : total);
  }
}

enum DocumentIssueStatus {
  draft,
  issued;

  static DocumentIssueStatus fromDbValue(String value) => switch (value) {
    'draft' => DocumentIssueStatus.draft,
    'issued' => DocumentIssueStatus.issued,
    _ => throw ArgumentError('Unknown DocumentIssueStatus: $value'),
  };
}

extension DocumentIssueStatusX on DocumentIssueStatus {
  String get dbValue => switch (this) {
    DocumentIssueStatus.draft => 'draft',
    DocumentIssueStatus.issued => 'issued',
  };

  String get arabicLabel => switch (this) {
    DocumentIssueStatus.draft => 'مسودة',
    DocumentIssueStatus.issued => 'صادر',
  };
}

class CommercialOrder extends Equatable {
  const CommercialOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.factoryId,
    required this.createdByProfileId,
    required this.phase,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final String? factoryId;
  final String createdByProfileId;
  final CommercialOrderPhase phase;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    customerId,
    factoryId,
    createdByProfileId,
    phase,
    notes,
    createdAt,
    updatedAt,
  ];
}

class CommercialOrderCreatorSnapshot extends Equatable {
  const CommercialOrderCreatorSnapshot({
    required this.displayName,
    required this.roleDbValue,
    required this.roleLabelAr,
  });

  final String displayName;
  final String roleDbValue;
  final String roleLabelAr;

  @override
  List<Object?> get props => [displayName, roleDbValue, roleLabelAr];
}

class CommercialOrderCustomerSnapshot extends Equatable {
  const CommercialOrderCustomerSnapshot({
    required this.id,
    required this.customerNumber,
    required this.typeDbValue,
    required this.displayName,
    this.phone,
    this.address,
    this.governorate,
  });

  final String id;
  final int customerNumber;
  final String typeDbValue;
  final String displayName;
  final String? phone;
  final String? address;
  final String? governorate;

  @override
  List<Object?> get props => [
    id,
    customerNumber,
    typeDbValue,
    displayName,
    phone,
    address,
    governorate,
  ];
}

class CommercialOrderSummary extends Equatable {
  const CommercialOrderSummary({
    required this.order,
    required this.customer,
    this.quoteStatus,
    this.agreementStatus,
  });

  final CommercialOrder order;
  final CommercialOrderCustomerSnapshot customer;
  final DocumentIssueStatus? quoteStatus;
  final DocumentIssueStatus? agreementStatus;

  @override
  List<Object?> get props => [order, customer, quoteStatus, agreementStatus];
}

class QuoteLine extends Equatable {
  const QuoteLine({
    required this.id,
    required this.orderQuoteId,
    this.productId,
    required this.description,
    required this.widthCm,
    required this.heightCm,
    required this.areaM2,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.sortOrder,
  });

  final String id;
  final String orderQuoteId;
  final String? productId;
  final String description;
  final double widthCm;
  final double heightCm;
  final double areaM2;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    orderQuoteId,
    productId,
    description,
    widthCm,
    heightCm,
    areaM2,
    quantity,
    unitPrice,
    lineTotal,
    sortOrder,
  ];
}

class OrderQuote extends Equatable {
  const OrderQuote({
    required this.id,
    required this.commercialOrderId,
    required this.quoteNumber,
    required this.quoteDate,
    required this.specsDescription,
    required this.otherComments,
    required this.discountPercent,
    this.discountAmount = 0,
    this.extrasTotal = 0,
    this.extraCharges = const [],
    this.manufacturingDurationDays,
    required this.subtotal,
    required this.amountAfterDiscount,
    required this.vatRate,
    required this.vatAmount,
    required this.grandTotal,
    this.totalInWords,
    required this.status,
    this.pdfStoragePath,
    required this.lines,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String commercialOrderId;
  final int quoteNumber;
  final DateTime quoteDate;
  final String specsDescription;
  final String otherComments;
  final double discountPercent;
  final double discountAmount;
  final double extrasTotal;
  final List<DocumentExtraCharge> extraCharges;
  final int? manufacturingDurationDays;
  final double subtotal;
  final double amountAfterDiscount;
  final double vatRate;
  final double vatAmount;
  final double grandTotal;
  final String? totalInWords;
  final DocumentIssueStatus status;
  final String? pdfStoragePath;
  final List<QuoteLine> lines;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get resolvedDiscountAmount {
    if (discountAmount > 0) return discountAmount;
    if (discountPercent <= 0) return 0;
    return _round2(subtotal * (discountPercent.clamp(0, 100) / 100));
  }

  @override
  List<Object?> get props => [
    id,
    commercialOrderId,
    quoteNumber,
    quoteDate,
    specsDescription,
    otherComments,
    discountPercent,
    discountAmount,
    extrasTotal,
    extraCharges,
    manufacturingDurationDays,
    subtotal,
    amountAfterDiscount,
    vatRate,
    vatAmount,
    grandTotal,
    totalInWords,
    status,
    pdfStoragePath,
    lines,
    createdAt,
    updatedAt,
  ];
}

class AgreementLine extends Equatable {
  const AgreementLine({
    required this.id,
    required this.agreementId,
    this.productId,
    required this.description,
    this.quantity,
    this.color,
    this.widthCm,
    this.heightCm,
    required this.unitPrice,
    this.notes,
    required this.sortOrder,
  });

  final String id;
  final String agreementId;
  final String? productId;
  final String description;
  final double? quantity;
  final String? color;
  final double? widthCm;
  final double? heightCm;
  final double unitPrice;
  final String? notes;
  final int sortOrder;

  double get areaM2 {
    final w = widthCm;
    final h = heightCm;
    if (w == null || h == null) return 0;
    return _round2((w / 100) * (h / 100));
  }

  double get lineTotal {
    final qty = quantity ?? 1;
    return _round2(areaM2 * qty * unitPrice);
  }

  @override
  List<Object?> get props => [
    id,
    agreementId,
    productId,
    description,
    quantity,
    color,
    widthCm,
    heightCm,
    unitPrice,
    notes,
    sortOrder,
  ];
}

class OrderAgreement extends Equatable {
  const OrderAgreement({
    required this.id,
    required this.commercialOrderId,
    required this.agreementNumber,
    required this.agreementDate,
    this.clientCity,
    this.clientVatNumber,
    this.manufacturingDays,
    required this.downPayment,
    this.receiptReference,
    this.discountAmount = 0,
    this.extrasTotal = 0,
    this.extraCharges = const [],
    required this.subtotal,
    required this.vatRate,
    required this.vatAmount,
    required this.grandTotal,
    required this.status,
    this.pdfStoragePath,
    this.termsSnapshot,
    required this.lines,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String commercialOrderId;
  final int agreementNumber;
  final DateTime agreementDate;
  final String? clientCity;
  final String? clientVatNumber;
  final int? manufacturingDays;
  final double downPayment;
  final String? receiptReference;
  final double discountAmount;
  final double extrasTotal;
  final List<DocumentExtraCharge> extraCharges;
  final double subtotal;
  final double vatRate;
  final double vatAmount;
  final double grandTotal;
  final DocumentIssueStatus status;
  final String? pdfStoragePath;
  final String? termsSnapshot;
  final List<AgreementLine> lines;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    commercialOrderId,
    agreementNumber,
    agreementDate,
    clientCity,
    clientVatNumber,
    manufacturingDays,
    downPayment,
    receiptReference,
    discountAmount,
    extrasTotal,
    extraCharges,
    subtotal,
    vatRate,
    vatAmount,
    grandTotal,
    status,
    pdfStoragePath,
    termsSnapshot,
    lines,
    createdAt,
    updatedAt,
  ];
}

class CommercialOrderDetail extends Equatable {
  const CommercialOrderDetail({
    required this.order,
    required this.customer,
    this.factory,
    this.quote,
    this.agreement,
    this.createdBy,
  });

  final CommercialOrder order;
  final CommercialOrderCustomerSnapshot customer;
  final FactoryProfile? factory;
  final OrderQuote? quote;
  final OrderAgreement? agreement;
  final CommercialOrderCreatorSnapshot? createdBy;

  @override
  List<Object?> get props => [
    order,
    customer,
    factory,
    quote,
    agreement,
    createdBy,
  ];
}

class CreateCommercialOrderInput extends Equatable {
  const CreateCommercialOrderInput({
    required this.customerId,
    this.factoryId,
    this.notes,
  });

  final String customerId;
  final String? factoryId;
  final String? notes;

  @override
  List<Object?> get props => [customerId, factoryId, notes];
}

class QuoteLineDraft extends Equatable {
  const QuoteLineDraft({
    this.productId,
    required this.description,
    required this.widthCm,
    required this.heightCm,
    required this.quantity,
    required this.unitPrice,
    required this.sortOrder,
  });

  final String? productId;
  final String description;
  final double widthCm;
  final double heightCm;
  final int quantity;
  final double unitPrice;
  final int sortOrder;

  double get areaM2 => _round2((widthCm / 100) * (heightCm / 100));
  double get lineTotal => _round2(areaM2 * quantity * unitPrice);

  @override
  List<Object?> get props => [
    productId,
    description,
    widthCm,
    heightCm,
    quantity,
    unitPrice,
    sortOrder,
  ];
}

class QuoteDraft extends Equatable {
  const QuoteDraft({
    required this.quoteDate,
    this.specsDescription,
    this.otherComments = defaultQuoteOtherCommentsText,
    this.discountAmount = 0,
    this.vatRate = defaultVatRate,
    this.manufacturingDurationDays,
    this.extraCharges = const [],
    this.status = DocumentIssueStatus.draft,
    required this.lines,
  });

  final DateTime quoteDate;
  final String? specsDescription;
  final String otherComments;
  final double discountAmount;
  final double vatRate;
  final int? manufacturingDurationDays;
  final List<DocumentExtraCharge> extraCharges;
  final DocumentIssueStatus status;
  final List<QuoteLineDraft> lines;

  double get subtotal =>
      _round2(lines.fold<double>(0, (sum, line) => sum + line.lineTotal));

  double get extrasTotal =>
      _round2(extraCharges.fold<double>(0, (sum, item) => sum + item.amount));

  double get taxableBase => DocumentFinance.taxableBase(
    linesSubtotal: subtotal,
    extrasTotal: extrasTotal,
  );

  double get amountAfterDiscount => taxableBase;

  double get vatAmount =>
      DocumentFinance.vatAmount(taxable: taxableBase, vatRate: vatRate);

  double get grandTotal => DocumentFinance.grandTotal(
    taxable: taxableBase,
    vatAmount: vatAmount,
    discountAmount: discountAmount,
  );

  String? get validationError {
    if (lines.isEmpty) return 'أضف بنداً واحداً على الأقل في عرض السعر';
    for (final line in lines) {
      if (line.description.trim().isEmpty) return 'وصف البند مطلوب';
      if (line.widthCm <= 0 || line.heightCm <= 0) {
        return 'أدخل العرض والارتفاع لكل بند';
      }
      if (line.quantity <= 0) return 'الكمية يجب أن تكون أكبر من صفر';
      if (line.unitPrice < 0) return 'سعر المتر غير صالح';
    }
    for (final extra in extraCharges) {
      if (extra.name.trim().isEmpty) return 'اسم المصروف الإضافي مطلوب';
      if (extra.amount < 0) return 'قيمة المصروف الإضافي غير صالحة';
    }
    if (discountAmount < 0) return 'قيمة الخصم غير صالحة';
    if (discountAmount > taxableBase + vatAmount) {
      return 'الخصم أكبر من إجمالي العرض بعد الضريبة';
    }
    if (manufacturingDurationDays != null && manufacturingDurationDays! <= 0) {
      return 'مدة التصنيع يجب أن تكون أكبر من صفر';
    }
    return null;
  }

  @override
  List<Object?> get props => [
    quoteDate,
    specsDescription,
    otherComments,
    discountAmount,
    vatRate,
    manufacturingDurationDays,
    extraCharges,
    status,
    lines,
  ];
}

class AgreementLineDraft extends Equatable {
  const AgreementLineDraft({
    this.productId,
    required this.description,
    this.quantity,
    this.color,
    this.widthCm,
    this.heightCm,
    required this.unitPrice,
    this.notes,
    required this.sortOrder,
  });

  final String? productId;
  final String description;
  final double? quantity;
  final String? color;
  final double? widthCm;
  final double? heightCm;
  final double unitPrice;
  final String? notes;
  final int sortOrder;

  double get areaM2 {
    final w = widthCm;
    final h = heightCm;
    if (w == null || h == null) return 0;
    return _round2((w / 100) * (h / 100));
  }

  double get lineTotal {
    final qty = quantity ?? 1;
    return _round2(areaM2 * qty * unitPrice);
  }

  String? get validationError {
    if (description.trim().isEmpty) return 'وصف البند مطلوب';
    if (widthCm == null ||
        widthCm! <= 0 ||
        heightCm == null ||
        heightCm! <= 0) {
      return 'أدخل العرض والارتفاع لكل بند';
    }
    if (quantity == null || quantity! <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    if (unitPrice < 0) return 'سعر المتر غير صالح';
    return null;
  }

  @override
  List<Object?> get props => [
    productId,
    description,
    quantity,
    color,
    widthCm,
    heightCm,
    unitPrice,
    notes,
    sortOrder,
  ];
}

class AgreementDraft extends Equatable {
  const AgreementDraft({
    required this.agreementDate,
    this.clientCity,
    this.clientVatNumber,
    this.manufacturingDays,
    this.downPayment = 0,
    this.receiptReference,
    this.discountAmount = 0,
    this.vatRate = defaultVatRate,
    this.extraCharges = const [],
    required this.lines,
  });

  final DateTime agreementDate;
  final String? clientCity;
  final String? clientVatNumber;
  final int? manufacturingDays;
  final double downPayment;
  final String? receiptReference;
  final double discountAmount;
  final double vatRate;
  final List<DocumentExtraCharge> extraCharges;
  final List<AgreementLineDraft> lines;

  double get subtotal =>
      _round2(lines.fold<double>(0, (sum, line) => sum + line.lineTotal));

  double get extrasTotal =>
      _round2(extraCharges.fold<double>(0, (sum, item) => sum + item.amount));

  double get taxableBase => DocumentFinance.taxableBase(
    linesSubtotal: subtotal,
    extrasTotal: extrasTotal,
  );

  double get vatAmount =>
      DocumentFinance.vatAmount(taxable: taxableBase, vatRate: vatRate);

  double get grandTotal => DocumentFinance.grandTotal(
    taxable: taxableBase,
    vatAmount: vatAmount,
    discountAmount: discountAmount,
  );

  String? get validationError {
    if (lines.isEmpty) return 'أضف بنداً واحداً على الأقل';
    for (final line in lines) {
      final err = line.validationError;
      if (err != null) return err;
    }
    for (final extra in extraCharges) {
      if (extra.name.trim().isEmpty) return 'اسم المصروف الإضافي مطلوب';
      if (extra.amount < 0) return 'قيمة المصروف الإضافي غير صالحة';
    }
    if (discountAmount < 0) return 'قيمة الخصم غير صالحة';
    if (downPayment < 0) return 'الدفعة المقدمة غير صالحة';
    if (manufacturingDays != null && manufacturingDays! <= 0) {
      return 'مدة التصنيع يجب أن تكون أكبر من صفر';
    }
    return null;
  }

  @override
  List<Object?> get props => [
    agreementDate,
    clientCity,
    clientVatNumber,
    manufacturingDays,
    downPayment,
    receiptReference,
    discountAmount,
    vatRate,
    extraCharges,
    lines,
  ];
}

class SaveQuoteInput extends Equatable {
  const SaveQuoteInput({required this.orderId, required this.draft});

  final String orderId;
  final QuoteDraft draft;

  @override
  List<Object?> get props => [orderId, draft];
}

class SaveAgreementInput extends Equatable {
  const SaveAgreementInput({required this.orderId, required this.draft});

  final String orderId;
  final AgreementDraft draft;

  @override
  List<Object?> get props => [orderId, draft];
}
