import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/ad_entity.dart';

abstract class AdsRepository {
  Future<Result<AdEntity, Failure>> fetchBannerAd();
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  });
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  });
}
