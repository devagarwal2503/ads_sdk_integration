import 'package:osmos_flutter_plugin/core/osmos_sdk.dart';
import 'package:ads_sdk_integration/core/constants/app_constants.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';

/// Service responsible for bootstrapping and managing the lifespan of the third-party Osmos SDK.
/// Handles initial configuration parameters and abstracts native SDK lifecycle issues.
class OsmosInitializer {
  final AppLogger _logger;
  bool _isInitialized = false;
  OsmosSDK? _sdk;

  OsmosInitializer(this._logger);

  /// Status flag indicating whether the SDK was successfully initialized.
  bool get isInitialized => _isInitialized;

  /// Retrieves the active instance of the Osmos SDK.
  /// Throws [StateError] if the SDK has not yet been initialized.
  OsmosSDK get sdk {
    if (_sdk == null) {
      throw StateError('Osmos SDK is not initialized. Call init() first.');
    }
    return _sdk!;
  }

  /// Initializes the Osmos SDK with parameters defined in [AppConstants].
  /// Includes fallback logic to capture and resolve standard native singleton conflicts
  /// caused by Hot Restarts (where Dart state resets but the native process survives).
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _logger.info(
        'Initializing Osmos SDK with Client ID: ${AppConstants.clientId}',
      );

      final builder = OsmosSDK.clientId(AppConstants.clientId)
          .displayAdsHost(AppConstants.displayAdsHost)
          .productAdsHost(AppConstants.productAdsHost)
          .debug(true);

      try {
        // Attempt standard global singleton registration
        await builder.buildGlobalInstance();
        _sdk = OsmosSDK.globalInstance();
      } catch (e) {
        final errorStr = e.toString();
        // If the native side already has an active singleton (common on Hot Restarts),
        // build a local instance instead to avoid crashing the bootstrapping pipeline.
        if (errorStr.contains('ERROR_ALREADY_INITIALIZED')) {
          _logger.info(
            'Osmos SDK already initialized on native side. Falling back to build().',
          );
          _sdk = await builder.build();
        } else {
          rethrow;
        }
      }

      _isInitialized = true;
      _logger.info('Osmos SDK initialized successfully.');
    } catch (e, stack) {
      _logger.error('Failed to initialize Osmos SDK', e, stack);
      _isInitialized = false;
      rethrow;
    }
  }
}
