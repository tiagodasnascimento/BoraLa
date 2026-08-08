class SearchResult {
  const SearchResult({
    required this.id,
    required this.name,
    required this.category,
    required this.venueId,
    required this.venueName,
  });

  final String id;
  final String name;
  final String category;

  /// Referencia o Venue correspondente, usado para centralizar o mapa (FR-008).
  final String venueId;
  final String venueName;
}
