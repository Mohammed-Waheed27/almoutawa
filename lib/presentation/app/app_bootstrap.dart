import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_env.dart';
import '../../core/shared/widgets/layout/app_brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/pretty_logger.dart';
import '../../di/injection_container.dart';
import '../../l10n/app_strings.dart';
import 'app_root.dart';

/// Paints a first Flutter frame immediately so the native splash can dismiss,
/// then loads env / Supabase / DI before handing off to [AppRoot].
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Object? _error;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    PrettyLogger.info('Bootstrap started', tag: 'Boot');
    try {
      await AppEnv.load().timeout(const Duration(seconds: 8));
      PrettyLogger.debug('Env loaded', tag: 'Boot');

      await Supabase.initialize(
        url: AppEnv.supabaseUrl,
        publishableKey: AppEnv.supabaseAnonKey,
      ).timeout(const Duration(seconds: 12));
      PrettyLogger.debug('Supabase ready', tag: 'Boot');

      await configureDependencies();
      PrettyLogger.success('Bootstrap complete', tag: 'Boot');

      if (!mounted) return;
      setState(() {
        _ready = true;
        _error = null;
      });
    } catch (error, stackTrace) {
      PrettyLogger.error(
        'Bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'Boot',
      );
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const AppRoot();
    }

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Tajawal',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _error != null
          ? _BootstrapErrorView(
              message: _error.toString(),
              onRetry: () {
                setState(() => _error = null);
                unawaited(_initialize());
              },
            )
          : const _BootstrapLoadingView(),
    );
  }
}

class _BootstrapLoadingView extends StatelessWidget {
  const _BootstrapLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBrandLogo(height: 168),
            SizedBox(height: 32),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // Literal padding — ScreenUtil is not ready during bootstrap.
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذّر تشغيل التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تحقق من الاتصال وملف الإعدادات ثم أعد المحاولة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
