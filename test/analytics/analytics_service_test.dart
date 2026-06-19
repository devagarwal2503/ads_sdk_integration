import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/analytics/analytics_service.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';

class MockLogger implements AppLogger {
  final List<String> infoLogs = [];
  final List<String> errorLogs = [];

  @override
  void info(String message) {
    infoLogs.add(message);
  }

  @override
  void debug(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    errorLogs.add(message);
  }

  @override
  void dispose() {}

  @override
  Stream<String> get logStream => const Stream.empty();
}

void main() {
  group('AnalyticsService Tests', () {
    late MockLogger mockLogger;
    late AnalyticsService analyticsService;

    setUp(() {
      mockLogger = MockLogger();
      analyticsService = AnalyticsService(mockLogger);
    });

    test('should log ad loaded event correctly', () {
      analyticsService.logAdLoaded();
      expect(mockLogger.infoLogs, contains('Analytics Event: Ad Loaded Successfully'));
    });

    test('should log impression event correctly', () {
      analyticsService.logImpression();
      expect(mockLogger.infoLogs, contains('Analytics Event: Impression Fired (50%+ Visibility)'));
    });

    test('should log click event correctly', () {
      analyticsService.logClick();
      expect(mockLogger.infoLogs, contains('Analytics Event: Ad Click Fired'));
    });

    test('should log failure event correctly', () {
      analyticsService.logFailure('Timeout Error');
      expect(mockLogger.errorLogs, contains('Analytics Event: Ad Error/Failure - Timeout Error'));
    });
  });
}
