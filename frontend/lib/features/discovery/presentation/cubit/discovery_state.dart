import 'package:equatable/equatable.dart';

import '../../domain/filter_criteria.dart';
import '../../domain/map_marker_view_model.dart';
import '../../domain/user_location.dart';

enum DiscoveryStatus { initial, loading, loaded, error }

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.status = DiscoveryStatus.initial,
    this.userLocation,
    this.markers = const <MapMarkerViewModel>[],
    this.filterCriteria = FilterCriteria.none,
    this.searchQuery = '',
    this.selectedVenueId,
    this.errorMessage,
  });

  /// Localização resolvida pelo LocationService — nunca nula após [DiscoveryStatus.loaded]
  /// ou [DiscoveryStatus.error]; usa [UserLocation.fallback] quando a permissão é negada (FR-017).
  final UserLocation? userLocation;
  final DiscoveryStatus status;

  /// Marcadores carregados para a área visível atual, antes de aplicar [filterCriteria].
  final List<MapMarkerViewModel> markers;
  final FilterCriteria filterCriteria;
  final String searchQuery;
  final String? selectedVenueId;
  final String? errorMessage;

  /// Marcadores após aplicar os filtros ativos (AND entre grupos, OR dentro do grupo — FR-010).
  List<MapMarkerViewModel> get visibleMarkers =>
      markers.where((marker) => _matchesFilters(marker, filterCriteria)).toList(growable: false);

  bool get hasNoResultsForFilters => !filterCriteria.isEmpty && visibleMarkers.isEmpty;

  bool get isUsingFallbackLocation => userLocation != null && !userLocation!.isPermissionGranted;

  MapMarkerViewModel? get selectedMarker {
    final id = selectedVenueId;
    if (id == null) return null;
    for (final marker in markers) {
      if (marker.venue.id == id) return marker;
    }
    return null;
  }

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    UserLocation? userLocation,
    List<MapMarkerViewModel>? markers,
    FilterCriteria? filterCriteria,
    String? searchQuery,
    String? selectedVenueId,
    bool clearSelectedVenueId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      markers: markers ?? this.markers,
      filterCriteria: filterCriteria ?? this.filterCriteria,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedVenueId: clearSelectedVenueId ? null : (selectedVenueId ?? this.selectedVenueId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        userLocation,
        markers,
        filterCriteria,
        searchQuery,
        selectedVenueId,
        errorMessage,
      ];
}

bool _matchesFilters(MapMarkerViewModel marker, FilterCriteria criteria) {
  if (criteria.genres.isNotEmpty) {
    final hasMatchingGenre = marker.activeEvents.any((event) => criteria.genres.contains(event.genre));
    if (!hasMatchingGenre) return false;
  }

  if (criteria.trafficStatuses.isNotEmpty &&
      !criteria.trafficStatuses.contains(marker.venue.trafficStatus)) {
    return false;
  }

  final dateRange = criteria.dateRange;
  if (dateRange != null) {
    final hasEventInRange = marker.activeEvents.any(
      (event) => !event.startAt.isAfter(dateRange.end) && !event.endAt.isBefore(dateRange.start),
    );
    if (!hasEventInRange) return false;
  }

  return true;
}
