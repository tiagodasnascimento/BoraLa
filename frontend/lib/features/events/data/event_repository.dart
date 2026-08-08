import '../domain/event.dart';

abstract class EventRepository {
  Future<List<EventItem>> fetchFeaturedEvents();
  Future<List<EventItem>> fetchEventsByDate(DateTime date);

  /// Eventos ativos ou futuros associados a um local (FR-005, contracts/discovery-repository.md).
  Future<List<EventItem>> fetchEventsByVenue(String venueId);
}

class EventRepositoryImpl implements EventRepository {
  static final List<EventItem> _events = [
    EventItem(
      id: 'evt_001',
      venueId: 'venue_001',
      name: 'Sábado de Música ao Vivo',
      genre: 'MPB',
      startAt: DateTime.now().add(const Duration(hours: 2)),
      endAt: DateTime.now().add(const Duration(hours: 5)),
      category: 'Música',
      isPopular: true,
    ),
    EventItem(
      id: 'evt_002',
      venueId: 'venue_002',
      name: 'Happy Hour Gourmet',
      genre: 'Ambiente',
      startAt: DateTime.now().add(const Duration(hours: 4)),
      endAt: DateTime.now().add(const Duration(hours: 7)),
      category: 'Gastronomia',
      isPopular: false,
    ),
    EventItem(
      id: 'evt_003',
      venueId: 'venue_003',
      name: 'Noite de Jazz',
      genre: 'Jazz',
      startAt: DateTime.now().subtract(const Duration(minutes: 30)),
      endAt: DateTime.now().add(const Duration(hours: 3)),
      category: 'Música',
      isPopular: true,
    ),
    EventItem(
      id: 'evt_004',
      venueId: 'venue_004',
      name: 'Rave no Quintal',
      genre: 'Eletrônica',
      startAt: DateTime.now().add(const Duration(hours: 1)),
      endAt: DateTime.now().add(const Duration(hours: 6)),
      category: 'Música',
      isPopular: true,
    ),
    EventItem(
      id: 'evt_005',
      venueId: 'venue_005',
      name: 'Rock na Vila',
      genre: 'Rock',
      startAt: DateTime.now().add(const Duration(hours: 3)),
      endAt: DateTime.now().add(const Duration(hours: 6)),
      category: 'Música',
      isPopular: false,
    ),
    EventItem(
      id: 'evt_006',
      venueId: 'venue_006',
      name: 'Roda de Samba',
      genre: 'Samba',
      startAt: DateTime.now().add(const Duration(hours: 2)),
      endAt: DateTime.now().add(const Duration(hours: 5)),
      category: 'Música',
      isPopular: false,
    ),
    EventItem(
      id: 'evt_007',
      venueId: 'venue_007',
      name: 'Pagode da Esquina',
      genre: 'Samba',
      startAt: DateTime.now().add(const Duration(hours: 1)),
      endAt: DateTime.now().add(const Duration(hours: 4)),
      category: 'Música',
      isPopular: true,
    ),
    EventItem(
      id: 'evt_008',
      venueId: 'venue_008',
      name: 'Chopp e Sertanejo',
      genre: 'Sertanejo',
      startAt: DateTime.now().add(const Duration(hours: 2)),
      endAt: DateTime.now().add(const Duration(hours: 5)),
      category: 'Música',
      isPopular: false,
    ),
    // Evento já encerrado — usado para validar que fetchEventsByVenue não o retorna.
    EventItem(
      id: 'evt_009',
      venueId: 'venue_001',
      name: 'Almoço de Sexta',
      genre: 'Ambiente',
      startAt: DateTime.now().subtract(const Duration(hours: 5)),
      endAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Gastronomia',
      isPopular: false,
    ),
  ];

  @override
  Future<List<EventItem>> fetchFeaturedEvents() async {
    final now = DateTime.now();
    return _events.where((event) => event.endAt.isAfter(now)).toList();
  }

  @override
  Future<List<EventItem>> fetchEventsByDate(DateTime date) async {
    return fetchFeaturedEvents();
  }

  @override
  Future<List<EventItem>> fetchEventsByVenue(String venueId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return _events
        .where((event) => event.venueId == venueId && event.endAt.isAfter(now))
        .toList();
  }
}
