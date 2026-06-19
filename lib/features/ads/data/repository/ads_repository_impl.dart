import 'dart:io';
import 'package:flutter/services.dart';
import 'package:osmos_flutter_plugin/utils/osmos_error_codes.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';
import 'package:ads_sdk_integration/core/utils/result.dart';
import 'package:ads_sdk_integration/sdk/osmos_event_service.dart';
import 'package:ads_sdk_integration/sdk/osmos_initializer.dart';
import 'package:ads_sdk_integration/features/ads/domain/entities/ad_entity.dart';
import 'package:ads_sdk_integration/features/ads/domain/repository/ads_repository.dart';
import 'package:ads_sdk_integration/features/ads/data/datasource/ads_remote_datasource.dart';

class AdsRepositoryImpl implements AdsRepository {
  final AdsRemoteDataSource remoteDataSource;
  final OsmosEventService osmosEventService;
  final OsmosInitializer osmosInitializer;

  AdsRepositoryImpl({
    required this.remoteDataSource,
    required this.osmosEventService,
    required this.osmosInitializer,
  });

  @override
  Future<Result<AdEntity, Failure>> fetchBannerAd() async {
    try {
      if (!osmosInitializer.isInitialized) {
        await osmosInitializer.init();
      }

      final adsResponse = await remoteDataSource.fetchDisplayAds();
      if (adsResponse.bannerAds.isEmpty) {
        return const FailureResult(
          EmptyAdFailure('No ads returned in response'),
        );
      }

      final adModel = adsResponse.bannerAds.first;
      final elements = adModel.elements;

      if (elements == null || elements.value.isEmpty) {
        return const FailureResult(
          EmptyAdFailure('Ad element image value is missing'),
        );
      }

      final adEntity = AdEntity(
        imageUrl: elements.value,
        destinationUrl: elements.destinationUrl.isNotEmpty
            ? elements.destinationUrl
            : (adModel.clickTrackingUrl ?? ''),
        impressionTrackingUrl: adModel.impressionTrackingUrl,
        clickTrackingUrl: adModel.clickTrackingUrl,
        width: adModel.width,
        height: adModel.height,
        uclid: adModel.uclid ?? 'unknown',
      );

      return Success(adEntity);
    } catch (e) {
      String errorStr = e.toString().toLowerCase();

      if (e is OsmosException) {
        final code = e.errorCode;
        if (code == OsmosErrorCodes.networkError ||
            code == OsmosErrorCodes.connectionError ||
            code == OsmosErrorCodes.timeoutError) {
          return const FailureResult(
            NetworkFailure(
              'No internet connection. Please check your network and try again.',
            ),
          );
        }

        // Incorporate any details from OsmosException
        if (e.details != null) {
          errorStr += ' ${e.details!.toLowerCase()}';
        }

        // Incorporate messages or details from the underlying native error/PlatformException
        final native = e.nativeError;
        if (native != null) {
          errorStr += ' ${native.toString().toLowerCase()}';
          if (native is PlatformException) {
            if (native.message != null) {
              errorStr += ' ${native.message!.toLowerCase()}';
            }
            if (native.details != null) {
              errorStr += ' ${native.details!.toString().toLowerCase()}';
            }
          }
        }
      }

      if (e is SocketException ||
          e is HttpException ||
          errorStr.contains('socketexception') ||
          errorStr.contains('network') ||
          errorStr.contains('connection') ||
          errorStr.contains('timeout') ||
          errorStr.contains('host') ||
          errorStr.contains('dns') ||
          errorStr.contains('offline') ||
          errorStr.contains('unreachable') ||
          errorStr.contains('failed to connect')) {
        return const FailureResult(
          NetworkFailure(
            'No internet connection. Please check your network and try again.',
          ),
        );
      }

      if (errorStr.contains('not initialized') ||
          errorStr.contains('sdknotinitialized')) {
        return FailureResult(
          SdkNotInitializedFailure('SDK not initialized: $e'),
        );
      }

      return FailureResult(
        UnexpectedFailure('An unexpected error occurred: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> trackImpression({
    required String uclid,
    String? impressionTrackingUrl,
  }) async {
    try {
      await osmosEventService.trackImpression(
        uclid: uclid,
        impressionTrackingUrl: impressionTrackingUrl,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> trackClick({
    required String uclid,
    String? clickTrackingUrl,
  }) async {
    try {
      await osmosEventService.trackClick(
        uclid: uclid,
        clickTrackingUrl: clickTrackingUrl,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(UnexpectedFailure(e.toString()));
    }
  }
}
