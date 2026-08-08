import '../domain/venue_status.dart';

class TrafficRepository {
  Future<VenueTraffic> fetchVenueStatus(String venueId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    return VenueTraffic(
      venueId: venueId,
      status: VenueTrafficStatus.high,
      occupancy: 160,
      capacity: 200,
    );
  }
}
