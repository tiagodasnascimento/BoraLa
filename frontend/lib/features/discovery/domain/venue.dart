import '../../traffic/domain/venue_status.dart';

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.trafficStatus,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final VenueTrafficStatus trafficStatus;
  final bool isFeatured;
}
