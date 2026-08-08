class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.isPermissionGranted,
  });

  final double latitude;
  final double longitude;
  final bool isPermissionGranted;

  /// Região padrão usada quando a permissão de localização é negada (FR-017).
  /// Centro de São Paulo, cidade de referência do BoraLá.
  static const UserLocation fallback = UserLocation(
    latitude: -23.5505,
    longitude: -46.6333,
    isPermissionGranted: false,
  );
}
