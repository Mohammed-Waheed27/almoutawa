import 'package:dartz/dartz.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../entities/admin_report.dart';
import '../entities/user_role.dart';
import '../repositories/admin_reports_repository.dart';

class FetchAdminReportsUseCase {
  FetchAdminReportsUseCase(this._repository);

  final AdminReportsRepository _repository;

  Future<Either<Failure, AdminReportsBundle>> call({
    required AdminReportDateRange range,
    UserRole? staffRole,
  }) {
    dbgAdmin(
      'FetchAdminReports start period=${range.period.name} '
      'role=${staffRole?.dbValue}',
    );
    return _repository.fetchReports(range: range, staffRole: staffRole);
  }
}
