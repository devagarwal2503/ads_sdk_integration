import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/fetch_banner_ad.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_click.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_impression.dart';
import 'package:ads_sdk_integration/analytics/analytics_service.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_bloc.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_event.dart';
import 'package:ads_sdk_integration/features/ads/presentation/bloc/ad_state.dart';
import 'package:ads_sdk_integration/features/ads/presentation/pages/home_page.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';

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

class FakeFetchBannerAdUseCase extends FetchBannerAdUseCase {
  FakeFetchBannerAdUseCase() : super(FakeAdsRepository());
}

class FakeTrackImpressionUseCase extends TrackImpressionUseCase {
  FakeTrackImpressionUseCase() : super(FakeAdsRepository());
}

class FakeTrackClickUseCase extends TrackClickUseCase {
  FakeTrackClickUseCase() : super(FakeAdsRepository());
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
  Stream<String> get logStream =>
      Stream.value('[INFO] Test Event Log Statement');
}

class FakeAnalytics extends AnalyticsService {
  FakeAnalytics() : super(FakeAppLogger());
}

class FakeAdBloc extends AdBloc {
  final List<AdEvent> dispatchedEvents = [];
  final AdState _mockState;

  FakeAdBloc(AdState initialState)
    : _mockState = initialState,
      super(
        fetchBannerAdUseCase: FakeFetchBannerAdUseCase(),
        trackImpressionUseCase: FakeTrackImpressionUseCase(),
        trackClickUseCase: FakeTrackClickUseCase(),
        analytics: FakeAnalytics(),
      );

  @override
  AdState get state => _mockState;

  @override
  void add(AdEvent event) {
    dispatchedEvents.add(event);
  }
}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<AppLogger>(FakeAppLogger());
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('HomePage renders tabs and handles navigation and reset clicks', (
    WidgetTester tester,
  ) async {
    final bloc = FakeAdBloc(AdInitial());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<AdBloc>.value(
            value: bloc,
            child: const HomePage(),
          ),
        ),
      ),
    );

    // Verify initial layout elements
    expect(find.text('OSMOS ADS INTEGRATION'), findsOneWidget);
    expect(find.text('Ad Simulator'), findsOneWidget);
    expect(find.text('Ad Verifier'), findsOneWidget);
    expect(find.text('Event Console'), findsOneWidget);

    // Tap Reset action button in AppBar
    final resetFinder = find.byTooltip('Reset State');
    expect(resetFinder, findsOneWidget);
    await tester.tap(resetFinder);
    await tester.pump();
    expect(bloc.dispatchedEvents.first, isA<ResetBanner>());

    // Switch to Ad Verifier Tab (Index 1)
    await tester.tap(find.text('Ad Verifier'));
    await tester.pump();

    // Switch to Event Console Tab (Index 2)
    await tester.tap(find.text('Event Console'));
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // Advance scroll delay
  });
}
