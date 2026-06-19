import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_impression.dart';

class MockAdsRepository implements AdsRepository {
  String? lastUclid;
  String? lastImpressionTrackingUrl;

  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    lastUclid = uclid;
    lastImpressionTrackingUrl = impressionTrackingUrl;
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late TrackImpressionUseCase useCase;
  late MockAdsRepository mockRepository;

  setUp(() {
    mockRepository = MockAdsRepository();
    useCase = TrackImpressionUseCase(mockRepository);
  });

  test('should pass parameters to repository and return Success', () async {
    final params = TrackImpressionParams(
      uclid: '123',
      impressionTrackingUrl: 'https://imp.url',
    );

    final result = await useCase(params);

    expect(result.isSuccess, true);
    expect(mockRepository.lastUclid, '123');
    expect(mockRepository.lastImpressionTrackingUrl, 'https://imp.url');
  });
}
