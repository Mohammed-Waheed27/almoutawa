import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/product_property.dart';

class ProductPropertiesRemoteDataSource {
  ProductPropertiesRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _definitionSelect =
      'id, name_ar, name_en, icon_key, sort_order, '
      'product_property_values(id, definition_id, value_ar, value_en, sort_order, image_url)';

  Future<List<ProductPropertyDefinition>> fetchDefinitions() async {
    dbgProducts('fetchPropertyDefinitions start');
    try {
      final rows = await _client
          .from('product_property_definitions')
          .select(_definitionSelect)
          .eq('is_active', true)
          .order('sort_order')
          .order('created_at');

      final definitions = rows
          .map((row) => _mapDefinition(row))
          .toList(growable: false);

      dbgProducts('fetchPropertyDefinitions ok count=${definitions.length}');
      return definitions;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'fetchPropertyDefinitions',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<ProductPropertyDefinition> createDefinition(
    ProductPropertyDefinitionDraft draft,
  ) async {
    dbgProducts('createPropertyDefinition start nameAr=${draft.nameAr.trim()}');
    try {
      final definitionRow = await _client
          .from('product_property_definitions')
          .insert({
            'name_ar': draft.nameAr.trim(),
            'name_en': draft.nameEn.trim(),
            'icon_key': draft.iconKey,
          })
          .select('id')
          .single();

      final definitionId = definitionRow['id'] as String;
      await _upsertValues(definitionId, draft.values);

      final row = await _client
          .from('product_property_definitions')
          .select(_definitionSelect)
          .eq('id', definitionId)
          .single();

      dbgProducts('createPropertyDefinition ok id=$definitionId');
      return _mapDefinition(row);
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'createPropertyDefinition',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<ProductPropertyDefinition> updateDefinition(
    String definitionId,
    ProductPropertyDefinitionDraft draft,
  ) async {
    dbgProducts('updatePropertyDefinition start id=$definitionId');
    try {
      await _client
          .from('product_property_definitions')
          .update({
            'name_ar': draft.nameAr.trim(),
            'name_en': draft.nameEn.trim(),
            'icon_key': draft.iconKey,
          })
          .eq('id', definitionId);

      await _client
          .from('product_property_values')
          .update({'is_active': false})
          .eq('definition_id', definitionId);

      await _upsertValues(definitionId, draft.values);

      final row = await _client
          .from('product_property_definitions')
          .select(_definitionSelect)
          .eq('id', definitionId)
          .single();

      dbgProducts('updatePropertyDefinition ok id=$definitionId');
      return _mapDefinition(row);
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'updatePropertyDefinition',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<void> replaceProductPropertyAssignments({
    required String productId,
    required List<ProductPropertyAssignmentDraft> properties,
  }) async {
    dbgProducts(
      'replaceProductPropertyAssignments start productId=$productId count=${properties.length}',
    );

    try {
      final existingAssignments = await _client
          .from('product_property_assignments')
          .select('id')
          .eq('product_id', productId);

      for (final row in existingAssignments as List<dynamic>) {
        final assignmentId = (row as Map<String, dynamic>)['id'] as String;
        await _client
            .from('product_property_assignment_values')
            .delete()
            .eq('assignment_id', assignmentId);
      }

      await _client
          .from('product_property_assignments')
          .delete()
          .eq('product_id', productId);

      if (properties.isNotEmpty) {
        await saveProductPropertyAssignments(
          productId: productId,
          properties: properties,
        );
      }

      dbgProducts('replaceProductPropertyAssignments ok productId=$productId');
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'replaceProductPropertyAssignments',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<void> saveProductPropertyAssignments({
    required String productId,
    required List<ProductPropertyAssignmentDraft> properties,
  }) async {
    if (properties.isEmpty) return;

    dbgProducts(
      'saveProductPropertyAssignments start productId=$productId count=${properties.length}',
    );

    try {
      for (var i = 0; i < properties.length; i++) {
        final prop = properties[i];
        final definitionId =
            prop.definitionId ??
            await _insertDefinition(
              nameAr: prop.nameAr,
              nameEn: prop.nameEn,
              iconKey: prop.iconKey,
            );

        final valueIds = await _resolveValueIds(
          definitionId: definitionId,
          values: prop.values,
        );

        final assignmentRow = await _client
            .from('product_property_assignments')
            .insert({
              'product_id': productId,
              'definition_id': definitionId,
              'sort_order': i,
            })
            .select('id')
            .single();

        final assignmentId = assignmentRow['id'] as String;
        for (final valueId in valueIds) {
          await _client.from('product_property_assignment_values').insert({
            'assignment_id': assignmentId,
            'value_id': valueId,
          });
        }
      }

      dbgProducts('saveProductPropertyAssignments ok productId=$productId');
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'saveProductPropertyAssignments',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<String> _insertDefinition({
    required String nameAr,
    required String nameEn,
    String? iconKey,
  }) async {
    final row = await _client
        .from('product_property_definitions')
        .insert({
          'name_ar': nameAr.trim(),
          'name_en': nameEn.trim().isEmpty ? null : nameEn.trim(),
          'icon_key': iconKey,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> _upsertValues(
    String definitionId,
    List<ProductPropertyValueDraft> values,
  ) async {
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value.valueId != null) {
        await _client
            .from('product_property_values')
            .update({
              'value_ar': value.valueAr.trim(),
              'value_en': value.valueEn.trim(),
              'sort_order': i,
              'is_active': true,
              'image_url': value.imageUrl,
            })
            .eq('id', value.valueId!);
      } else {
        await _client.from('product_property_values').insert({
          'definition_id': definitionId,
          'value_ar': value.valueAr.trim(),
          'value_en': value.valueEn.trim(),
          'sort_order': i,
          'image_url': value.imageUrl,
        });
      }
    }
  }

  Future<List<String>> _resolveValueIds({
    required String definitionId,
    required List<ProductPropertyValueDraft> values,
  }) async {
    final ids = <String>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value.valueId != null) {
        ids.add(value.valueId!);
        continue;
      }
      final row = await _client
          .from('product_property_values')
          .insert({
            'definition_id': definitionId,
            'value_ar': value.valueAr.trim(),
            'value_en': value.valueEn.trim(),
            'sort_order': i,
            'image_url': value.imageUrl,
          })
          .select('id')
          .single();
      ids.add(row['id'] as String);
    }
    return ids;
  }

  ProductPropertyDefinition _mapDefinition(Map<String, dynamic> row) {
    final valueRows =
        row['product_property_values'] as List<dynamic>? ?? const [];
    final values =
        valueRows
            .map((item) => _mapValue(item as Map<String, dynamic>))
            .where((value) => value.valueAr.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ProductPropertyDefinition(
      id: row['id'] as String,
      nameAr: row['name_ar'] as String,
      nameEn: (row['name_en'] as String?) ?? '',
      iconKey: row['icon_key'] as String?,
      sortOrder: row['sort_order'] as int? ?? 0,
      values: values,
    );
  }

  ProductPropertyValue _mapValue(Map<String, dynamic> row) {
    return ProductPropertyValue(
      id: row['id'] as String,
      definitionId: row['definition_id'] as String,
      valueAr: row['value_ar'] as String,
      valueEn: (row['value_en'] as String?) ?? '',
      sortOrder: row['sort_order'] as int? ?? 0,
      imageUrl: row['image_url'] as String?,
    );
  }
}
