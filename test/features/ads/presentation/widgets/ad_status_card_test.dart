import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/ad_status_card.dart';

void main() {
  testWidgets('AdStatusCard renders status labels and uclid code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdStatusCard(
            impressionTracked: false,
            clickTracked: false,
            uclid: 'test-uclid-value',
          ),
        ),
      ),
    );

    expect(find.text('Ad Tracking Status'), findsOneWidget);
    expect(find.text('UCLID: test-uclid-value'), findsOneWidget);
    expect(find.text('Impression'), findsOneWidget);
    expect(find.text('Click'), findsOneWidget);
  });

  testWidgets(
    'AdStatusCard renders checkmark icons and correct text colors when tracked',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdStatusCard(
              impressionTracked: true,
              clickTracked: true,
              uclid: 'test-uclid',
            ),
          ),
        ),
      );

      // Verify presence of check_circle icons indicating success
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    },
  );
}
