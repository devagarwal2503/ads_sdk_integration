import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/features/ads/presentation/widgets/loading_indicator.dart';

void main() {
  testWidgets('LoadingIndicator renders spinner and loading text labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingIndicator())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Fetching ad content...'), findsOneWidget);
  });
}
