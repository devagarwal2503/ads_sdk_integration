import 'package:equatable/equatable.dart';
import 'element_model.dart';

/// Data model representing a single advertisement item parsed from the SDK payload response.
class AdModel extends Equatable {
  /// The element containing media information such as image path and landing URL.
  final ElementModel? elements;

  /// The destination target endpoint to ping when the ad is viewed.
  final String? impressionTrackingUrl;

  /// The destination target endpoint to ping when the ad is clicked.
  final String? clickTrackingUrl;

  /// Calculated width of the layout boundary.
  final double? width;

  /// Calculated height of the layout boundary.
  final double? height;

  /// The unique click trace ID parsed from elements or tracking URLs.
  final String? uclid;

  const AdModel({
    this.elements,
    this.impressionTrackingUrl,
    this.clickTrackingUrl,
    this.width,
    this.height,
    this.uclid,
  });

  /// Factory method to construct an [AdModel] from dynamic JSON payloads.
  ///
  /// Employs robust fallbacks to parse:
  /// - Unwrapped maps vs wrapped lists inside the elements dictionary.
  /// - Nested width/height fields inside the elements block if the root contains nulls.
  /// - Embedded `uclid` query params inside tracking URLs if the root `uclid` field is missing.
  factory AdModel.fromJson(Map<String, dynamic> json) {
    ElementModel? parsedElements;
    final rawElements = json['elements'];
    if (rawElements is Map) {
      parsedElements = ElementModel.fromJson(
        Map<String, dynamic>.from(rawElements),
      );
    } else if (rawElements is List && rawElements.isNotEmpty) {
      final first = rawElements.first;
      if (first is Map) {
        parsedElements = ElementModel.fromJson(
          Map<String, dynamic>.from(first),
        );
      }
    }

    // Try parsing dimensions from the root level
    final rawWidth = json['width'];
    double? widthValue = rawWidth is num
        ? rawWidth.toDouble()
        : double.tryParse(rawWidth?.toString() ?? '');

    final rawHeight = json['height'];
    double? heightValue = rawHeight is num
        ? rawHeight.toDouble()
        : double.tryParse(rawHeight?.toString() ?? '');

    // Fallback: If root dimensions are null, parse dimensions from the elements level
    if (widthValue == null && rawElements is Map) {
      final elWidth = rawElements['width'];
      widthValue = elWidth is num
          ? elWidth.toDouble()
          : double.tryParse(elWidth?.toString() ?? '');
    }
    if (heightValue == null && rawElements is Map) {
      final elHeight = rawElements['height'];
      heightValue = elHeight is num
          ? elHeight.toDouble()
          : double.tryParse(elHeight?.toString() ?? '');
    }

    // Capture impression url from string or nested arrays
    String? parsedImpressionUrl;
    final rawImpression = json['impression_tracking_url'];
    if (rawImpression is String) {
      parsedImpressionUrl = rawImpression;
    } else if (rawImpression is List && rawImpression.isNotEmpty) {
      parsedImpressionUrl = rawImpression.first.toString();
    }

    // Capture click url from string or nested arrays
    String? parsedClickUrl;
    final rawClick = json['click_tracking_url'];
    if (rawClick is String) {
      parsedClickUrl = rawClick;
    } else if (rawClick is List && rawClick.isNotEmpty) {
      parsedClickUrl = rawClick.first.toString();
    }

    // Fallback: If uclid is missing or empty, extract it dynamically from the tracking parameters
    String? parsedUclid = json['uclid']?.toString();
    if (parsedUclid == null || parsedUclid.isEmpty) {
      parsedUclid =
          _extractUclid(parsedClickUrl) ?? _extractUclid(parsedImpressionUrl);
    }

    return AdModel(
      elements: parsedElements,
      impressionTrackingUrl: parsedImpressionUrl,
      clickTrackingUrl: parsedClickUrl,
      width: widthValue,
      height: heightValue,
      uclid: parsedUclid,
    );
  }

  /// Utility to extract query parameter `uclid` from a target HTTP string.
  static String? _extractUclid(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('uclid')) {
        return uri.queryParameters['uclid'];
      }
    } catch (_) {}
    return null;
  }

  /// Converts the [AdModel] back into a map for serializing.
  Map<String, dynamic> toJson() {
    return {
      'elements': elements?.toJson(),
      'impression_tracking_url': impressionTrackingUrl,
      'click_tracking_url': clickTrackingUrl,
      'width': width,
      'height': height,
      'uclid': uclid,
    };
  }

  @override
  List<Object?> get props => [
    elements,
    impressionTrackingUrl,
    clickTrackingUrl,
    width,
    height,
    uclid,
  ];
}
