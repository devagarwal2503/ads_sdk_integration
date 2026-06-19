import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repository/ads_repository.dart';

/// Request parameters required to record a click event.
class TrackClickParams {
  /// The unique click trace ID.
  final String uclid;

  /// Optional server endpoint to trigger a direct HTTP GET ping.
  final String? clickTrackingUrl;

  TrackClickParams({required this.uclid, this.clickTrackingUrl});
}

/// Usecase responsible for reporting ad click actions back to the repository analytics layer.
class TrackClickUseCase {
  final AdsRepository repository;

  TrackClickUseCase(this.repository);

  /// Fires the click tracking action using parameters specified in [TrackClickParams].
  Future<Result<void, Failure>> call(TrackClickParams params) {
    return repository.trackClick(
      uclid: params.uclid,
      clickTrackingUrl: params.clickTrackingUrl,
    );
  }
}
