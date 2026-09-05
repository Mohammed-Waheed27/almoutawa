import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/local_media_pick.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_property.dart';
import '../../domain/entities/storage_quota.dart';
import 'product_media_storage_data_source.dart';
import 'product_properties_remote_data_source.dart';

class ProductsRemoteDataSource {
  ProductsRemoteDataSource(
    this._client,
    this._mediaStorage,
    this._propertiesRemote,
  );

  final SupabaseClient _client;
  final ProductMediaStorageDataSource _mediaStorage;
  final ProductPropertiesRemoteDataSource _propertiesRemote;

  static const _productSelect =
      'id, name, name_en, description, image_url, unit_price, pricing_unit, '
      'created_at, updated_at, '
      'product_images(id, storage_path, file_size_bytes, sort_order), '
      'product_colors(id, product_id, name, name_en, hex_code, color_image_url, '
      'sort_order, '
      'product_color_images(id, storage_path, file_size_bytes, sort_order)), '
      'product_property_assignments(id, sort_order, '
      'product_property_definitions(id, name_ar, name_en, icon_key, sort_order, '
      'product_property_values(id, definition_id, value_ar, value_en, sort_order)), '
      'product_property_assignment_values('
      'product_property_values(id, definition_id, value_ar, value_en, sort_order)))';

  Future<Product> fetchProductById(String productId) async {
    dbgProducts('fetchProductById start id=$productId');
    try {
      final row = await _client
          .from('products')
          .select(_productSelect)
          .eq('id', productId)
          .eq('is_active', true)
          .single();

      final product = _mapProduct(row);
      dbgProducts('fetchProductById ok id=$productId');
      return product;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'fetchProductById',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Product> appendProductImage({
    required String productId,
    required LocalMediaPick pick,
    required StorageQuota quota,
  }) async {
    final fileError = quota.validateFileSize(pick.sizeBytes);
    if (fileError != null) throw ServerFailure(fileError);
    if (!quota.canUploadBytes(pick.sizeBytes)) {
      throw ServerFailure('مساحة التخزين غير كافية لرفع الصورة');
    }

    dbgProducts('appendProductImage start id=$productId');
    try {
      final product = await fetchProductById(productId);
      if (product.images.length >= quota.maxProductImages) {
        throw ServerFailure(
          'عدد صور المنتج يتجاوز الحد (${quota.maxProductImages})',
        );
      }
      final path = await _mediaStorage.uploadProductImage(
        productId: productId,
        pick: pick,
      );
      await _client.from('product_images').insert({
        'product_id': productId,
        'storage_path': path,
        'file_size_bytes': pick.sizeBytes,
        'sort_order': product.images.length,
      });
      if ((product.imageUrl ?? '').trim().isEmpty) {
        await _client
            .from('products')
            .update({'image_url': _mediaStorage.publicUrl(path)})
            .eq('id', productId);
      }
      return fetchProductById(productId);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'appendProductImage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Product> appendColorImage({
    required String productId,
    required String colorId,
    required LocalMediaPick pick,
    required StorageQuota quota,
  }) async {
    final fileError = quota.validateFileSize(pick.sizeBytes);
    if (fileError != null) throw ServerFailure(fileError);
    if (!quota.canUploadBytes(pick.sizeBytes)) {
      throw ServerFailure('مساحة التخزين غير كافية لرفع الصورة');
    }

    dbgProducts('appendColorImage start product=$productId color=$colorId');
    try {
      final product = await fetchProductById(productId);
      final color = product.colors.where((item) => item.id == colorId);
      if (color.isEmpty) {
        throw ServerFailure('اللون غير موجود على هذا المنتج');
      }
      if (color.first.images.length >= quota.maxColorImages) {
        throw ServerFailure(
          'عدد صور اللون يتجاوز الحد (${quota.maxColorImages})',
        );
      }
      final path = await _mediaStorage.uploadColorImage(
        productId: productId,
        colorId: colorId,
        pick: pick,
      );
      await _client.from('product_color_images').insert({
        'product_color_id': colorId,
        'storage_path': path,
        'file_size_bytes': pick.sizeBytes,
        'sort_order': color.first.images.length,
      });
      if ((color.first.colorImageUrl ?? '').trim().isEmpty) {
        await _client
            .from('product_colors')
            .update({'color_image_url': _mediaStorage.publicUrl(path)})
            .eq('id', colorId);
      }
      return fetchProductById(productId);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'appendColorImage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<PagedResult<Product>> fetchProductsPage({
    required int page,
    required int pageSize,
  }) async {
    dbgProducts('fetchProductsPage start page=$page');
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from('products')
          .select(_productSelect)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final rows = response.data as List<dynamic>;
      final products = rows
          .map((row) => _mapProduct(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgProducts(
        'fetchProductsPage ok count=${products.length} total=${response.count}',
      );
      return PagedResult(
        items: products,
        totalCount: response.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'fetchProductsPage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Product> createProduct(
    ProductDraft draft, {
    required StorageQuota quota,
  }) async {
    dbgProducts('createProduct start name=${draft.name.trim()}');
    _validateUploadBudget(draft, quota);

    try {
      final productRow = await _client
          .from('products')
          .insert(_draftToProductPayload(draft))
          .select('id')
          .single();

      final productId = productRow['id'] as String;

      for (var i = 0; i < draft.localProductImages.length; i++) {
        final pick = draft.localProductImages[i];
        final path = await _mediaStorage.uploadProductImage(
          productId: productId,
          pick: pick,
        );
        await _client.from('product_images').insert({
          'product_id': productId,
          'storage_path': path,
          'file_size_bytes': pick.sizeBytes,
          'sort_order': i,
        });
      }

      for (var colorIndex = 0; colorIndex < draft.colors.length; colorIndex++) {
        final colorDraft = draft.colors[colorIndex];
        final colorNameEn = colorDraft.nameEn?.trim();
        final colorRow = await _client
            .from('product_colors')
            .insert({
              'product_id': productId,
              'name': colorDraft.name.trim(),
              if (colorNameEn != null && colorNameEn.isNotEmpty)
                'name_en': colorNameEn,
              'hex_code': _normalizeHex(colorDraft.hexCode),
              'sort_order': colorIndex,
            })
            .select('id')
            .single();

        final colorId = colorRow['id'] as String;
        for (
          var imgIndex = 0;
          imgIndex < colorDraft.localImages.length;
          imgIndex++
        ) {
          final pick = colorDraft.localImages[imgIndex];
          final path = await _mediaStorage.uploadColorImage(
            productId: productId,
            colorId: colorId,
            pick: pick,
          );
          await _client.from('product_color_images').insert({
            'product_color_id': colorId,
            'storage_path': path,
            'file_size_bytes': pick.sizeBytes,
            'sort_order': imgIndex,
          });
        }
      }

      if (draft.properties.isNotEmpty) {
        await _propertiesRemote.saveProductPropertyAssignments(
          productId: productId,
          properties: draft.properties,
        );
      }

      final row = await _client
          .from('products')
          .select(_productSelect)
          .eq('id', productId)
          .single();

      dbgProducts('createProduct ok id=$productId');
      return _mapProduct(row);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'createProduct',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<Product> updateProduct(
    String productId,
    ProductDraft draft, {
    required StorageQuota quota,
    required Product baseline,
  }) async {
    dbgProducts('updateProduct start id=$productId name=${draft.name.trim()}');
    _validateUploadBudgetForUpdate(draft, quota);

    try {
      await _client
          .from('products')
          .update(_draftToProductPayload(draft))
          .eq('id', productId);

      await _syncProductImages(productId, draft, baseline);
      await _syncColors(productId, draft, baseline);
      await _propertiesRemote.replaceProductPropertyAssignments(
        productId: productId,
        properties: draft.properties,
      );

      final row = await _client
          .from('products')
          .select(_productSelect)
          .eq('id', productId)
          .single();

      dbgProducts('updateProduct ok id=$productId');
      return _mapProduct(row);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'updateProduct',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<void> _syncProductImages(
    String productId,
    ProductDraft draft,
    Product baseline,
  ) async {
    final retainedRemoteIds = draft.productImages
        .where((item) => item.isRemote)
        .map((item) => item.remoteAsset!.id)
        .toSet();

    for (final image in baseline.images) {
      if (!retainedRemoteIds.contains(image.id)) {
        await _client.from('product_images').delete().eq('id', image.id);
      }
    }

    final nextSortBase = draft.productImages
        .where((item) => item.isRemote)
        .length;

    var localIndex = 0;
    for (final item in draft.productImages) {
      if (!item.isLocal) continue;
      final pick = item.localPick!;
      final path = await _mediaStorage.uploadProductImage(
        productId: productId,
        pick: pick,
      );
      await _client.from('product_images').insert({
        'product_id': productId,
        'storage_path': path,
        'file_size_bytes': pick.sizeBytes,
        'sort_order': nextSortBase + localIndex,
      });
      localIndex++;
    }
  }

  Future<void> _syncColors(
    String productId,
    ProductDraft draft,
    Product baseline,
  ) async {
    final baselineById = {for (final color in baseline.colors) color.id: color};
    final retainedRemoteIds = draft.colors
        .where((color) => color.remoteColorId != null)
        .map((color) => color.remoteColorId!)
        .toSet();

    for (final baselineColor in baseline.colors) {
      if (!retainedRemoteIds.contains(baselineColor.id)) {
        await _client
            .from('product_color_images')
            .delete()
            .eq('product_color_id', baselineColor.id);
        await _client
            .from('product_colors')
            .delete()
            .eq('id', baselineColor.id);
      }
    }

    for (var colorIndex = 0; colorIndex < draft.colors.length; colorIndex++) {
      final colorDraft = draft.colors[colorIndex];
      if (colorDraft.remoteColorId != null) {
        final colorId = colorDraft.remoteColorId!;
        final updateNameEn = colorDraft.nameEn?.trim();
        await _client
            .from('product_colors')
            .update({
              'name': colorDraft.name.trim(),
              'name_en': (updateNameEn == null || updateNameEn.isEmpty)
                  ? null
                  : updateNameEn,
              'hex_code': _normalizeHex(colorDraft.hexCode),
              'sort_order': colorIndex,
            })
            .eq('id', colorId);

        await _syncColorImages(
          productId: productId,
          colorId: colorId,
          colorDraft: colorDraft,
          baselineColor: baselineById[colorId],
        );
        continue;
      }

      final insertNameEn = colorDraft.nameEn?.trim();
      final colorRow = await _client
          .from('product_colors')
          .insert({
            'product_id': productId,
            'name': colorDraft.name.trim(),
            if (insertNameEn != null && insertNameEn.isNotEmpty)
              'name_en': insertNameEn,
            'hex_code': _normalizeHex(colorDraft.hexCode),
            'sort_order': colorIndex,
          })
          .select('id')
          .single();

      final colorId = colorRow['id'] as String;
      for (
        var imgIndex = 0;
        imgIndex < colorDraft.localImages.length;
        imgIndex++
      ) {
        final pick = colorDraft.localImages[imgIndex];
        final path = await _mediaStorage.uploadColorImage(
          productId: productId,
          colorId: colorId,
          pick: pick,
        );
        await _client.from('product_color_images').insert({
          'product_color_id': colorId,
          'storage_path': path,
          'file_size_bytes': pick.sizeBytes,
          'sort_order': imgIndex,
        });
      }
    }
  }

  Future<void> _syncColorImages({
    required String productId,
    required String colorId,
    required ProductColorDraft colorDraft,
    required ProductColor? baselineColor,
  }) async {
    final retainedRemoteIds = colorDraft.images
        .where((item) => item.isRemote)
        .map((item) => item.remoteAsset!.id)
        .toSet();

    for (final image in baselineColor?.images ?? const <ProductMediaAsset>[]) {
      if (!retainedRemoteIds.contains(image.id)) {
        await _client.from('product_color_images').delete().eq('id', image.id);
      }
    }

    final nextSortBase = colorDraft.images
        .where((item) => item.isRemote)
        .length;
    var localIndex = 0;
    for (final item in colorDraft.images) {
      if (!item.isLocal) continue;
      final pick = item.localPick!;
      final path = await _mediaStorage.uploadColorImage(
        productId: productId,
        colorId: colorId,
        pick: pick,
      );
      await _client.from('product_color_images').insert({
        'product_color_id': colorId,
        'storage_path': path,
        'file_size_bytes': pick.sizeBytes,
        'sort_order': nextSortBase + localIndex,
      });
      localIndex++;
    }
  }

  void _validateUploadBudgetForUpdate(ProductDraft draft, StorageQuota quota) {
    if (draft.productImages.length > quota.maxProductImages) {
      throw ServerFailure(
        'عدد صور المنتج يتجاوز الحد (${quota.maxProductImages})',
      );
    }
    if (draft.colors.length > quota.maxColorsPerProduct) {
      throw ServerFailure(
        'عدد الألوان يتجاوز الحد (${quota.maxColorsPerProduct})',
      );
    }

    for (final pick in draft.localProductImages) {
      final fileError = quota.validateFileSize(pick.sizeBytes);
      if (fileError != null) throw ServerFailure(fileError);
    }

    for (final color in draft.colors) {
      if (color.images.length > quota.maxColorImages) {
        throw ServerFailure(
          'عدد صور اللون "${color.name}" يتجاوز الحد (${quota.maxColorImages})',
        );
      }
      for (final pick in color.localImages) {
        final fileError = quota.validateFileSize(pick.sizeBytes);
        if (fileError != null) throw ServerFailure(fileError);
      }
    }

    if (!quota.canUploadBytes(draft.pendingNewUploadBytes)) {
      throw ServerFailure('مساحة التخزين غير كافية لرفع الصور الجديدة');
    }
  }

  void _validateUploadBudget(ProductDraft draft, StorageQuota quota) {
    if (draft.productImages.length > quota.maxProductImages) {
      throw ServerFailure(
        'عدد صور المنتج يتجاوز الحد (${quota.maxProductImages})',
      );
    }
    if (draft.colors.length > quota.maxColorsPerProduct) {
      throw ServerFailure(
        'عدد الألوان يتجاوز الحد (${quota.maxColorsPerProduct})',
      );
    }

    var pendingBytes = 0;
    for (final pick in draft.localProductImages) {
      final fileError = quota.validateFileSize(pick.sizeBytes);
      if (fileError != null) throw ServerFailure(fileError);
      pendingBytes += pick.sizeBytes;
    }

    for (final color in draft.colors) {
      if (color.images.length > quota.maxColorImages) {
        throw ServerFailure(
          'عدد صور اللون "${color.name}" يتجاوز الحد (${quota.maxColorImages})',
        );
      }
      for (final pick in color.localImages) {
        final fileError = quota.validateFileSize(pick.sizeBytes);
        if (fileError != null) throw ServerFailure(fileError);
        pendingBytes += pick.sizeBytes;
      }
    }

    if (!quota.canUploadBytes(pendingBytes)) {
      throw ServerFailure('مساحة التخزين غير كافية لرفع الصور المحددة');
    }
  }

  Map<String, dynamic> _draftToProductPayload(ProductDraft draft) {
    final nameEn = draft.nameEn?.trim();
    return {
      'name': draft.name.trim(),
      'name_en': (nameEn == null || nameEn.isEmpty) ? null : nameEn,
      'description': draft.description?.trim(),
      'unit_price': draft.unitPrice,
      'pricing_unit': draft.pricingUnit.dbValue,
    };
  }

  String? _normalizeHex(String? hex) {
    if (hex == null) return null;
    final trimmed = hex.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  Product _mapProduct(Map<String, dynamic> row) {
    final imageRows = row['product_images'] as List<dynamic>? ?? const [];
    final images =
        imageRows
            .map((item) => _mapMediaAsset(item as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final colorRows = row['product_colors'] as List<dynamic>? ?? const [];
    final colors =
        colorRows
            .map((item) => _mapColor(item as Map<String, dynamic>))
            .where((color) => color.name.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final propertyRows =
        row['product_property_assignments'] as List<dynamic>? ?? const [];
    final properties = _mapPropertyAssignments(propertyRows);

    return Product(
      id: row['id'] as String,
      name: row['name'] as String,
      nameEn: row['name_en'] as String?,
      description: row['description'] as String?,
      imageUrl: row['image_url'] as String?,
      unitPrice: _parseAmount(row['unit_price']),
      pricingUnit: ProductPricingUnit.fromDbValue(
        row['pricing_unit'] as String,
      ),
      images: images,
      colors: colors,
      properties: properties,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  List<ProductPropertyAssignment> _mapPropertyAssignments(List<dynamic> rows) {
    final assignments =
        rows
            .map((item) => _mapPropertyAssignment(item as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return assignments;
  }

  ProductPropertyAssignment _mapPropertyAssignment(Map<String, dynamic> row) {
    final definitionRow =
        row['product_property_definitions'] as Map<String, dynamic>;
    final definitionValues =
        definitionRow['product_property_values'] as List<dynamic>? ?? const [];

    final assignmentValueRows =
        row['product_property_assignment_values'] as List<dynamic>? ?? const [];
    final values =
        assignmentValueRows
            .map((item) {
              final valueRow =
                  (item as Map<String, dynamic>)['product_property_values']
                      as Map<String, dynamic>;
              return ProductPropertyValue(
                id: valueRow['id'] as String,
                definitionId: valueRow['definition_id'] as String,
                valueAr: valueRow['value_ar'] as String,
                valueEn: (valueRow['value_en'] as String?) ?? '',
                sortOrder: valueRow['sort_order'] as int? ?? 0,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final definition = ProductPropertyDefinition(
      id: definitionRow['id'] as String,
      nameAr: definitionRow['name_ar'] as String,
      nameEn: (definitionRow['name_en'] as String?) ?? '',
      iconKey: definitionRow['icon_key'] as String?,
      sortOrder: definitionRow['sort_order'] as int? ?? 0,
      values: definitionValues
          .map(
            (item) => ProductPropertyValue(
              id: (item as Map<String, dynamic>)['id'] as String,
              definitionId: item['definition_id'] as String,
              valueAr: item['value_ar'] as String,
              valueEn: (item['value_en'] as String?) ?? '',
              sortOrder: item['sort_order'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
    );

    return ProductPropertyAssignment(
      id: row['id'] as String,
      definition: definition,
      values: values,
      sortOrder: row['sort_order'] as int? ?? 0,
    );
  }

  ProductColor _mapColor(Map<String, dynamic> row) {
    final imageRows = row['product_color_images'] as List<dynamic>? ?? const [];
    final images =
        imageRows
            .map((item) => _mapMediaAsset(item as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ProductColor(
      id: row['id'] as String,
      productId: row['product_id'] as String,
      name: row['name'] as String,
      nameEn: row['name_en'] as String?,
      hexCode: row['hex_code'] as String?,
      colorImageUrl: row['color_image_url'] as String?,
      images: images,
      sortOrder: row['sort_order'] as int? ?? 0,
    );
  }

  ProductMediaAsset _mapMediaAsset(Map<String, dynamic> row) {
    final path = row['storage_path'] as String;
    return ProductMediaAsset(
      id: row['id'] as String,
      storagePath: path,
      publicUrl: _mediaStorage.publicUrl(path),
      fileSizeBytes: (row['file_size_bytes'] as num?)?.toInt() ?? 0,
      sortOrder: row['sort_order'] as int? ?? 0,
    );
  }

  double _parseAmount(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
