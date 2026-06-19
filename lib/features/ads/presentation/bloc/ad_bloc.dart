import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_sdk_integration/analytics/analytics_service.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/fetch_banner_ad.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_click.dart';
import 'package:ads_sdk_integration/features/ads/domain/usecases/track_impression.dart';
import 'ad_event.dart';
import 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final FetchBannerAdUseCase fetchBannerAdUseCase;
  final TrackImpressionUseCase trackImpressionUseCase;
  final TrackClickUseCase trackClickUseCase;
  final AnalyticsService analytics;

  AdBloc({
    required this.fetchBannerAdUseCase,
    required this.trackImpressionUseCase,
    required this.trackClickUseCase,
    required this.analytics,
  }) : super(AdInitial()) {
    on<LoadBannerAd>(_onLoadBannerAd);
    on<RetryLoadingAd>(_onRetryLoadingAd);
    on<ImpressionDetected>(_onImpressionDetected);
    on<BannerClicked>(_onBannerClicked);
    on<ResetBanner>(_onResetBanner);
  }

  Future<void> _onLoadBannerAd(
    LoadBannerAd event,
    Emitter<AdState> emit,
  ) async {
    emit(AdLoading());
    final result = await fetchBannerAdUseCase();
    result.fold(
      (ad) {
        analytics.logAdLoaded();
        emit(AdLoaded(ad: ad));
      },
      (failure) {
        analytics.logFailure(failure.message);
        if (failure is EmptyAdFailure) {
          emit(AdEmpty(message: failure.message));
        } else {
          emit(AdError(failure.message));
        }
      },
    );
  }

  Future<void> _onRetryLoadingAd(
    RetryLoadingAd event,
    Emitter<AdState> emit,
  ) async {
    add(LoadBannerAd());
  }

  Future<void> _onImpressionDetected(
    ImpressionDetected event,
    Emitter<AdState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdLoaded && !currentState.impressionTracked) {
      final ad = currentState.ad;
      analytics.logImpression();

      emit(currentState.copyWith(impressionTracked: true));

      await trackImpressionUseCase(
        TrackImpressionParams(
          uclid: ad.uclid,
          impressionTrackingUrl: ad.impressionTrackingUrl,
        ),
      );
    }
  }

  Future<void> _onBannerClicked(
    BannerClicked event,
    Emitter<AdState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdLoaded) {
      final ad = currentState.ad;
      analytics.logClick();

      emit(currentState.copyWith(clickTracked: true));

      await trackClickUseCase(
        TrackClickParams(
          uclid: ad.uclid,
          clickTrackingUrl: ad.clickTrackingUrl,
        ),
      );
    }
  }

  void _onResetBanner(ResetBanner event, Emitter<AdState> emit) {
    emit(AdInitial());
  }
}
