import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'ad_model.dart';

/// Top-level model representing the complete ad response packet returned by the SDK.
class AdsResponseModel extends Equatable {
  /// List of banner advertisement objects parsed from the JSON response.
  final List<AdModel> bannerAds;

  const AdsResponseModel({required this.bannerAds});

  /// Factory constructor to parse and map raw SDK payloads into [AdsResponseModel].
  ///
  /// Designed to accommodate layout changes by handling:
  /// 1. Direct structures: JSON containing `ads` keys directly at the root.
  /// 2. Nested/Wrapped responses: JSON where root contains `response.data` wrapper blocks.
  factory AdsResponseModel.fromJson(Map<String, dynamic> json) {
    List<AdModel> bannerAdsList = [];

    Map<String, dynamic> dataMap = json;

    // Check if the payload is wrapped under a 'response' node.
    if (json.containsKey('response') && json['response'] is Map) {
      final responseMap = Map<String, dynamic>.from(json['response'] as Map);
      final rawData = responseMap['data'];

      if (rawData is Map) {
        dataMap = Map<String, dynamic>.from(rawData);
      } else if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }

    // Extract the ads list nested under banner_ads
    final adsMap = dataMap['ads'];
    if (adsMap is Map) {
      final bannerAdsData = adsMap['banner_ads'];
      if (bannerAdsData is List) {
        bannerAdsList = bannerAdsData
            .map(
              (item) =>
                  AdModel.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      }
    }
    return AdsResponseModel(bannerAds: bannerAdsList);
  }

  /// Converts the [AdsResponseModel] instance into a JSON compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'ads': {'banner_ads': bannerAds.map((item) => item.toJson()).toList()},
    };
  }

  @override
  List<Object?> get props => [bannerAds];
}
