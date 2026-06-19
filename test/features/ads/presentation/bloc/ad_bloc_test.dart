import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/analytics/analytics_service.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/fetch_banner_ad.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_click.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_impression.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_event.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_state.dart';

class FakeAdsRepository implements AdsRepository {
  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async =>
      throw UnimplementedError();

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async => throw UnimplementedError();
}

class MockFetchBannerAdUseCase extends FetchBannerAdUseCase {
  MockFetchBannerAdUseCase() : super(FakeAdsRepository());
  Result<AdEntity, Failure>? result;

  @override
  Future<Result<AdEntity, Failure>> call() async {
    return result ?? const FailureResult(ServerFailure('Not set'));
  }
}

class MockTrackImpressionUseCase extends TrackImpressionUseCase {
  MockTrackImpressionUseCase() : super(FakeAdsRepository());
  TrackImpressionParams? lastParams;

  @override
  Future<Result<void, Failure>> call(TrackImpressionParams params) async {
    lastParams = params;
    return const Success(null);
  }
}

class MockTrackClickUseCase extends TrackClickUseCase {
  MockTrackClickUseCase() : super(FakeAdsRepository());
  TrackClickParams? lastParams;

  @override
  Future<Result<void, Failure>> call(TrackClickParams params) async {
    lastParams = params;
    return const Success(null);
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

class MockAnalyticsService extends AnalyticsService {
  MockAnalyticsService() : super(FakeAppLogger());
  int adLoadedCount = 0;
  int failureCount = 0;
  int impressionCount = 0;
  int clickCount = 0;

  @override
  void logAdLoaded() => adLoadedCount++;
  @override
  void logFailure(String message) => failureCount++;
  @override
  void logImpression() => impressionCount++;
  @override
  void logClick() => clickCount++;
}

void main() {
  late AdBloc bloc;
  late MockFetchBannerAdUseCase mockFetchBannerAd;
  late MockTrackImpressionUseCase mockTrackImpression;
  late MockTrackClickUseCase mockTrackClick;
  late MockAnalyticsService mockAnalytics;

  final tAdEntity = AdEntity(
    imageUrl: 'https://image.url',
    destinationUrl: 'https://dest.url',
    uclid: '123',
    impressionTrackingUrl: 'https://imp.url',
    clickTrackingUrl: 'https://click.url',
    width: 300,
    height: 250,
  );

  setUp(() {
    mockFetchBannerAd = MockFetchBannerAdUseCase();
    mockTrackImpression = MockTrackImpressionUseCase();
    mockTrackClick = MockTrackClickUseCase();
    mockAnalytics = MockAnalyticsService();

    bloc = AdBloc(
      fetchBannerAdUseCase: mockFetchBannerAd,
      trackImpressionUseCase: mockTrackImpression,
      trackClickUseCase: mockTrackClick,
      analytics: mockAnalytics,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be AdInitial', () {
    expect(bloc.state, isA<AdInitial>());
  });

  group('LoadBannerAd event', () {
    test(
      'should emit [AdLoading, AdLoaded] and log analytics when call succeeds',
      () async {
        mockFetchBannerAd.result = Success<AdEntity, Failure>(tAdEntity);

        final expectedStates = [
          isA<AdLoading>(),
          isA<AdLoaded>().having((s) => s.ad, 'ad', tAdEntity),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(LoadBannerAd());

        await until(() => mockAnalytics.adLoadedCount > 0);
        expect(mockAnalytics.adLoadedCount, 1);
      },
    );

    test(
      'should emit [AdLoading, AdError] and log analytics when call fails',
      () async {
        mockFetchBannerAd.result = const FailureResult<AdEntity, Failure>(
          ServerFailure('Load Error'),
        );

        final expectedStates = [
          isA<AdLoading>(),
          isA<AdError>().having((s) => s.message, 'message', 'Load Error'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(LoadBannerAd());

        await until(() => mockAnalytics.failureCount > 0);
        expect(mockAnalytics.failureCount, 1);
      },
    );

    test(
      'should emit [AdLoading, AdEmpty] and log analytics when empty failure is returned',
      () async {
        mockFetchBannerAd.result = const FailureResult<AdEntity, Failure>(
          EmptyAdFailure('Empty Error'),
        );

        final expectedStates = [
          isA<AdLoading>(),
          isA<AdEmpty>().having((s) => s.message, 'message', 'Empty Error'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(LoadBannerAd());

        await until(() => mockAnalytics.failureCount > 0);
        expect(mockAnalytics.failureCount, 1);
      },
    );
  });

  group('Tracking events', () {
    test(
      'ImpressionDetected event should emit copy of AdLoaded and call TrackImpressionUseCase',
      () async {
        bloc.emit(AdLoaded(ad: tAdEntity));

        final expectedStates = [
          isA<AdLoaded>().having(
            (s) => s.impressionTracked,
            'impressionTracked',
            true,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(ImpressionDetected());

        await until(() => mockAnalytics.impressionCount > 0);
        expect(mockAnalytics.impressionCount, 1);
        expect(mockTrackImpression.lastParams?.uclid, tAdEntity.uclid);
        expect(
          mockTrackImpression.lastParams?.impressionTrackingUrl,
          tAdEntity.impressionTrackingUrl,
        );
      },
    );

    test(
      'BannerClicked event should emit copy of AdLoaded and call TrackClickUseCase',
      () async {
        bloc.emit(AdLoaded(ad: tAdEntity));

        final expectedStates = [
          isA<AdLoaded>().having((s) => s.clickTracked, 'clickTracked', true),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(BannerClicked());

        await until(() => mockAnalytics.clickCount > 0);
        expect(mockAnalytics.clickCount, 1);
        expect(mockTrackClick.lastParams?.uclid, tAdEntity.uclid);
        expect(
          mockTrackClick.lastParams?.clickTrackingUrl,
          tAdEntity.clickTrackingUrl,
        );
      },
    );

    test('ResetBanner event should emit AdInitial', () async {
      bloc.emit(AdLoaded(ad: tAdEntity));

      final expectedStates = [isA<AdInitial>()];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(ResetBanner());
    });
  });

  group('AdEvent and AdState properties', () {
    test('AdEvent props', () {
      expect(LoadBannerAd().props, isEmpty);
      expect(RetryLoadingAd().props, isEmpty);
      expect(ImpressionDetected().props, isEmpty);
      expect(BannerClicked().props, isEmpty);
      expect(ResetBanner().props, isEmpty);
    });

    test('AdState props and copyWith', () {
      expect(AdInitial().props, isEmpty);
      expect(AdLoading().props, isEmpty);
      
      final state = AdLoaded(ad: tAdEntity);
      expect(state.props, [tAdEntity, false, false]);

      final stateCopy = state.copyWith();
      expect(stateCopy.ad, tAdEntity);
      expect(stateCopy.impressionTracked, false);
      expect(stateCopy.clickTracked, false);

      final stateCopyCustom = state.copyWith(
        impressionTracked: true,
        clickTracked: true,
      );
      expect(stateCopyCustom.impressionTracked, true);
      expect(stateCopyCustom.clickTracked, true);

      const emptyState = AdEmpty();
      expect(emptyState.props, ['Ad not available']);

      const errorState = AdError('test error');
      expect(errorState.props, ['test error']);
    });
  });
}

// Utility helper to wait for condition in async tests
Future<void> until(bool Function() condition) async {
  final start = DateTime.now();
  while (DateTime.now().difference(start).inMilliseconds < 1000) {
    if (condition()) return;
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
