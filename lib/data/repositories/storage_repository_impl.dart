import '../../domain/entities/storage_quota.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_settings_remote_data_source.dart';

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl(this._remote);

  final StorageSettingsRemoteDataSource _remote;

  @override
  Future<StorageQuota> fetchStorageQuota() => _remote.fetchStorageQuota();
}
