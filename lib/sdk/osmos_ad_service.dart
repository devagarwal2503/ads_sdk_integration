import 'package:ads_sdk_integration/core/constants/api_constants.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';
import 'osmos_initializer.dart';

/// Wrapper service for handling SDK ad retrieval operations.
/// Isolates the direct Osmos SDK ad-fetching API from domain layers.
class OsmosAdService {
  final OsmosInitializer _osmosInitializer;
  final AppLogger _logger;

  OsmosAdService(this._osmosInitializer, this._logger);

  /// Fetches display ads from the Osmos SDK using the designated Ad Unit (AU).
  ///
  /// Requests configured parameters:
  /// - [ApiConstants.cliUbid]: Ubiquitous ID to identify client layout segment.
  /// - [ApiConstants.pageType]: Demarcator indicating the type of simulator view.
  /// - [ApiConstants.adUnit]: Specific banner segment identifier.
  ///
  /// Returns the raw map payload returned by the native plugin, or throws on failure.
  Future<Map<String, dynamic>?> fetchDisplayAds() async {
    _logger.info(
      'Fetching Display Ads via Osmos SDK (pageType: ${ApiConstants.pageType}, adUnit: ${ApiConstants.adUnit})...',
    );
    try {
      final sdk = _osmosInitializer.sdk;
      final response = await sdk.adFetcher.fetchDisplayAdsWithAu(
        cliUbid: ApiConstants.cliUbid,
        pageType: ApiConstants.pageType,
        productCount: 1,
        adUnits: [ApiConstants.adUnit],
      );
      _logger.info('Ad response received successfully from SDK.');
      _logger.debug('Ad response payload: $response');
      return response;
    } catch (e, stack) {
      _logger.error('Error fetching ads from SDK', e, stack);
      rethrow;
    }
  }
}
