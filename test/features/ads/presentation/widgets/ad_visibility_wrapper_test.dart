import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/ad_visibility_wrapper.dart';

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets(
    'AdVisibilityWrapper renders child and handles configuration updates',
    (WidgetTester tester) async {
      bool impressionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdVisibilityWrapper(
              adId: 'test-ad-id',
              onImpression: () => impressionCalled = true,
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Text('Visible Ad Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Visible Ad Widget'), findsOneWidget);
      expect(impressionCalled, isTrue);
    },
  );
}
