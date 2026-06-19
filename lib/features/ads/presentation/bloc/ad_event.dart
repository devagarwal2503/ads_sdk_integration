import 'package:equatable/equatable.dart';

abstract class AdEvent extends Equatable {
  const AdEvent();

  @override
  List<Object?> get props => [];
}

class LoadBannerAd extends AdEvent {}

class RetryLoadingAd extends AdEvent {}

class ImpressionDetected extends AdEvent {}

class BannerClicked extends AdEvent {}

class ResetBanner extends AdEvent {}
