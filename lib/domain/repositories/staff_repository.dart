import '../entities/paged_result.dart';
import '../entities/staff_profile.dart';
import '../entities/user_role.dart';

abstract class StaffRepository {
  Future<PagedResult<StaffProfile>> fetchDeliveryWorkersPage({
    required int page,
    int pageSize = staffPageSize,
  });

  Future<PagedResult<StaffProfile>> fetchStaffPage({
    required UserRole role,
    required int page,
    int pageSize = staffPageSize,
  });

  Future<StaffProfile> createDeliveryWorker(StaffProfileDraft draft);

  Future<StaffProfile> updateDeliveryWorker({
    required String profileId,
    required StaffProfileUpdateDraft draft,
  });

  Future<StaffProfile> suspendDeliveryWorker(String profileId);

  Future<StaffProfile> reactivateDeliveryWorker(String profileId);

  Future<void> deleteDeliveryWorker(String profileId);
}
