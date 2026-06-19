import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/features/ads/data/models/ad_model.dart';

void main() {
  group('AdModel JSON Parsing & Fallbacks', () {
    test('should parse valid JSON with root width and height', () {
      final json = {
        'width': 300,
        'height': 250,
        'impression_tracking_url': 'https://t.o-s.io/imp?uclid=123',
        'click_tracking_url': 'https://t.o-s.io/click?uclid=456',
        'uclid': 'abc',
        'elements': {
          'value': 'https://image.url',
          'destination_url': 'https://destination.url',
        },
      };

      final model = AdModel.fromJson(json);

      expect(model.width, 300.0);
      expect(model.height, 250.0);
      expect(model.uclid, 'abc');
      expect(model.elements?.value, 'https://image.url');
      expect(model.elements?.destinationUrl, 'https://destination.url');
    });

    test(
      'should fallback to elements width and height when root values are missing',
      () {
        final json = {
          'impression_tracking_url': 'https://t.o-s.io/imp?uclid=123',
          'click_tracking_url': 'https://t.o-s.io/click?uclid=456',
          'elements': {
            'value': 'https://image.url',
            'destination_url': 'https://destination.url',
            'width': 200,
            'height': 200,
          },
        };

        final model = AdModel.fromJson(json);

        expect(model.width, 200.0);
        expect(model.height, 200.0);
      },
    );

    test(
      'should extract uclid from click tracking URL if uclid is missing at root',
      () {
        final json = {
          'click_tracking_url': 'https://t.o-s.io/click?uclid=test-uclid-click',
          'elements': {
            'value': 'https://image.url',
            'destination_url': 'https://destination.url',
          },
        };

        final model = AdModel.fromJson(json);

        expect(model.uclid, 'test-uclid-click');
      },
    );

    test(
      'should extract uclid from impression tracking URL if root and click tracking uclid are missing',
      () {
        final json = {
          'impression_tracking_url':
              'https://t.o-s.io/imp?uclid=test-uclid-imp',
          'elements': {
            'value': 'https://image.url',
            'destination_url': 'https://destination.url',
          },
        };

        final model = AdModel.fromJson(json);

        expect(model.uclid, 'test-uclid-imp');
      },
    );

    test('should output valid JSON map on toJson', () {
      final json = {
        'width': 300.0,
        'height': 250.0,
        'impression_tracking_url': 'https://t.o-s.io/imp',
        'click_tracking_url': 'https://t.o-s.io/click',
        'uclid': 'xyz',
        'elements': {
          'value': 'https://image.url',
          'destination_url': 'https://destination.url',
        },
      };

      final model = AdModel.fromJson(json);
      final generatedJson = model.toJson();

      expect(generatedJson['width'], 300.0);
      expect(generatedJson['height'], 250.0);
      expect(generatedJson['uclid'], 'xyz');
      expect(generatedJson['elements']['value'], 'https://image.url');
    });
  });
}
