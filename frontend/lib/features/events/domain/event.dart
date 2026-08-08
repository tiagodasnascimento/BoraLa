class EventItem {
  const EventItem({
    required this.id,
    required this.venueId,
    required this.name,
    required this.genre,
    required this.startAt,
    required this.endAt,
    required this.category,
    required this.isPopular,
  });

  final String id;
  final String venueId;
  final String name;

  /// Estilo/gênero musical do evento (ex.: "Jazz", "Eletrônica"), usado no filtro de gênero (FR-009).
  final String genre;
  final DateTime startAt;
  final DateTime endAt;
  final String category;
  final bool isPopular;

  /// Evento acontecendo agora, per a regra de estado derivado em data-model.md.
  bool isHappeningAt(DateTime now) => !now.isBefore(startAt) && now.isBefore(endAt);

  /// Evento ainda não começou.
  bool isUpcomingAt(DateTime now) => now.isBefore(startAt);
}
