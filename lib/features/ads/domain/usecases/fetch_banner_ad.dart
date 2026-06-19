import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/ad_entity.dart';
import '../repository/ads_repository.dart';

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
