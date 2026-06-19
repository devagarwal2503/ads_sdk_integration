import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';

/// Usecase responsible for fetching display advertisements from the repository.
///
/// Returns a [Result] containing [AdEntity] on success, or [Failure] on error.
class FetchBannerAdUseCase {
  final AdsRepository repository;

  FetchBannerAdUseCase(this.repository);

  /// Executes the ad retrieval request.
  Future<Result<AdEntity, Failure>> call() {
    return repository.fetchBannerAd();
  }
}
