import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../traffic/domain/venue_status.dart';
import '../domain/venue.dart';

abstract class VenueRepository {
  /// Retorna todos os locais visíveis na região atual do mapa.
  Future<List<Venue>> fetchVenues({required LatLngBounds visibleBounds});

  /// Retorna um único local pelo id (usado ao abrir o painel de detalhes).
  Future<Venue?> fetchVenueById(String id);
}

/// Descrição de um venue mockado, posicionado por deslocamento em graus a partir
/// de um ponto de referência — assim o conjunto de dados de exemplo aparece ao
/// redor de onde o usuário estiver, em vez de ficar preso a uma cidade fixa.
class _VenueSeed {
  const _VenueSeed({
    required this.id,
    required this.name,
    required this.latOffset,
    required this.lngOffset,
    required this.trafficStatus,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final double latOffset;
  final double lngOffset;
  final VenueTrafficStatus trafficStatus;
  final bool isFeatured;
}

class VenueRepositoryImpl implements VenueRepository {
  /// Os quatro últimos seeds ficam muito próximos entre si de propósito, para
  /// exercitar o agrupamento de marcadores em alta densidade (FR-012/SC-006).
  static const List<_VenueSeed> _seeds = [
    _VenueSeed(
      id: 'venue_001',
      name: 'Bar do Bairro',
      latOffset: 0.0000,
      lngOffset: 0.0000,
      trafficStatus: VenueTrafficStatus.high,
      isFeatured: true,
    ),
    _VenueSeed(
      id: 'venue_002',
      name: 'Bistro Central',
      latOffset: -0.0040,
      lngOffset: 0.0033,
      trafficStatus: VenueTrafficStatus.medium,
    ),
    _VenueSeed(
      id: 'venue_003',
      name: 'Jazz & Cia',
      latOffset: 0.0035,
      lngOffset: -0.0032,
      trafficStatus: VenueTrafficStatus.low,
    ),
    _VenueSeed(
      id: 'venue_004',
      name: 'Quintal Eletrônico',
      latOffset: -0.0105,
      lngOffset: 0.0083,
      trafficStatus: VenueTrafficStatus.crowded,
      isFeatured: true,
    ),
    _VenueSeed(
      id: 'venue_005',
      name: 'Vila do Rock',
      latOffset: 0.0015,
      lngOffset: 0.0053,
      trafficStatus: VenueTrafficStatus.medium,
    ),
    _VenueSeed(
      id: 'venue_006',
      name: 'Boteco da Vila',
      latOffset: 0.0013,
      lngOffset: 0.0050,
      trafficStatus: VenueTrafficStatus.low,
    ),
    _VenueSeed(
      id: 'venue_007',
      name: 'Samba da Esquina',
      latOffset: 0.0017,
      lngOffset: 0.0055,
      trafficStatus: VenueTrafficStatus.crowded,
    ),
    _VenueSeed(
      id: 'venue_008',
      name: 'Choperia da Vila',
      latOffset: 0.0011,
      lngOffset: 0.0052,
      trafficStatus: VenueTrafficStatus.high,
    ),
  ];

  /// Venues já materializados, para que `fetchVenueById` e consultas seguintes
  /// devolvam sempre as mesmas coordenadas.
  final Map<String, Venue> _resolved = {};

  List<Venue> _materializeAround(LatLng center) {
    final venues = [
      for (final seed in _seeds)
        Venue(
          id: seed.id,
          name: seed.name,
          latitude: center.latitude + seed.latOffset,
          longitude: center.longitude + seed.lngOffset,
          trafficStatus: seed.trafficStatus,
          isFeatured: seed.isFeatured,
        ),
    ];
    for (final venue in venues) {
      _resolved[venue.id] = venue;
    }
    return venues;
  }

  @override
  Future<List<Venue>> fetchVenues({required LatLngBounds visibleBounds}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final alreadyVisible = _resolved.values
        .where((venue) => visibleBounds.contains(LatLng(venue.latitude, venue.longitude)))
        .toList();
    if (alreadyVisible.isNotEmpty) return alreadyVisible;

    // Nada carregado ainda para esta área: posiciona o conjunto de exemplo ao
    // redor do centro da região consultada, como uma API real faria ao devolver
    // os locais existentes dentro dos bounds.
    final center = LatLng(
      (visibleBounds.north + visibleBounds.south) / 2,
      (visibleBounds.east + visibleBounds.west) / 2,
    );
    return _materializeAround(center)
        .where((venue) => visibleBounds.contains(LatLng(venue.latitude, venue.longitude)))
        .toList();
  }

  @override
  Future<Venue?> fetchVenueById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_resolved.isEmpty) {
      _materializeAround(const LatLng(-23.5505, -46.6333));
    }
    return _resolved[id];
  }
}
