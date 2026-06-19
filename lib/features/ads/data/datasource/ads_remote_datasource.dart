import 'package:ads_sdk_integration/features/ads/data/models/ads_response_model.dart';

abstract class AdsRemoteDataSource {
  Future<AdsResponseModel> fetchDisplayAds();
}
