import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../events/data/event_repository.dart';
import '../../data/location_service.dart';
import '../../data/venue_repository.dart';
import '../../domain/filter_criteria.dart';
import '../../domain/map_marker_view_model.dart';
import '../../domain/user_location.dart';
import 'discovery_state.dart';

/// Combina localização do usuário, venues/eventos visíveis, filtros ativos,
/// termo de busca e marcador selecionado — consumido pelas 3 user stories (US1/US2/US3).
class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit({
    required VenueRepository venueRepository,
    required EventRepository eventRepository,
    required LocationService locationService,
  })  : _venueRepository = venueRepository,
        _eventRepository = eventRepository,
        _locationService = locationService,
        super(const DiscoveryState());

  final VenueRepository _venueRepository;
  final EventRepository _eventRepository;
  final LocationService _locationService;

  /// Resolve a localização do usuário (com fallback para região padrão quando a
  /// permissão é negada — FR-017) e carrega os venues ao redor dela.
  Future<void> initialize() async {
    emit(state.copyWith(status: DiscoveryStatus.loading));
    final userLocation = await _locationService.resolveCurrentLocation();
    emit(state.copyWith(userLocation: userLocation));
    await loadVenuesAround(userLocation);
  }

  Future<void> loadVenuesAround(UserLocation location) {
    const degreesRadius = 0.05;
    final bounds = LatLngBounds(
      LatLng(location.latitude - degreesRadius, location.longitude - degreesRadius),
      LatLng(location.latitude + degreesRadius, location.longitude + degreesRadius),
    );
    return loadVenuesInBounds(bounds);
  }

  Future<void> loadVenuesInBounds(LatLngBounds bounds) async {
    try {
      emit(state.copyWith(status: DiscoveryStatus.loading));
      final venues = await _venueRepository.fetchVenues(visibleBounds: bounds);

      final markers = <MapMarkerViewModel>[];
      for (final venue in venues) {
        final events = await _eventRepository.fetchEventsByVenue(venue.id);
        if (events.isEmpty) continue;
        markers.add(
          MapMarkerViewModel(
            venue: venue,
            activeEvents: events,
            isSelected: venue.id == state.selectedVenueId,
          ),
        );
      }

      emit(state.copyWith(status: DiscoveryStatus.loaded, markers: markers));
    } catch (_) {
      emit(
        state.copyWith(
          status: DiscoveryStatus.error,
          errorMessage: 'Não foi possível carregar os eventos. Tente novamente.',
        ),
      );
    }
  }

  /// Seleciona (ou limpa, com `null`) o marcador ativo — abre/fecha o painel de detalhes (US1).
  void selectMarker(String? venueId) {
    final updatedMarkers = state.markers
        .map((marker) => marker.copyWith(isSelected: marker.venue.id == venueId))
        .toList(growable: false);

    emit(
      state.copyWith(
        markers: updatedMarkers,
        selectedVenueId: venueId,
        clearSelectedVenueId: venueId == null,
      ),
    );
  }

  void clearSelection() => selectMarker(null);

  /// Usado pela busca (US2): garante que o venue selecionado exista no estado
  /// atual (mesmo que esteja fora da área já carregada) e o seleciona.
  Future<void> selectVenueById(String venueId) async {
    final alreadyLoaded = state.markers.any((marker) => marker.venue.id == venueId);
    if (!alreadyLoaded) {
      final venue = await _venueRepository.fetchVenueById(venueId);
      if (venue == null) return;
      final events = await _eventRepository.fetchEventsByVenue(venueId);
      if (events.isEmpty) return;
      emit(
        state.copyWith(
          markers: [...state.markers, MapMarkerViewModel(venue: venue, activeEvents: events)],
        ),
      );
    }
    selectMarker(venueId);
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Combina os filtros ativos (FR-009/FR-010): AND entre grupos (gênero, lotação, data),
  /// OR dentro do mesmo grupo — a filtragem em si acontece em [DiscoveryState.visibleMarkers].
  void applyFilters(FilterCriteria criteria) {
    emit(state.copyWith(filterCriteria: criteria));
  }

  void clearFilters() {
    emit(state.copyWith(filterCriteria: FilterCriteria.none));
  }
}
