import 'package:flutter/material.dart' show DateTimeRange;

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
