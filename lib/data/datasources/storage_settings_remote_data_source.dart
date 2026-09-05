import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/storage_quota.dart';

class StorageSettingsRemoteDataSource {
  StorageSettingsRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<StorageQuota> fetchStorageQuota() async {
    dbgProducts('fetchStorageQuota start');
    try {
      final settings = await _client
          .from('company_storage_settings')
          .select(
            'quota_bytes, max_file_bytes, max_product_images, '
            'max_color_images, max_colors_per_product',
          )
          .eq('id', 1)
          .single();

      final usage = await _client
          .from('company_storage_usage')
          .select('used_bytes')
          .maybeSingle();

      final usedBytes = (usage?['used_bytes'] as num?)?.toInt() ?? 0;

      return StorageQuota(
        quotaBytes: (settings['quota_bytes'] as num).toInt(),
        usedBytes: usedBytes,
        maxFileBytes: (settings['max_file_bytes'] as num).toInt(),
        maxProductImages: settings['max_product_images'] as int,
        maxColorImages: settings['max_color_images'] as int,
        maxColorsPerProduct: settings['max_colors_per_product'] as int,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'fetchStorageQuota',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }
}
