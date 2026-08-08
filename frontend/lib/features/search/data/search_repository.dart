import '../domain/search_result.dart';

class SearchRepository {
  Future<List<SearchResult>> searchEvents(String query) async {
    final normalized = query.trim().toLowerCase();
    final all = [
      const SearchResult(id: 'evt_001', name: 'Sábado de Música ao Vivo', category: 'Música'),
      const SearchResult(id: 'evt_002', name: 'Happy Hour Gourmet', category: 'Gastronomia'),
      const SearchResult(id: 'evt_003', name: 'Noite de Jazz', category: 'Música'),
    ];

    if (normalized.isEmpty) {
      return all;
    }

    return all.where((item) => item.name.toLowerCase().contains(normalized)).toList();
  }
}
