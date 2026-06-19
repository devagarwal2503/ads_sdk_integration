import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/fetch_banner_ad.dart';

class MockAdsRepository implements AdsRepository {
  Result<AdEntity, Failure>? fetchResult;

  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async {
    return fetchResult ?? const FailureResult(ServerFailure('Not set'));
  }

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    return const Success(null);
  }
}

void main() {
  late FetchBannerAdUseCase useCase;
  late MockAdsRepository mockRepository;

  setUp(() {
    mockRepository = MockAdsRepository();
    useCase = FetchBannerAdUseCase(mockRepository);
  });

  final tAdEntity = AdEntity(
    imageUrl: 'https://image.url',
    destinationUrl: 'https://dest.url',
    uclid: '123',
    width: 300,
    height: 250,
  );

  test('should return AdEntity from repository on success', () async {
    mockRepository.fetchResult = Success<AdEntity, Failure>(tAdEntity);

    final result = await useCase();

    expect(result.isSuccess, true);
    expect(result.success, tAdEntity);
  });

  test('should return Failure from repository on error', () async {
    const failure = ServerFailure('Server Error');
    mockRepository.fetchResult = const FailureResult<AdEntity, Failure>(
      failure,
    );

    final result = await useCase();

    expect(result.isFailure, true);
    expect(result.failure, failure);
  });
}
