import 'package:equatable/equatable.dart';

import 'commercial_order.dart';

const String defaultManufacturingCardAlert = 'تنبيه مهم: الباب لا يشمل دفاش';

String _enOrAr(String arabic, String? english) {
  final en = english?.trim();
  if (en != null && en.isNotEmpty) return en;
  return arabic.trim();
}

class ManufacturingCardProperty extends Equatable {
  const ManufacturingCardProperty({
    required this.id,
    required this.cardId,
    this.definitionId,
    this.valueId,
    required this.nameAr,
    this.nameEn,
    required this.valueAr,
    this.valueEn,
    this.iconKey,
    this.imageUrl,
    required this.sortOrder,
  });

  final String id;
  final String cardId;
  final String? definitionId;
  final String? valueId;
  final String nameAr;
  final String? nameEn;
  final String valueAr;
  final String? valueEn;
  final String? iconKey;
  final String? imageUrl;
  final int sortOrder;

  String get nameEnOrAr => _enOrAr(nameAr, nameEn);

  String get valueEnOrAr => _enOrAr(valueAr, valueEn);

  @override
  List<Object?> get props => [
    id,
    cardId,
    definitionId,
    valueId,
    nameAr,
    nameEn,
    valueAr,
    valueEn,
    iconKey,
    imageUrl,
    sortOrder,
  ];
}

class ManufacturingCard extends Equatable {
  const ManufacturingCard({
    required this.id,
    required this.orderId,
    required this.agreementId,
    this.agreementLineId,
    required this.cardIndex,
    this.productId,
    required this.modelNameAr,
    this.modelNameEn,
    required this.widthCm,
    required this.heightCm,
    this.colorId,
    this.colorNameAr,
    this.colorNameEn,
    this.colorCode,
    this.productImageUrl,
    this.colorImageUrl,
    this.alertNote = defaultManufacturingCardAlert,
    this.notes,
    required this.clientSigned,
    required this.status,
    this.pdfStoragePath,
    required this.sortOrder,
    required this.properties,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderId;
  final String agreementId;
  final String? agreementLineId;
  final int cardIndex;
  final String? productId;
  final String modelNameAr;
  final String? modelNameEn;
  final double widthCm;
  final double heightCm;
  final String? colorId;
  final String? colorNameAr;
  final String? colorNameEn;
  final String? colorCode;
  final String? productImageUrl;
  final String? colorImageUrl;
  final String alertNote;
  final String? notes;
  final bool clientSigned;
  final DocumentIssueStatus status;
  final String? pdfStoragePath;
  final int sortOrder;
  final List<ManufacturingCardProperty> properties;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get modelNameEnOrAr => _enOrAr(modelNameAr, modelNameEn);

  String? get colorNameEnOrAr {
    final ar = colorNameAr?.trim();
    if (ar == null || ar.isEmpty) return null;
    return _enOrAr(ar, colorNameEn);
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    agreementId,
    agreementLineId,
    cardIndex,
    productId,
    modelNameAr,
    modelNameEn,
    widthCm,
    heightCm,
    colorId,
    colorNameAr,
    colorNameEn,
    colorCode,
    productImageUrl,
    colorImageUrl,
    alertNote,
    notes,
    clientSigned,
    status,
    pdfStoragePath,
    sortOrder,
    properties,
    createdAt,
    updatedAt,
  ];
}

class ManufacturingCardPropertyDraft extends Equatable {
  const ManufacturingCardPropertyDraft({
    this.definitionId,
    this.valueId,
    required this.nameAr,
    this.nameEn,
    required this.valueAr,
    this.valueEn,
    this.iconKey,
    this.imageUrl,
    required this.sortOrder,
  });

  final String? definitionId;
  final String? valueId;
  final String nameAr;
  final String? nameEn;
  final String valueAr;
  final String? valueEn;
  final String? iconKey;
  final String? imageUrl;
  final int sortOrder;

  String? get validationError {
    if (nameAr.trim().isEmpty) return 'اسم الخاصية مطلوب';
    if (valueAr.trim().isEmpty) return 'قيمة الخاصية مطلوبة';
    return null;
  }

  @override
  List<Object?> get props => [
    definitionId,
    valueId,
    nameAr,
    nameEn,
    valueAr,
    valueEn,
    iconKey,
    imageUrl,
    sortOrder,
  ];
}

class ManufacturingCardDraft extends Equatable {
  const ManufacturingCardDraft({
    this.cardId,
    required this.agreementLineId,
    required this.cardIndex,
    this.productId,
    required this.modelNameAr,
    this.modelNameEn,
    required this.widthCm,
    required this.heightCm,
    this.colorId,
    this.colorNameAr,
    this.colorNameEn,
    this.colorCode,
    this.productImageUrl,
    this.colorImageUrl,
    this.alertNote = defaultManufacturingCardAlert,
    this.notes,
    this.clientSigned = false,
    this.status = DocumentIssueStatus.draft,
    this.properties = const [],
    this.sortOrder = 0,
  });

  final String? cardId;
  final String agreementLineId;
  final int cardIndex;
  final String? productId;
  final String modelNameAr;
  final String? modelNameEn;
  final double widthCm;
  final double heightCm;
  final String? colorId;
  final String? colorNameAr;
  final String? colorNameEn;
  final String? colorCode;
  final String? productImageUrl;
  final String? colorImageUrl;
  final String alertNote;
  final String? notes;
  final bool clientSigned;
  final DocumentIssueStatus status;
  final List<ManufacturingCardPropertyDraft> properties;
  final int sortOrder;

  bool get isEditing => cardId != null;

  String? get validationError {
    if (modelNameAr.trim().isEmpty) return 'اسم الموديل مطلوب';
    if (widthCm <= 0 || heightCm <= 0) {
      return 'أدخل العرض والارتفاع بالمتر أو السم';
    }
    if (properties.isEmpty) return 'أضف خاصية واحدة على الأقل للباب';
    for (final property in properties) {
      final error = property.validationError;
      if (error != null) return error;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    cardId,
    agreementLineId,
    cardIndex,
    productId,
    modelNameAr,
    modelNameEn,
    widthCm,
    heightCm,
    colorId,
    colorNameAr,
    colorNameEn,
    colorCode,
    productImageUrl,
    colorImageUrl,
    alertNote,
    notes,
    clientSigned,
    status,
    properties,
    sortOrder,
  ];
}

/// Hub slot: one physical door derived from an agreement line × quantity.
class ManufacturingCardSlot extends Equatable {
  const ManufacturingCardSlot({
    required this.agreementLine,
    required this.cardIndex,
    this.existingCard,
  });

  final AgreementLine agreementLine;
  final int cardIndex;
  final ManufacturingCard? existingCard;

  bool get isComplete => existingCard != null;

  String get titleAr {
    final desc = agreementLine.description.trim();
    if (desc.isEmpty) return 'باب $cardIndex';
    return desc;
  }

  @override
  List<Object?> get props => [agreementLine, cardIndex, existingCard];
}

/// Expands agreement lines by quantity into door slots for the hub UI.
List<ManufacturingCardSlot> buildManufacturingCardSlots({
  required OrderAgreement agreement,
  required List<ManufacturingCard> cards,
}) {
  final slots = <ManufacturingCardSlot>[];
  for (final line in agreement.lines) {
    final qty = (line.quantity ?? 1).ceil();
    final unitCount = qty < 1 ? 1 : qty;
    for (var index = 1; index <= unitCount; index++) {
      ManufacturingCard? existing;
      for (final card in cards) {
        if (card.agreementLineId == line.id && card.cardIndex == index) {
          existing = card;
          break;
        }
      }
      slots.add(
        ManufacturingCardSlot(
          agreementLine: line,
          cardIndex: index,
          existingCard: existing,
        ),
      );
    }
  }
  return slots;
}
