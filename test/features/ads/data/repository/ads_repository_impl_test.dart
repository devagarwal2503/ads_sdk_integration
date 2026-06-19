import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmos_flutter_plugin/core/osmos_sdk.dart';
import 'package:osmos_flutter_plugin/utils/osmos_error_codes.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';
import 'package:ads_sdk_integration/sdk/osmos_event_service.dart';
import 'package:ads_sdk_integration/sdk/osmos_initializer.dart';
import 'package:ads_sdk_integration/features/ads/data/datasource/ads_remote_datasource.dart';
import 'package:ads_sdk_integration/features/ads/data/models/ad_model.dart';
import 'package:ads_sdk_integration/features/ads/data/models/ads_response_model.dart';
import 'package:ads_sdk_integration/features/ads/data/models/element_model.dart';
import 'package:ads_sdk_integration/features/ads/data/repository/ads_repository_impl.dart';

class MockAdsRemoteDataSource implements AdsRemoteDataSource {
  AdsResponseModel? fetchResult;
  @override
  Future<AdsResponseModel> fetchDisplayAds() async {
    if (fetchResult == null) throw Exception('Unexpected error');
    return fetchResult!;
  }
}

class FakeAppLogger implements AppLogger {
  @override
  void info(String m) {}
  @override
  void debug(String m) {}
  @override
  void warning(String m) {}
  @override
  void error(String m, [dynamic e, StackTrace? s]) {}
  @override
  void dispose() {}
  @override
  Stream<String> get logStream => const Stream.empty();
}

class MockOsmosEventService implements OsmosEventService {
  String? lastImpressionUclid;
  String? lastImpressionUrl;
  String? lastClickUclid;
  String? lastClickUrl;

  @override
  Future<void> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    lastImpressionUclid = uclid;
    lastImpressionUrl = impressionTrackingUrl;
  }

  @override
  Future<void> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    lastClickUclid = uclid;
    lastClickUrl = clickTrackingUrl;
  }
}

class MockOsmosInitializer implements OsmosInitializer {
  @override
  bool isInitialized = false;

  @override
  OsmosSDK get sdk => throw UnimplementedError();

  int initCount = 0;
  @override
  Future<void> init() async {
    initCount++;
    isInitialized = true;
  }
}

void main() {
  late AdsRepositoryImpl repository;
  late MockAdsRemoteDataSource mockRemoteDataSource;
  late MockOsmosEventService mockEventService;
  late MockOsmosInitializer mockInitializer;

  setUp(() {
    mockRemoteDataSource = MockAdsRemoteDataSource();
    mockEventService = MockOsmosEventService();
    mockInitializer = MockOsmosInitializer();

    repository = AdsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      osmosEventService: mockEventService,
      osmosInitializer: mockInitializer,
    );
  });

  final tAdModel = AdModel(
    width: 300,
    height: 250,
    impressionTrackingUrl: 'https://imp.url',
    clickTrackingUrl: 'https://click.url',
    uclid: '123',
    elements: const ElementModel(
      value: 'https://image.url',
      destinationUrl: 'https://dest.url',
    ),
  );

  group('fetchBannerAd', () {
    test('should initialize SDK if not already initialized', () async {
      mockInitializer.isInitialized = false;
      mockRemoteDataSource.fetchResult = AdsResponseModel(
        bannerAds: [tAdModel],
      );

      await repository.fetchBannerAd();

      expect(mockInitializer.initCount, 1);
    });

    test('should return AdEntity mapped properly on success', () async {
      mockInitializer.isInitialized = true;
      mockRemoteDataSource.fetchResult = AdsResponseModel(
        bannerAds: [tAdModel],
      );

      final result = await repository.fetchBannerAd();

      expect(result.isSuccess, true);
      final ad = result.success;
      expect(ad.imageUrl, 'https://image.url');
      expect(ad.destinationUrl, 'https://dest.url');
      expect(ad.uclid, '123');
    });

    test(
      'should return clickTrackingUrl as destinationUrl if destinationUrl is empty',
      () async {
        final adNoDest = AdModel(
          width: 300,
          height: 250,
          impressionTrackingUrl: 'https://imp.url',
          clickTrackingUrl: 'https://click.url',
          uclid: '123',
          elements: const ElementModel(
            value: 'https://image.url',
            destinationUrl: '',
          ),
        );

        mockInitializer.isInitialized = true;
        mockRemoteDataSource.fetchResult = AdsResponseModel(
          bannerAds: [adNoDest],
        );

        final result = await repository.fetchBannerAd();

        expect(result.isSuccess, true);
        expect(result.success.destinationUrl, 'https://click.url');
      },
    );

    test(
      'should return FailureResult when remote data source returns empty list',
      () async {
        mockInitializer.isInitialized = true;
        mockRemoteDataSource.fetchResult = const AdsResponseModel(
          bannerAds: [],
        );

        final result = await repository.fetchBannerAd();

        expect(result.isFailure, true);
        expect(result.failure, isA<EmptyAdFailure>());
      },
    );

    test(
      'should return FailureResult when remote datasource throws exception',
      () async {
        mockInitializer.isInitialized = true;
        mockRemoteDataSource.fetchResult = null; // Throws error

        final result = await repository.fetchBannerAd();

        expect(result.isFailure, true);
        expect(result.failure, isA<UnexpectedFailure>());
      },
    );

    test(
      'should return NetworkFailure when remote datasource throws network exception',
      () async {
        mockInitializer.isInitialized = true;

        final customMockDS = MockNetworkExceptionDataSource();
        final customRepo = AdsRepositoryImpl(
          remoteDataSource: customMockDS,
          osmosEventService: mockEventService,
          osmosInitializer: mockInitializer,
        );

        final result = await customRepo.fetchBannerAd();

        expect(result.isFailure, true);
        expect(result.failure, isA<NetworkFailure>());
        expect(result.failure.message, contains('connection'));
      },
    );

    test(
      'should return NetworkFailure when remote datasource throws OsmosException wrapping a native connection error',
      () async {
        mockInitializer.isInitialized = true;

        final customMockDS = MockOsmosNetworkExceptionDataSource();
        final customRepo = AdsRepositoryImpl(
          remoteDataSource: customMockDS,
          osmosEventService: mockEventService,
          osmosInitializer: mockInitializer,
        );

        final result = await customRepo.fetchBannerAd();

        expect(result.isFailure, true);
        expect(result.failure, isA<NetworkFailure>());
        expect(result.failure.message, contains('No internet connection'));
      },
    );
  });

  group('trackImpression', () {
    test(
      'should call osmosEventService.trackImpression and return Success',
      () async {
        final result = await repository.trackImpression(
          uclid: '123',
          impressionTrackingUrl: 'https://imp.url',
        );

        expect(result.isSuccess, true);
        expect(mockEventService.lastImpressionUclid, '123');
        expect(mockEventService.lastImpressionUrl, 'https://imp.url');
      },
    );
  });

  group('trackClick', () {
    test(
      'should call osmosEventService.trackClick and return Success',
      () async {
        final result = await repository.trackClick(
          uclid: '123',
          clickTrackingUrl: 'https://click.url',
        );

        expect(result.isSuccess, true);
        expect(mockEventService.lastClickUclid, '123');
        expect(mockEventService.lastClickUrl, 'https://click.url');
      },
    );
  });
}

class MockNetworkExceptionDataSource implements AdsRemoteDataSource {
  @override
  Future<AdsResponseModel> fetchDisplayAds() async {
    throw const SocketException('Connection failed');
  }
}

class MockOsmosNetworkExceptionDataSource implements AdsRemoteDataSource {
  @override
  Future<AdsResponseModel> fetchDisplayAds() async {
    throw OsmosException(
      errorCode: OsmosErrorCodes.fetchDisplayAdsError,
      details: 'Unable to connect to host dev-hub.osmos.ai',
      nativeError: PlatformException(
        code: 'FETCH_DISPLAY_ADS_ERROR',
        message: 'java.net.UnknownHostException: Unable to resolve host',
      ),
    );
  }
}
