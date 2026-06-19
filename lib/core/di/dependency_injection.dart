import 'package:get_it/get_it.dart';
import '../../analytics/analytics_service.dart';
import '../../features/ads/data/datasource/ads_remote_datasource.dart';
import '../../features/ads/data/datasource/ads_remote_datasource_impl.dart';
import '../../features/ads/data/repository/ads_repository_impl.dart';
import '../../features/ads/domain/repository/ads_repository.dart';
import '../../features/ads/domain/usecases/fetch_banner_ad.dart';
import '../../features/ads/domain/usecases/track_click.dart';
import '../../features/ads/domain/usecases/track_impression.dart';
import '../../features/ads/presentation/bloc/ad_bloc.dart';
import '../../sdk/osmos_ad_service.dart';
import '../../sdk/osmos_event_service.dart';
import '../../sdk/osmos_initializer.dart';
import '../logger/app_logger.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Core
  sl.registerLazySingleton<AppLogger>(() => AppLogger());
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(sl<AppLogger>()),
  );

  // SDK
  sl.registerLazySingleton<OsmosInitializer>(
    () => OsmosInitializer(sl<AppLogger>()),
  );
  sl.registerLazySingleton<OsmosAdService>(
    () => OsmosAdService(sl<OsmosInitializer>(), sl<AppLogger>()),
  );
  sl.registerLazySingleton<OsmosEventService>(
    () => OsmosEventService(sl<OsmosInitializer>(), sl<AppLogger>()),
  );

  // Data sources
  sl.registerLazySingleton<AdsRemoteDataSource>(
    () => AdsRemoteDataSourceImpl(osmosAdService: sl<OsmosAdService>()),
  );

  // Repositories
  sl.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(
      remoteDataSource: sl<AdsRemoteDataSource>(),
      osmosEventService: sl<OsmosEventService>(),
      osmosInitializer: sl<OsmosInitializer>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<FetchBannerAdUseCase>(
    () => FetchBannerAdUseCase(sl<AdsRepository>()),
  );
  sl.registerLazySingleton<TrackImpressionUseCase>(
    () => TrackImpressionUseCase(sl<AdsRepository>()),
  );
  sl.registerLazySingleton<TrackClickUseCase>(
    () => TrackClickUseCase(sl<AdsRepository>()),
  );

  // BLoCs
  sl.registerFactory<AdBloc>(
    () => AdBloc(
      fetchBannerAdUseCase: sl<FetchBannerAdUseCase>(),
      trackImpressionUseCase: sl<TrackImpressionUseCase>(),
      trackClickUseCase: sl<TrackClickUseCase>(),
      analytics: sl<AnalyticsService>(),
    ),
  );
}
