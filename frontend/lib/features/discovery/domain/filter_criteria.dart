import 'package:flutter/material.dart' show DateTimeRange;

import '../../events/domain/event.dart';
import '../../traffic/domain/venue_status.dart';

class FilterCriteria {
  const FilterCriteria({
    this.genres = const <String>{},
    this.trafficStatuses = const <VenueTrafficStatus>{},
    this.dateRange,
  });

  final Set<String> genres;
  final Set<VenueTrafficStatus> trafficStatuses;
  final DateTimeRange? dateRange;

  bool get isEmpty => genres.isEmpty && trafficStatuses.isEmpty && dateRange == null;

  /// Regra de combinação dos filtros (FR-010): AND entre grupos (gênero, lotação,
  /// data) e OR dentro do mesmo grupo. Vive no domínio — a camada de apresentação
  /// apenas consulta o resultado (Princípio I da constituição).
  bool matches({
    required VenueTrafficStatus trafficStatus,
    required List<EventItem> events,
  }) {
    if (genres.isNotEmpty && !events.any((event) => genres.contains(event.genre))) {
      return false;
    }

    if (trafficStatuses.isNotEmpty && !trafficStatuses.contains(trafficStatus)) {
      return false;
    }

    final range = dateRange;
    if (range != null) {
      final hasEventInRange = events.any(
        (event) => !event.startAt.isAfter(range.end) && !event.endAt.isBefore(range.start),
      );
      if (!hasEventInRange) return false;
    }

    return true;
  }

  FilterCriteria copyWith({
    Set<String>? genres,
    Set<VenueTrafficStatus>? trafficStatuses,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return FilterCriteria(
      genres: genres ?? this.genres,
      trafficStatuses: trafficStatuses ?? this.trafficStatuses,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }

  static const FilterCriteria none = FilterCriteria();
}
