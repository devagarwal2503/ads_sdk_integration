import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';

void main() {
  group('AppLogger Tests', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger();
    });

    tearDown(() {
      logger.dispose();
    });

    test('should emit logs to stream when info is called', () async {
      final logs = <String>[];
      final subscription = logger.logStream.listen(logs.add);

      logger.info('Info message');

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logs, contains('[INFO] Info message'));
      await subscription.cancel();
    });

    test('should emit logs to stream when debug is called', () async {
      final logs = <String>[];
      final subscription = logger.logStream.listen(logs.add);

      logger.debug('Debug message');

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logs, contains('[DEBUG] Debug message'));
      await subscription.cancel();
    });

    test('should emit logs to stream when warning is called', () async {
      final logs = <String>[];
      final subscription = logger.logStream.listen(logs.add);

      logger.warning('Warning message');

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logs, contains('[WARNING] Warning message'));
      await subscription.cancel();
    });

    test('should emit logs to stream when error is called without custom error details', () async {
      final logs = <String>[];
      final subscription = logger.logStream.listen(logs.add);

      logger.error('Error message');

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logs, contains('[ERROR] Error message'));
      await subscription.cancel();
    });

    test('should emit logs to stream when error is called with custom error details', () async {
      final logs = <String>[];
      final subscription = logger.logStream.listen(logs.add);

      logger.error('Error message', 'details_error', StackTrace.empty);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(logs, contains('[ERROR] Error message: details_error'));
      await subscription.cancel();
    });

    test('should close stream when dispose is called', () async {
      final loggerToDispose = AppLogger();
      expect(loggerToDispose.logStream, emitsDone);
      loggerToDispose.dispose();
    });
  });
}
