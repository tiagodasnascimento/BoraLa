import 'package:get_it/get_it.dart';

import '../../features/discovery/data/location_service.dart';
import '../../features/discovery/data/venue_repository.dart';
import '../../features/events/data/event_repository.dart';
import '../../features/search/data/search_repository.dart';
import '../../features/traffic/data/traffic_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (getIt.isRegistered<VenueRepository>()) return;

  getIt.registerLazySingleton<VenueRepository>(() => VenueRepositoryImpl());
  getIt.registerLazySingleton<EventRepository>(() => EventRepositoryImpl());
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepository(
      eventRepository: getIt<EventRepository>(),
      venueRepository: getIt<VenueRepository>(),
    ),
  );
  getIt.registerLazySingleton<TrafficRepository>(() => TrafficRepository());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
}
