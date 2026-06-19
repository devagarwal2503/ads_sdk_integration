import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';

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
