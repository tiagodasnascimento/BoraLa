import '../../discovery/data/venue_repository.dart';
import '../../events/data/event_repository.dart';
import '../domain/search_result.dart';

class SearchRepository {
  SearchRepository({EventRepository? eventRepository, VenueRepository? venueRepository})
      : _eventRepository = eventRepository ?? EventRepositoryImpl(),
        _venueRepository = venueRepository ?? VenueRepositoryImpl();

  final EventRepository _eventRepository;
  final VenueRepository _venueRepository;

  /// Busca por nome do evento, gênero/estilo musical ou nome do local (FR-007).
  Future<List<SearchResult>> searchEvents(String query) async {
    final normalized = query.trim().toLowerCase();
    final events = await _eventRepository.fetchFeaturedEvents();

    final results = <SearchResult>[];
    for (final event in events) {
      final venue = await _venueRepository.fetchVenueById(event.venueId);
      final venueName = venue?.name ?? '';

      final matches = normalized.isEmpty ||
          event.name.toLowerCase().contains(normalized) ||
          event.genre.toLowerCase().contains(normalized) ||
          venueName.toLowerCase().contains(normalized);

      if (matches) {
        results.add(
          SearchResult(
            id: event.id,
            name: event.name,
            category: event.genre,
            venueId: event.venueId,
            venueName: venueName,
          ),
        );
      }
    }
    return results;
  }
}
