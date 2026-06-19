import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_click.dart';

class MockAdsRepository implements AdsRepository {
  String? lastUclid;
  String? lastClickTrackingUrl;

  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    lastUclid = uclid;
    lastClickTrackingUrl = clickTrackingUrl;
    return const Success(null);
  }
}

void main() {
  late TrackClickUseCase useCase;
  late MockAdsRepository mockRepository;

  setUp(() {
    mockRepository = MockAdsRepository();
    useCase = TrackClickUseCase(mockRepository);
  });

  test('should pass parameters to repository and return Success', () async {
    final params = TrackClickParams(
      uclid: '123',
      clickTrackingUrl: 'https://click.url',
    );

    final result = await useCase(params);

    expect(result.isSuccess, true);
    expect(mockRepository.lastUclid, '123');
    expect(mockRepository.lastClickTrackingUrl, 'https://click.url');
  });
}
