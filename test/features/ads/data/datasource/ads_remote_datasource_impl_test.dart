import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/sdk/osmos_ad_service.dart';
import 'package:ads_sdk_integration/features/ads/data/datasource/ads_remote_datasource_impl.dart';
import 'package:ads_sdk_integration/features/ads/data/models/ads_response_model.dart';

class MockOsmosAdService implements OsmosAdService {
  Map<String, dynamic>? fetchResult;

  @override
  Future<Map<String, dynamic>?> fetchDisplayAds() async {
    return fetchResult;
  }
}

void main() {
  late AdsRemoteDataSourceImpl dataSource;
  late MockOsmosAdService mockAdService;

  setUp(() {
    mockAdService = MockOsmosAdService();
    dataSource = AdsRemoteDataSourceImpl(osmosAdService: mockAdService);
  });

  final tAdResponseMap = {
    'ads': {
      'banner_ads': [
        {
          'uclid': '123',
          'elements': {
            'value': 'https://image.url',
            'destination_url': 'https://destination.url',
          },
        },
      ],
    },
  };

  test(
    'should return AdsResponseModel when fetchDisplayAds returns a non-null map',
    () async {
      mockAdService.fetchResult = tAdResponseMap;

      final result = await dataSource.fetchDisplayAds();

      expect(result, isA<AdsResponseModel>());
      expect(result.bannerAds.first.uclid, '123');
    },
  );

  test('should throw Exception when fetchDisplayAds returns null', () async {
    mockAdService.fetchResult = null;

    expect(() => dataSource.fetchDisplayAds(), throwsException);
  });
}
