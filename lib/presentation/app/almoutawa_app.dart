import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/adaptive_scope.dart';
import '../../core/layout/screen_util_config.dart';
import '../../core/theme/app_density.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../routes/app_router.dart';
import '../routes/auth_refresh_notifier.dart';

class AlmoutawaApp extends StatefulWidget {
  const AlmoutawaApp({super.key, required this.authBloc});

  final AuthBloc authBloc;

  @override
  State<AlmoutawaApp> createState() => _AlmoutawaAppState();
}

class _AlmoutawaAppState extends State<AlmoutawaApp> {
  late final AuthRefreshNotifier _refreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _refreshNotifier = AuthRefreshNotifier(widget.authBloc);
    _router = createAppRouter(
      authBloc: widget.authBloc,
      refreshNotifier: _refreshNotifier,
    );
  }

  @override
  void dispose() {
    _refreshNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtilConfig.designSize,
      minTextAdapt: ScreenUtilConfig.minTextAdapt,
      splitScreenMode: ScreenUtilConfig.splitScreenMode,
      // Desktop / laptop: 1:1 logical px — see ScreenUtilConfig.allowScale.
      enableScaleWH: ScreenUtilConfig.allowScale,
      enableScaleText: ScreenUtilConfig.allowScale,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return AdaptiveScopeHost(
              child: AppDensityScopeHost(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          routerConfig: _router,
        );
      },
    );
  }
}
