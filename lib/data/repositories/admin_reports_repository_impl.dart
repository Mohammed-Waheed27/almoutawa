import 'package:dartz/dartz.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/admin_report.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/admin_reports_repository.dart';
import '../datasources/admin_reports_remote_data_source.dart';

class AdminReportsRepositoryImpl implements AdminReportsRepository {
  AdminReportsRepositoryImpl(this._remote);

  final AdminReportsRemoteDataSource _remote;

  @override
  Future<Either<Failure, AdminReportsBundle>> fetchReports({
    required AdminReportDateRange range,
    UserRole? staffRole,
  }) async {
    try {
      final bundle = await _remote.fetchReports(
        range: range,
        staffRole: staffRole,
      );
      return Right(bundle);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'AdminReportsRepositoryImpl.fetchReports',
        error: error,
        stackTrace: stackTrace,
      );
      dbgAdminError(
        'fetchReports failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(SupabaseErrorMapper.userMessage(error)));
    }
  }
}
