import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/logger/app_logger.dart';
import 'package:ads_sdk_integration/sdk/osmos_ad_service.dart';
import 'package:ads_sdk_integration/sdk/osmos_event_service.dart';
import 'package:ads_sdk_integration/sdk/osmos_initializer.dart';
import 'package:osmos_flutter_plugin/core/osmos_sdk.dart';
import 'package:osmos_flutter_plugin/utils/osmos_error_codes.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('osmos_flutter_plugin');
  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'buildGlobalInstance') {
        return null;
      } else if (methodCall.method == 'build') {
        return null;
      } else if (methodCall.method == 'fetchDisplayAdsWithAu') {
        return {
          'status': 'success',
          'data': [
            {
              'image_url': 'https://mock.url',
              'destination_url': 'https://dest.url',
            }
          ]
        };
      } else if (methodCall.method == 'registerAdImpresssionEvent') {
        return {'status': 'success'};
      } else if (methodCall.method == 'registerAdClickEvent') {
        return {'status': 'success'};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    OsmosSDK.shutdown();
  });

  group('OsmosInitializer Tests', () {
    test('init initializes successfully and exposes sdk getter', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      await initializer.init();

      expect(initializer.isInitialized, isTrue);
      expect(initializer.sdk, isNotNull);
      expect(log.map((m) => m.method), contains('buildGlobalInstance'));
    });

    test('init handles native ERROR_ALREADY_INITIALIZED and initializes successfully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'buildGlobalInstance') {
          throw PlatformException(
            code: 'ERROR_ALREADY_INITIALIZED',
            message: 'Already initialized',
            details: 'ERROR_ALREADY_INITIALIZED',
          );
        }
        return null;
      });

      final initializer = OsmosInitializer(FakeAppLogger());
      await initializer.init();

      expect(initializer.isInitialized, isTrue);
      expect(initializer.sdk, isNotNull);
      expect(log.map((m) => m.method), contains('buildGlobalInstance'));
    });

    test('init rethrows other errors and sets isInitialized to false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(
          code: 'SOME_OTHER_ERROR',
          message: 'Error message',
        );
      });

      final initializer = OsmosInitializer(FakeAppLogger());
      expect(() => initializer.init(), throwsA(isA<OsmosException>()));
      expect(initializer.isInitialized, isFalse);
    });

    test('sdk getter throws StateError if not initialized', () {
      final initializer = OsmosInitializer(FakeAppLogger());
      expect(() => initializer.sdk, throwsStateError);
    });
  });

  group('OsmosAdService Tests', () {
    test('fetchDisplayAds throws state error if sdk is not initialized', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      final service = OsmosAdService(initializer, FakeAppLogger());

      expect(() => service.fetchDisplayAds(), throwsStateError);
    });

    test('fetchDisplayAds returns mock data on success', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      await initializer.init();

      final service = OsmosAdService(initializer, FakeAppLogger());
      final result = await service.fetchDisplayAds();

      expect(result, isNotNull);
      expect(result?['status'], 'success');
      expect(log.map((m) => m.method), contains('fetchDisplayAdsWithAu'));
    });

    test('fetchDisplayAds rethrows when sdk call fails', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      await initializer.init();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'fetchDisplayAdsWithAu') {
          throw PlatformException(code: 'FETCH_ERROR', message: 'Failed fetching');
        }
        return null;
      });

      final service = OsmosAdService(initializer, FakeAppLogger());
      expect(() => service.fetchDisplayAds(), throwsA(isA<OsmosException>()));
    });
  });

  group('OsmosEventService Tests', () {
    test('trackImpression and trackClick call native methods and pings URL', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      await initializer.init();

      final service = OsmosEventService(initializer, FakeAppLogger());

      await service.trackImpression(
        uclid: '123',
        impressionTrackingUrl: 'https://invalid-url.com/imp',
      );
      expect(log.map((m) => m.method), contains('registerAdImpresssionEvent'));

      await service.trackClick(
        uclid: '123',
        clickTrackingUrl: 'https://invalid-url.com/click',
      );
      expect(log.map((m) => m.method), contains('registerAdClickEvent'));
    });

    test('trackImpression and trackClick gracefully ignore SDK errors if not initialized', () async {
      final initializer = OsmosInitializer(FakeAppLogger());
      final service = OsmosEventService(initializer, FakeAppLogger());

      await service.trackImpression(uclid: '123');
      await service.trackClick(uclid: '123');
      expect(log, isEmpty);
    });
  });
}
