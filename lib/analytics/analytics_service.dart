import 'package:ads_sdk_integration/core/logger/app_logger.dart';

class AnalyticsService {
  final AppLogger _logger;

  AnalyticsService(this._logger);

  void logAdLoaded() {
    _logger.info('Analytics Event: Ad Loaded Successfully');
  }

  void logImpression() {
    _logger.info('Analytics Event: Impression Fired (50%+ Visibility)');
  }

  void logClick() {
    _logger.info('Analytics Event: Ad Click Fired');
  }

  void logFailure(String message) {
    _logger.error('Analytics Event: Ad Error/Failure - $message');
  }
}
