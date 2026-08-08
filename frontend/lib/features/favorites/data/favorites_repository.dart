import '../domain/favorite_event.dart';

class FavoritesRepository {
  Future<List<FavoriteEvent>> fetchFavorites() async {
    return [
      const FavoriteEvent(
        id: 'fav_01',
        eventId: 'evt_001',
        name: 'Sábado de Música ao Vivo',
        location: 'Bar do Bairro',
      ),
      const FavoriteEvent(
        id: 'fav_02',
        eventId: 'evt_002',
        name: 'Happy Hour Gourmet',
        location: 'Bistro Central',
      ),
    ];
  }

  Future<FavoriteEvent> addFavorite(String eventId, String name, String location) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return FavoriteEvent(
      id: 'fav_new',
      eventId: eventId,
      name: name,
      location: location,
    );
  }
}
