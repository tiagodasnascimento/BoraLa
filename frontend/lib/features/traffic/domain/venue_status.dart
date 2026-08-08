enum VenueTrafficStatus { low, medium, high, crowded }

class VenueTraffic {
  const VenueTraffic({
    required this.venueId,
    required this.status,
    required this.occupancy,
    required this.capacity,
  });

  final String venueId;
  final VenueTrafficStatus status;
  final int occupancy;
  final int capacity;
}
