import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/admin_report.dart';
import '../entities/user_role.dart';

abstract class AdminReportsRepository {
  Future<Either<Failure, AdminReportsBundle>> fetchReports({
    required AdminReportDateRange range,
    UserRole? staffRole,
  });
}
