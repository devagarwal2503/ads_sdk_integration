import 'package:equatable/equatable.dart';

class AdEntity extends Equatable {
  final String imageUrl;
  final String destinationUrl;
  final String? impressionTrackingUrl;
  final String? clickTrackingUrl;
  final double? width;
  final double? height;
  final String uclid;

  const AdEntity({
    required this.imageUrl,
    required this.destinationUrl,
    this.impressionTrackingUrl,
    this.clickTrackingUrl,
    this.width,
    this.height,
    required this.uclid,
  });

  @override
  List<Object?> get props => [
    imageUrl,
    destinationUrl,
    impressionTrackingUrl,
    clickTrackingUrl,
    width,
    height,
    uclid,
  ];
}
