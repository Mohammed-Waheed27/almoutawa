import '../../domain/entities/paged_result.dart';
import '../../domain/entities/staff_profile.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl(this._remote);

  final StaffRemoteDataSource _remote;

  @override
  Future<PagedResult<StaffProfile>> fetchDeliveryWorkersPage({
    required int page,
    int pageSize = staffPageSize,
  }) {
    return _remote.fetchDeliveryWorkersPage(page: page, pageSize: pageSize);
  }

  @override
  Future<PagedResult<StaffProfile>> fetchStaffPage({
    required UserRole role,
    required int page,
    int pageSize = staffPageSize,
  }) {
    return _remote.fetchStaffPage(role: role, page: page, pageSize: pageSize);
  }

  @override
  Future<StaffProfile> createDeliveryWorker(StaffProfileDraft draft) {
    return _remote.createDeliveryWorker(draft);
  }

  @override
  Future<StaffProfile> updateDeliveryWorker({
    required String profileId,
    required StaffProfileUpdateDraft draft,
  }) {
    return _remote.updateDeliveryWorker(profileId: profileId, draft: draft);
  }

  @override
  Future<StaffProfile> suspendDeliveryWorker(String profileId) {
    return _remote.suspendDeliveryWorker(profileId);
  }

  @override
  Future<StaffProfile> reactivateDeliveryWorker(String profileId) {
    return _remote.reactivateDeliveryWorker(profileId);
  }

  @override
  Future<void> deleteDeliveryWorker(String profileId) {
    return _remote.deleteDeliveryWorker(profileId);
  }
}
