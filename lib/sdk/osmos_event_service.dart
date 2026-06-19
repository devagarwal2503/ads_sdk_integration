import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/logger/app_logger.dart';
import 'osmos_initializer.dart';

/// Wrapper service for handling SDK event attribution and tracking.
/// Handles registerEvent calls to the native SDK, and triggers direct HTTP tracking URL pings.
class OsmosEventService {
  final OsmosInitializer _osmosInitializer;
  final AppLogger _logger;

  OsmosEventService(this._osmosInitializer, this._logger);

  /// Registers an ad impression with the native Osmos SDK and pings the tracking server.
  ///
  /// - [uclid]: The unique ad click/impression identifier.
  /// - [impressionTrackingUrl]: Optional URL for sending a redundant HTTP GET check to the ad server.
  Future<void> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    _logger.info('Registering impression event for uclid: $uclid');
    try {
      final sdk = _osmosInitializer.sdk;
      final result = await sdk.registerEvent.registerAdImpressionEvent(
        cliUbid: ApiConstants.cliUbid,
        uclid: uclid,
        position: 1,
      );
      _logger.info('Impression registered with SDK. Result: $result');
    } catch (e, stack) {
      _logger.error('Error registering impression with SDK', e, stack);
    }

    // Direct HTTP ping fallback for direct attribution verification
    if (impressionTrackingUrl != null && impressionTrackingUrl.isNotEmpty) {
      _logger.info(
        'Pinging raw impression tracking URL: $impressionTrackingUrl',
      );
      try {
        final response = await http.get(Uri.parse(impressionTrackingUrl));
        _logger.info('Impression URL ping status: ${response.statusCode}');
      } catch (e, stack) {
        _logger.error('Failed to ping raw impression URL', e, stack);
      }
    }
  }

  /// Registers an ad click with the native Osmos SDK and pings the click tracking server.
  ///
  /// - [uclid]: The unique ad identifier.
  /// - [clickTrackingUrl]: Optional URL for sending a redundant HTTP GET click attribution ping.
  Future<void> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    _logger.info('Registering click event for uclid: $uclid');
    try {
      final sdk = _osmosInitializer.sdk;
      final result = await sdk.registerEvent.registerAdClickEvent(
        cliUbid: ApiConstants.cliUbid,
        uclid: uclid,
      );
      _logger.info('Click registered with SDK. Result: $result');
    } catch (e, stack) {
      _logger.error('Error registering click with SDK', e, stack);
    }

    // Direct HTTP ping fallback for click redirect tracking
    if (clickTrackingUrl != null && clickTrackingUrl.isNotEmpty) {
      _logger.info('Pinging raw click tracking URL: $clickTrackingUrl');
      try {
        final response = await http.get(Uri.parse(clickTrackingUrl));
        _logger.info('Click URL ping status: ${response.statusCode}');
      } catch (e, stack) {
        _logger.error('Failed to ping raw click URL', e, stack);
      }
    }
  }
}
