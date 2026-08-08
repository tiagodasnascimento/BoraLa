import 'package:geolocator/geolocator.dart';

import '../domain/user_location.dart';

/// Resolve a localização do usuário via `geolocator`, com fallback para uma
/// região padrão quando a permissão é negada ou o serviço está desabilitado (FR-017).
class LocationService {
  Future<UserLocation> resolveCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return UserLocation.fallback;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return UserLocation.fallback;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        isPermissionGranted: true,
      );
    } catch (_) {
      return UserLocation.fallback;
    }
  }
}
