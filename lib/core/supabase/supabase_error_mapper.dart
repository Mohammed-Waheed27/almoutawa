import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/failures.dart';
import '../utils/pretty_logger.dart';

/// Maps Supabase / PostgREST errors to Arabic user copy and logs rich debug detail.
abstract final class SupabaseErrorMapper {
  static String userMessage(Object error) {
    if (error is AuthException) {
      return _authMessage(error);
    }
    if (error is PostgrestException) {
      return _postgrestMessage(error);
    }
    if (error is AuthFailure) {
      return error.message;
    }
    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }

  static void logRemoteFailure({
    required String flowTag,
    required String step,
    required Object error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    final details = <String, Object?>{
      'step': step,
      if (context != null) ...context,
    };

    if (error is PostgrestException) {
      details
        ..['code'] = error.code ?? 'unknown'
        ..['message'] = error.message
        ..['details'] = error.details ?? ''
        ..['hint'] = error.hint ?? '';
    } else if (error is AuthException) {
      details
        ..['statusCode'] = error.statusCode ?? 'unknown'
        ..['message'] = error.message;
    } else {
      details['runtimeType'] = error.runtimeType.toString();
    }

    PrettyLogger.error(
      'Supabase failure at $step',
      tag: flowTag,
      error: error,
      stackTrace: stackTrace,
      data: details,
    );
  }

  static String _authMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (message.contains('email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }
    return error.message;
  }

  static String _postgrestMessage(PostgrestException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();
    final details = '${error.details ?? ''}'.toLowerCase();

    if (_isRlsDenied(code: code, message: message, details: details)) {
      return 'لا تملك صلاحية للوصول إلى هذه البيانات (RLS)';
    }
    if (code == 'PGRST116') {
      return 'لم يتم العثور على السجل المطلوب';
    }
    if (message.contains('permission denied for function')) {
      return 'خطأ في صلاحيات قاعدة البيانات — تواصل مع مدير النظام';
    }
    if (message.contains('jwt') || message.contains('token')) {
      return 'انتهت الجلسة. سجّل الدخول مرة أخرى';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
    }
    return error.message.isNotEmpty
        ? error.message
        : 'حدث خطأ أثناء الاتصال بالخادم';
  }

  static bool _isRlsDenied({
    required String code,
    required String message,
    required String details,
  }) {
    if (code == '42501') return true;
    if (message.contains('row-level security')) return true;
    if (message.contains('permission denied')) return true;
    if (details.contains('row-level security')) return true;
    return false;
  }
}
