import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/features/favorites/data/favorites_repository.dart';

void main() {
  test('fetchFavorites returns saved favorites', () async {
    final repository = FavoritesRepository();

    final favorites = await repository.fetchFavorites();

    expect(favorites, isNotEmpty);
    expect(favorites.first.name, 'Sábado de Música ao Vivo');
  });

  test('addFavorite creates a new favorite record', () async {
    final repository = FavoritesRepository();

    final favorite = await repository.addFavorite('evt_003', 'Noite de Jazz', 'Sede do Jazz');

    expect(favorite.eventId, 'evt_003');
    expect(favorite.name, 'Noite de Jazz');
  });
}
