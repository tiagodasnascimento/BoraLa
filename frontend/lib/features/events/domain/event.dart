class EventItem {
  const EventItem({
    required this.id,
    required this.name,
    required this.location,
    required this.startAt,
    required this.endAt,
    required this.category,
    required this.isPopular,
  });

  final String id;
  final String name;
  final String location;
  final DateTime startAt;
  final DateTime endAt;
  final String category;
  final bool isPopular;
}
