import '../entities/storage_quota.dart';

abstract class StorageRepository {
  Future<StorageQuota> fetchStorageQuota();
}
