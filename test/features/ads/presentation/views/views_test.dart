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
import 'package:ads_sdk_integration/features/ads/presentation/views/ad_simulator_view.dart';
import 'package:ads_sdk_integration/features/ads/presentation/views/ad_verifier_view.dart';
import 'package:ads_sdk_integration/features/ads/presentation/views/console_logs_view.dart';
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

  final tAdEntity = AdEntity(
    imageUrl: 'https://image.url',
    destinationUrl: 'https://dest.url',
    uclid: '123',
    impressionTrackingUrl: 'https://imp.url',
    clickTrackingUrl: 'https://click.url',
    width: 300,
    height: 250,
  );

  group('AdSimulatorView Tests', () {
    testWidgets('renders initial state with load button', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(AdInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdSimulatorView(),
            ),
          ),
        ),
      );

      expect(find.text('Ready to Load Ad'), findsOneWidget);
      expect(find.text('Load Display Ad'), findsOneWidget);

      await tester.tap(find.text('Load Display Ad'));
      await tester.pump();

      expect(bloc.dispatchedEvents.first, isA<LoadBannerAd>());
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      final bloc = FakeAdBloc(AdLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdSimulatorView(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders loaded state with sponsored ad feed content', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(AdLoaded(ad: tAdEntity));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdSimulatorView(),
            ),
          ),
        ),
      );

      expect(find.text('DEMO FEED CONTENT (SCROLL DOWN)'), findsOneWidget);
      expect(find.text('SPONSORED ADVERTISEMENT'), findsOneWidget);
    });

    testWidgets('renders empty state with retry option', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(const AdEmpty(message: 'No ads'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdSimulatorView(),
            ),
          ),
        ),
      );

      expect(find.text('No Ads Available'), findsOneWidget);
      expect(find.text('No ads'), findsOneWidget);
      expect(find.text('Retry Fetch'), findsOneWidget);

      await tester.tap(find.text('Retry Fetch'));
      await tester.pump();

      expect(bloc.dispatchedEvents.first, isA<RetryLoadingAd>());
    });

    testWidgets('renders error state with retry option', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(const AdError('Error msg'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdSimulatorView(),
            ),
          ),
        ),
      );

      expect(find.text('Ad Loading Failed'), findsOneWidget);
      expect(find.text('Error msg'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(bloc.dispatchedEvents.first, isA<RetryLoadingAd>());
    });
  });

  group('AdVerifierView Tests', () {
    testWidgets('renders empty active ad session diagnostics placeholder', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(AdInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdVerifierView(),
            ),
          ),
        ),
      );

      expect(find.text('No Active Ad Session'), findsOneWidget);
    });

    testWidgets('renders status data cards when ad session is active', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(AdLoaded(ad: tAdEntity));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const AdVerifierView(),
            ),
          ),
        ),
      );

      expect(find.text('AD SESSION DIAGNOSTICS'), findsOneWidget);
      expect(find.text('SDK ANALYTICS DATA'), findsOneWidget);
      expect(find.text('Image URL'), findsOneWidget);
    });
  });

  group('ConsoleLogsView Tests', () {
    testWidgets('renders log statements in monospace console viewport', (
      WidgetTester tester,
    ) async {
      final bloc = FakeAdBloc(AdInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AdBloc>.value(
              value: bloc,
              child: const ConsoleLogsView(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('[INFO] Test Event Log Statement'), findsOneWidget);
      expect(find.text('Auto-scroll'), findsOneWidget);
    });
  });
}
