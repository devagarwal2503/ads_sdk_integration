import '../models/ads_response_model.dart';

abstract class AdsRemoteDataSource {
  Future<AdsResponseModel> fetchDisplayAds();
}
