import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnv {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError('SUPABASE_URL is missing from .env');
    }
    return value;
  }

  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    if (value == null || value.isEmpty) {
      throw StateError('SUPABASE_ANON_KEY is missing from .env');
    }
    return value;
  }
}
