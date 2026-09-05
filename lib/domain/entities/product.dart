import 'package:equatable/equatable.dart';

import 'form_media_item.dart';
import 'local_media_pick.dart';
import 'product_property.dart';

class ProductMediaAsset extends Equatable {
  const ProductMediaAsset({
    required this.id,
    required this.storagePath,
    required this.publicUrl,
    required this.fileSizeBytes,
    required this.sortOrder,
  });

  final String id;
  final String storagePath;
  final String publicUrl;
  final int fileSizeBytes;
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    storagePath,
    publicUrl,
    fileSizeBytes,
    sortOrder,
  ];
}

enum ProductPricingUnit {
  meter,
  piece;

  static ProductPricingUnit fromDbValue(String value) => switch (value) {
    'meter' => ProductPricingUnit.meter,
    'piece' => ProductPricingUnit.piece,
    _ => throw ArgumentError('Unknown pricing unit: $value'),
  };
}

extension ProductPricingUnitX on ProductPricingUnit {
  String get dbValue => switch (this) {
    ProductPricingUnit.meter => 'meter',
    ProductPricingUnit.piece => 'piece',
  };

  String get arabicLabel => switch (this) {
    ProductPricingUnit.meter => 'بالسعر للمتر',
    ProductPricingUnit.piece => 'بالسعر للقطعة',
  };

  String get shortLabel => switch (this) {
    ProductPricingUnit.meter => 'متر',
    ProductPricingUnit.piece => 'قطعة',
  };
}

class ProductColor extends Equatable {
  const ProductColor({
    required this.id,
    required this.productId,
    required this.name,
    this.nameEn,
    this.hexCode,
    this.colorImageUrl,
    required this.images,
    required this.sortOrder,
  });

  final String id;
  final String productId;

  /// Arabic color name (mandatory).
  final String name;

  /// Optional English; falls back to [name] when empty.
  final String? nameEn;
  final String? hexCode;
  final String? colorImageUrl;
  final List<ProductMediaAsset> images;
  final int sortOrder;

  String get nameEnOrAr {
    final en = nameEn?.trim();
    if (en != null && en.isNotEmpty) return en;
    return name;
  }

  String? get coverImageUrl =>
      images.isNotEmpty ? images.first.publicUrl : colorImageUrl;

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    nameEn,
    hexCode,
    colorImageUrl,
    images,
    sortOrder,
  ];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.imageUrl,
    required this.unitPrice,
    required this.pricingUnit,
    required this.images,
    required this.colors,
    this.properties = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Arabic product name (mandatory).
  final String name;

  /// Optional English; manufacturing card / PDF fall back to [name].
  final String? nameEn;
  final String? description;
  final String? imageUrl;
  final double unitPrice;
  final ProductPricingUnit pricingUnit;
  final List<ProductMediaAsset> images;
  final List<ProductColor> colors;
  final List<ProductPropertyAssignment> properties;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get nameEnOrAr {
    final en = nameEn?.trim();
    if (en != null && en.isNotEmpty) return en;
    return name;
  }

  String get priceLabel => unitPrice <= 0
      ? 'السعر غير محدد'
      : '${unitPrice.toStringAsFixed(0)} ج.م / ${pricingUnit.shortLabel}';

  String? get coverImageUrl =>
      images.isNotEmpty ? images.first.publicUrl : imageUrl;

  int get propertyCount => properties.length;

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    description,
    imageUrl,
    unitPrice,
    pricingUnit,
    images,
    colors,
    properties,
    createdAt,
    updatedAt,
  ];
}

class ProductColorDraft extends Equatable {
  const ProductColorDraft({
    this.remoteColorId,
    required this.name,
    this.nameEn,
    this.hexCode,
    this.images = const [],
  });

  final String? remoteColorId;
  final String name;
  final String? nameEn;
  final String? hexCode;
  final List<FormMediaItem> images;

  String? get validationError {
    if (name.trim().isEmpty) return 'اسم اللون بالعربية مطلوب';
    if (hexCode != null &&
        hexCode!.trim().isNotEmpty &&
        !_isValidHex(hexCode!.trim())) {
      return 'كود اللون غير صحيح (مثال: #FFFFFF)';
    }
    return null;
  }

  List<LocalMediaPick> get localImages => images
      .where((item) => item.isLocal)
      .map((item) => item.localPick!)
      .toList();

  static bool _isValidHex(String value) =>
      RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value);

  @override
  List<Object?> get props => [remoteColorId, name, nameEn, hexCode, images];
}

class ProductDraft extends Equatable {
  const ProductDraft({
    this.productId,
    required this.name,
    this.nameEn,
    this.description,
    required this.unitPrice,
    required this.pricingUnit,
    this.productImages = const [],
    this.colors = const [],
    this.properties = const [],
  });

  final String? productId;
  final String name;
  final String? nameEn;
  final String? description;
  final double unitPrice;
  final ProductPricingUnit pricingUnit;
  final List<FormMediaItem> productImages;
  final List<ProductColorDraft> colors;
  final List<ProductPropertyAssignmentDraft> properties;

  bool get isEditing => productId != null;

  String? get validationError {
    if (name.trim().isEmpty) return 'اسم المنتج بالعربية مطلوب';
    if (unitPrice < 0) return 'السعر لا يمكن أن يكون سالباً';
    for (final color in colors) {
      final colorError = color.validationError;
      if (colorError != null) {
        final label = color.name.trim().isEmpty
            ? 'لون بدون اسم'
            : color.name.trim();
        return 'اللون "$label": $colorError';
      }
    }
    for (final property in properties) {
      final propertyError = property.validationError;
      if (propertyError != null) {
        final label = property.nameAr.trim().isEmpty
            ? 'خاصية بدون اسم'
            : property.nameAr.trim();
        return 'الخاصية "$label": $propertyError';
      }
    }
    return null;
  }

  List<LocalMediaPick> get localProductImages => productImages
      .where((item) => item.isLocal)
      .map((item) => item.localPick!)
      .toList(growable: false);

  int get pendingNewUploadBytes =>
      localProductImages.fold<int>(0, (sum, item) => sum + item.sizeBytes) +
      colors.fold<int>(
        0,
        (sum, color) =>
            sum + color.localImages.fold<int>(0, (s, img) => s + img.sizeBytes),
      );

  @override
  List<Object?> get props => [
    productId,
    name,
    nameEn,
    description,
    unitPrice,
    pricingUnit,
    productImages,
    colors,
    properties,
  ];
}
