import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Global bilingual property definition (e.g. كود اللون / Color Code).
class ProductPropertyDefinition extends Equatable {
  const ProductPropertyDefinition({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.iconKey,
    required this.sortOrder,
    required this.values,
  });

  final String id;
  final String nameAr;

  /// Optional English; empty means fall back to [nameAr].
  final String nameEn;
  final String? iconKey;
  final int sortOrder;
  final List<ProductPropertyValue> values;

  IconData get icon => productPropertyIconFromKey(iconKey);

  String get nameEnOrAr {
    final en = nameEn.trim();
    if (en.isNotEmpty) return en;
    return nameAr;
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, iconKey, sortOrder, values];
}

class ProductPropertyValue extends Equatable {
  const ProductPropertyValue({
    required this.id,
    required this.definitionId,
    required this.valueAr,
    required this.valueEn,
    required this.sortOrder,
    this.imageUrl,
  });

  final String id;
  final String definitionId;
  final String valueAr;

  /// Optional English; empty means fall back to [valueAr].
  final String valueEn;
  final int sortOrder;
  final String? imageUrl;

  String get valueEnOrAr {
    final en = valueEn.trim();
    if (en.isNotEmpty) return en;
    return valueAr;
  }

  @override
  List<Object?> get props => [
    id,
    definitionId,
    valueAr,
    valueEn,
    sortOrder,
    imageUrl,
  ];
}

/// Property linked to a product with allowed values.
class ProductPropertyAssignment extends Equatable {
  const ProductPropertyAssignment({
    required this.id,
    required this.definition,
    required this.values,
    required this.sortOrder,
  });

  final String id;
  final ProductPropertyDefinition definition;
  final List<ProductPropertyValue> values;
  final int sortOrder;

  @override
  List<Object?> get props => [id, definition, values, sortOrder];
}

class ProductPropertyValueDraft extends Equatable {
  const ProductPropertyValueDraft({
    this.valueId,
    required this.valueAr,
    required this.valueEn,
    this.imageUrl,
  });

  final String? valueId;
  final String valueAr;
  final String valueEn;
  final String? imageUrl;

  String? get validationError {
    if (valueAr.trim().isEmpty) return 'قيمة الخاصية بالعربية مطلوبة';
    return null;
  }

  @override
  List<Object?> get props => [valueId, valueAr, valueEn, imageUrl];
}

class ProductPropertyDefinitionDraft extends Equatable {
  const ProductPropertyDefinitionDraft({
    this.definitionId,
    required this.nameAr,
    required this.nameEn,
    this.iconKey,
    this.values = const [],
  });

  final String? definitionId;
  final String nameAr;
  final String nameEn;
  final String? iconKey;
  final List<ProductPropertyValueDraft> values;

  String? get validationError {
    if (nameAr.trim().isEmpty) return 'اسم الخاصية بالعربية مطلوب';
    if (values.isEmpty) return 'أضف قيمة واحدة على الأقل';
    for (final value in values) {
      final error = value.validationError;
      if (error != null) return error;
    }
    return null;
  }

  @override
  List<Object?> get props => [definitionId, nameAr, nameEn, iconKey, values];
}

class ProductPropertyAssignmentDraft extends Equatable {
  const ProductPropertyAssignmentDraft({
    required this.localId,
    this.definitionId,
    required this.nameAr,
    required this.nameEn,
    this.iconKey,
    this.values = const [],
  });

  final String localId;
  final String? definitionId;
  final String nameAr;
  final String nameEn;
  final String? iconKey;
  final List<ProductPropertyValueDraft> values;

  String? get validationError {
    if (nameAr.trim().isEmpty) return 'اسم الخاصية بالعربية مطلوب';
    if (values.isEmpty) return 'اختر قيمة واحدة على الأقل لكل خاصية';
    for (final value in values) {
      final error = value.validationError;
      if (error != null) return error;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    localId,
    definitionId,
    nameAr,
    nameEn,
    iconKey,
    values,
  ];
}

IconData productPropertyIconFromKey(String? key) {
  return switch (key) {
    'palette_outlined' => Icons.palette_outlined,
    'lock_outline' => Icons.lock_outline,
    'window_outlined' => Icons.window_outlined,
    'sensor_door_outlined' => Icons.sensor_door_outlined,
    'back_hand_outlined' => Icons.back_hand_outlined,
    'horizontal_rule' => Icons.horizontal_rule,
    'format_paint_outlined' => Icons.format_paint_outlined,
    'door_front_outlined' => Icons.door_sliding_outlined,
    'straighten_outlined' => Icons.straighten_outlined,
    'category_outlined' => Icons.category_outlined,
    _ => Icons.tune_outlined,
  };
}

const productPropertyIconOptions = {
  'palette_outlined': Icons.palette_outlined,
  'lock_outline': Icons.lock_outline,
  'window_outlined': Icons.window_outlined,
  'sensor_door_outlined': Icons.sensor_door_outlined,
  'back_hand_outlined': Icons.back_hand_outlined,
  'horizontal_rule': Icons.horizontal_rule,
  'format_paint_outlined': Icons.format_paint_outlined,
  'door_front_outlined': Icons.door_sliding_outlined,
  'straighten_outlined': Icons.straighten_outlined,
  'category_outlined': Icons.category_outlined,
};
