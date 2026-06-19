import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:ads_sdk_integration/core/di/dependency_injection.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();

  final logger = sl<AppLogger>();

  FlutterError.onError = (details) {
    logger.error(details.exceptionAsString(), details.exception, details.stack);
  };

  runApp(await builder());
}
