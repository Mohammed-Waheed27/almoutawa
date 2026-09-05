import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/local_media_pick.dart';

class ProductMediaStorageDataSource {
  ProductMediaStorageDataSource(this._client);

  final SupabaseClient _client;
  static const bucket = 'product-media';
  static const _uuid = Uuid();

  Future<String> uploadProductImage({
    required String productId,
    required LocalMediaPick pick,
  }) async {
    return _upload(
      path: 'products/$productId/${_uuid.v4()}.${pick.extension}',
      pick: pick,
    );
  }

  Future<String> uploadColorImage({
    required String productId,
    required String colorId,
    required LocalMediaPick pick,
  }) async {
    return _upload(
      path: 'products/$productId/colors/$colorId/${_uuid.v4()}.${pick.extension}',
      pick: pick,
    );
  }

  Future<String> uploadLooseImage({
    required String folder,
    required LocalMediaPick pick,
  }) async {
    final cleanFolder = folder.replaceAll(RegExp(r'^/+|/+$'), '');
    return _upload(
      path: '$cleanFolder/${_uuid.v4()}.${pick.extension}',
      pick: pick,
    );
  }

  Future<String> _upload({
    required String path,
    required LocalMediaPick pick,
  }) async {
    dbgProducts('uploadMedia start path=$path size=${pick.sizeBytes}');
    try {
      await _client.storage.from(bucket).uploadBinary(
        path,
        pick.bytes,
        fileOptions: FileOptions(contentType: pick.mimeType, upsert: false),
      );
      dbgProducts('uploadMedia ok path=$path');
      return path;
    } on StorageException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'ProductsFlow',
        step: 'uploadMedia',
        error: error,
        stackTrace: stackTrace,
        context: {'path': path},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  String publicUrl(String storagePath) {
    return _client.storage.from(bucket).getPublicUrl(storagePath);
  }
}
