import '../domain/event.dart';

abstract class EventRepository {
  Future<List<EventItem>> fetchFeaturedEvents();
  Future<List<EventItem>> fetchEventsByDate(DateTime date);
}

class EventRepositoryImpl implements EventRepository {
  @override
  Future<List<EventItem>> fetchFeaturedEvents() async {
    return [
      EventItem(
        id: '1',
        name: 'Sábado de Música ao Vivo',
        location: 'Bar do Bairro',
        startAt: DateTime.now().add(const Duration(hours: 2)),
        endAt: DateTime.now().add(const Duration(hours: 5)),
        category: 'Música',
        isPopular: true,
      ),
      EventItem(
        id: '2',
        name: 'Happy Hour Gourmet',
        location: 'Bistro Central',
        startAt: DateTime.now().add(const Duration(hours: 4)),
        endAt: DateTime.now().add(const Duration(hours: 7)),
        category: 'Gastronomia',
        isPopular: false,
      ),
    ];
  }

  @override
  Future<List<EventItem>> fetchEventsByDate(DateTime date) async {
    return fetchFeaturedEvents();
  }
}
