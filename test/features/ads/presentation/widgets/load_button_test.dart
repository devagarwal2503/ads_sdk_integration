import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/load_button.dart';

void main() {
  testWidgets('LoadButton renders label and icon and responds to taps', (
    WidgetTester tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadButton(
            label: 'Test Button',
            icon: Icons.cloud_download,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_download), findsOneWidget);

    await tester.tap(find.byType(LoadButton));
    await tester.pump();

    expect(pressed, true);
  });
}
