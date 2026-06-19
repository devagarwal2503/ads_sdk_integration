import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../sdk/osmos_event_service.dart';
import '../../../../sdk/osmos_initializer.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/repository/ads_repository.dart';
import '../datasource/ads_remote_datasource.dart';

class AdsRepositoryImpl implements AdsRepository {
  final AdsRemoteDataSource remoteDataSource;
  final OsmosEventService osmosEventService;
  final OsmosInitializer osmosInitializer;

  AdsRepositoryImpl({
    required this.remoteDataSource,
    required this.osmosEventService,
    required this.osmosInitializer,
  });

  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async {
    try {
      if (!osmosInitializer.isInitialized) {
        await osmosInitializer.init();
      }

      final adsResponse = await remoteDataSource.fetchDisplayAds();
      if (adsResponse.bannerAds.isEmpty) {
        return const FailureResult(
          ServerFailure('No ads returned in response'),
        );
      }

      final adModel = adsResponse.bannerAds.first;
      final elements = adModel.elements;

      if (elements == null || elements.value.isEmpty) {
        return const FailureResult(
          ServerFailure('Ad element image value is missing'),
        );
      }

      final adEntity = AdEntity(
        imageUrl: elements.value,
        destinationUrl: elements.destinationUrl.isNotEmpty
            ? elements.destinationUrl
            : (adModel.clickTrackingUrl ?? ''),
        impressionTrackingUrl: adModel.impressionTrackingUrl,
        clickTrackingUrl: adModel.clickTrackingUrl,
        width: adModel.width,
        height: adModel.height,
        uclid: adModel.uclid ?? 'unknown',
      );

      return Success(adEntity);
    } catch (e) {
      return FailureResult(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    try {
      await osmosEventService.trackImpression(
        uclid: uclid,
        impressionTrackingUrl: impressionTrackingUrl,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    try {
      await osmosEventService.trackClick(
        uclid: uclid,
        clickTrackingUrl: clickTrackingUrl,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(UnexpectedFailure(e.toString()));
    }
  }
}
