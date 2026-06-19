import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';

/// Request parameters required to record an impression.
class TrackImpressionParams {
  /// The unique click/impression tracking ID.
  final String uclid;

  /// Optional server endpoint to trigger a direct HTTP ping for validation.
  final String? impressionTrackingUrl;

  TrackImpressionParams({required this.uclid, this.impressionTrackingUrl});
}

/// Usecase responsible for reporting ad impression views back to the repository analytics layer.
class TrackImpressionUseCase {
  final AdsRepository repository;

  TrackImpressionUseCase(this.repository);

  /// Fires the impression request with parameters specified in [TrackImpressionParams].
  Future<Result<void, Failure>> call(TrackImpressionParams params) {
    return repository.trackImpression(
      uclid: params.uclid,
      impressionTrackingUrl: params.impressionTrackingUrl,
    );
  }
}
