import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/banner_ad_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final log = <MethodCall>[];
  bool canLaunchResult = true;
  bool launchResult = true;
  bool shouldThrowOnCanLaunch = false;
  bool shouldThrowOnLaunch = false;

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  setUp(() {
    log.clear();
    canLaunchResult = true;
    launchResult = true;
    shouldThrowOnCanLaunch = false;
    shouldThrowOnLaunch = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'canLaunch') {
        if (shouldThrowOnCanLaunch) {
          throw Exception('CanLaunch error');
        }
        return canLaunchResult;
      } else if (methodCall.method == 'launch') {
        if (shouldThrowOnLaunch) {
          throw Exception('Launch error');
        }
        return launchResult;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('BannerAdWidget renders image matching AdEntity parameters', (
    WidgetTester tester,
  ) async {
    final ad = AdEntity(
      imageUrl: 'https://image.url/ad.png',
      destinationUrl: 'https://dest.url',
      uclid: '123',
      width: 300,
      height: 250,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerAdWidget(ad: ad, onImpression: () {}, onAdClick: () {}),
        ),
      ),
    );

    // Verify presence of CachedNetworkImage
    expect(find.byType(CachedNetworkImage), findsOneWidget);

    // Find the AspectRatio widget and verify calculated ratio (300 / 250 = 1.2)
    final AspectRatio aspectRatioWidget = tester.widget(
      find.byType(AspectRatio),
    );
    expect(aspectRatioWidget.aspectRatio, 1.2);
  });

  testWidgets(
    'BannerAdWidget uses fallback 16:9 ratio when dimensions are null or invalid',
    (WidgetTester tester) async {
      final adNull = AdEntity(
        imageUrl: 'https://image.url/ad.png',
        destinationUrl: 'https://dest.url',
        uclid: '123',
        width: null,
        height: null,
      );

      final adZeroHeight = AdEntity(
        imageUrl: 'https://image.url/ad.png',
        destinationUrl: 'https://dest.url',
        uclid: '123',
        width: 300,
        height: 0,
      );

      // Null case
      await tester.pumpWidget(
        MaterialApp(
          key: const Key('null_ratio'),
          home: Scaffold(
            body: BannerAdWidget(ad: adNull, onImpression: () {}, onAdClick: () {}),
          ),
        ),
      );

      final AspectRatio aspectNull = tester.widget(find.byType(AspectRatio));
      expect(aspectNull.aspectRatio, 16 / 9);

      // Zero Height case
      await tester.pumpWidget(
        MaterialApp(
          key: const Key('zero_ratio'),
          home: Scaffold(
            body: BannerAdWidget(ad: adZeroHeight, onImpression: () {}, onAdClick: () {}),
          ),
        ),
      );

      final AspectRatio aspectZero = tester.widget(find.byType(AspectRatio));
      expect(aspectZero.aspectRatio, 16 / 9);
    },
  );

  testWidgets('tapping BannerAdWidget launches URL when canLaunch is true', (
    WidgetTester tester,
  ) async {
    bool clicked = false;
    final ad = AdEntity(
      imageUrl: 'https://image.url/ad.png',
      destinationUrl: 'https://dest.url',
      uclid: '123',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerAdWidget(
            ad: ad,
            onImpression: () {},
            onAdClick: () => clicked = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BannerAdWidget));
    await tester.pump(const Duration(milliseconds: 100));

    expect(clicked, isTrue);
    expect(log.map((m) => m.method), contains('canLaunch'));
    expect(log.map((m) => m.method), contains('launch'));
  });

  testWidgets(
    'tapping BannerAdWidget falls back to direct launch if canLaunch is false but launch succeeds',
    (WidgetTester tester) async {
      bool clicked = false;
      canLaunchResult = false;
      launchResult = true;

      final ad = AdEntity(
        imageUrl: 'https://image.url/ad.png',
        destinationUrl: 'https://dest.url',
        uclid: '123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              ad: ad,
              onImpression: () {},
              onAdClick: () => clicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BannerAdWidget));
      await tester.pump(const Duration(milliseconds: 100));

      expect(clicked, isTrue);
      expect(log.map((m) => m.method), contains('canLaunch'));
      expect(log.map((m) => m.method), contains('launch'));
    },
  );

  testWidgets(
    'tapping BannerAdWidget shows SnackBar if launcher fails completely',
    (WidgetTester tester) async {
      bool clicked = false;
      canLaunchResult = false;
      shouldThrowOnLaunch = true;

      final ad = AdEntity(
        imageUrl: 'https://image.url/ad.png',
        destinationUrl: 'https://dest.url',
        uclid: '123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              ad: ad,
              onImpression: () {},
              onAdClick: () => clicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BannerAdWidget));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Let SnackBar animate in

      expect(clicked, isFalse);
      expect(find.text('Could not launch https://dest.url'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping BannerAdWidget handles exception and triggers fallback launch',
    (WidgetTester tester) async {
      bool clicked = false;
      shouldThrowOnCanLaunch = true;

      final ad = AdEntity(
        imageUrl: 'https://image.url/ad.png',
        destinationUrl: 'https://dest.url',
        uclid: '123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(
              ad: ad,
              onImpression: () {},
              onAdClick: () => clicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BannerAdWidget));
      await tester.pump(const Duration(milliseconds: 100));

      expect(clicked, isTrue);
      expect(log.map((m) => m.method), contains('canLaunch'));
      expect(log.map((m) => m.method), contains('launch'));
    },
  );
}
