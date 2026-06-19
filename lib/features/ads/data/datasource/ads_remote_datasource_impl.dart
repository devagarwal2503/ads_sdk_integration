import '../../../../sdk/osmos_ad_service.dart';
import '../models/ads_response_model.dart';
import 'ads_remote_datasource.dart';

/// Implementation of [AdsRemoteDataSource] communicating directly with the SDK wrapper service.
class AdsRemoteDataSourceImpl implements AdsRemoteDataSource {
  final OsmosAdService osmosAdService;

  AdsRemoteDataSourceImpl({required this.osmosAdService});

  /// Contacts [OsmosAdService] to retrieve banner ads.
  /// Throws [Exception] if the response is empty or null, otherwise parses and returns [AdsResponseModel].
  @override
  Future<AdsResponseModel> fetchDisplayAds() async {
    final response = await osmosAdService.fetchDisplayAds();
    if (response == null) {
      throw Exception('Received null ad response from SDK');
    }
    return AdsResponseModel.fromJson(response);
  }
}
