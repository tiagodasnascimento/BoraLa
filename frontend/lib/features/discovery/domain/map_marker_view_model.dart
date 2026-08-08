import '../../events/domain/event.dart';
import 'venue.dart';

/// View-state derivado (não é uma entidade de negócio) que combina um [Venue]
/// com os eventos ativos após filtragem e o estado de seleção do marcador.
class MapMarkerViewModel {
  const MapMarkerViewModel({
    required this.venue,
    required this.activeEvents,
    this.isSelected = false,
  });

  final Venue venue;
  final List<EventItem> activeEvents;
  final bool isSelected;

  bool get isRelevant => venue.isFeatured || activeEvents.any((event) => event.isPopular);

  MapMarkerViewModel copyWith({
    List<EventItem>? activeEvents,
    bool? isSelected,
  }) {
    return MapMarkerViewModel(
      venue: venue,
      activeEvents: activeEvents ?? this.activeEvents,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
