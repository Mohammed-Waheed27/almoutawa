import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/utils/pretty_logger.dart';
import 'presentation/app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    PrettyLogger.error(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
      tag: 'Boot',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    PrettyLogger.error(
      'Uncaught platform error',
      error: error,
      stackTrace: stack,
      tag: 'Boot',
    );
    return true;
  };

  runApp(const AppBootstrap());
}
