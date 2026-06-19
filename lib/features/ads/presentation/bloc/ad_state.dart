import 'package:equatable/equatable.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';

abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object?> get props => [];
}

class AdInitial extends AdState {}

class AdLoading extends AdState {}

class AdLoaded extends AdState {
  final AdEntity ad;
  final bool impressionTracked;
  final bool clickTracked;

  const AdLoaded({
    required this.ad,
    this.impressionTracked = false,
    this.clickTracked = false,
  });

  AdLoaded copyWith({
    AdEntity? ad,
    bool? impressionTracked,
    bool? clickTracked,
  }) {
    return AdLoaded(
      ad: ad ?? this.ad,
      impressionTracked: impressionTracked ?? this.impressionTracked,
      clickTracked: clickTracked ?? this.clickTracked,
    );
  }

  @override
  List<Object?> get props => [ad, impressionTracked, clickTracked];
}

class AdEmpty extends AdState {
  final String message;

  const AdEmpty({this.message = 'Ad not available'});

  @override
  List<Object?> get props => [message];
}

class AdError extends AdState {
  final String message;

  const AdError(this.message);

  @override
  List<Object?> get props => [message];
}
