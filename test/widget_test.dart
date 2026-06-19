import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ads_sdk_integration/app/app.dart';
import 'package:ads_sdk_integration/core/di/dependency_injection.dart';
import 'package:ads_sdk_integration/features/ads/data/models/ads_response_model.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
  });

  testWidgets('Home page shows load ad button initially', (
    WidgetTester tester,
  ) async {
    await initDI();

    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('Ready to Load Ad'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  test(
    'AdsResponseModel parses both wrapped and unwrapped JSON structures',
    () {
      final rawUnwrapped = {
        'ads': {
          'banner_ads': [
            {
              'impression_tracking_url': 'https://t.o-s.io/events?uclid=123',
              'click_tracking_url': 'https://t.o-s.io/click?uclid=456',
              'elements': {
                'value': 'https://image.url/1.png',
                'destination_url': 'https://dest.url/1',
              },
            },
          ],
        },
      };

      final rawWrapped = {
        'status': true,
        'response': {
          'code': 200,
          'data': {
            'ads': {
              'banner_ads': [
                {
                  'impression_tracking_url':
                      'https://t.o-s.io/events?uclid=123',
                  'click_tracking_url': 'https://t.o-s.io/click?uclid=456',
                  'elements': {
                    'value': 'https://image.url/1.png',
                    'destination_url': 'https://dest.url/1',
                  },
                },
              ],
            },
          },
        },
      };

      final unwrappedModel = AdsResponseModel.fromJson(rawUnwrapped);
      final wrappedModel = AdsResponseModel.fromJson(rawWrapped);

      expect(unwrappedModel.bannerAds.length, 1);
      expect(
        unwrappedModel.bannerAds.first.elements?.value,
        'https://image.url/1.png',
      );
      expect(unwrappedModel.bannerAds.first.uclid, '456');

      expect(wrappedModel.bannerAds.length, 1);
      expect(
        wrappedModel.bannerAds.first.elements?.value,
        'https://image.url/1.png',
      );
      expect(wrappedModel.bannerAds.first.uclid, '456');
    },
  );
}
