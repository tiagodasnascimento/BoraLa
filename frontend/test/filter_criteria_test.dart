import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

import 'package:bora_la/features/discovery/domain/filter_criteria.dart';
import 'package:bora_la/features/events/domain/event.dart';
import 'package:bora_la/features/traffic/domain/venue_status.dart';

/// Teste unitário da regra de combinação de filtros (Princípio III da
/// constituição: toda regra de negócio MUST ter teste unitário).
EventItem _event({required String genre, DateTime? startAt, DateTime? endAt}) {
  final start = startAt ?? DateTime(2026, 8, 8, 20);
  return EventItem(
    id: 'evt',
    venueId: 'venue',
    name: 'Evento',
    genre: genre,
    startAt: start,
    endAt: endAt ?? start.add(const Duration(hours: 3)),
    category: 'Música',
    isPopular: false,
  );
}

void main() {
  group('FilterCriteria.matches', () {
    test('sem filtros ativos, tudo passa', () {
      expect(
        FilterCriteria.none.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Jazz')],
        ),
        isTrue,
      );
    });

    test('OR dentro do grupo de gêneros: basta um evento corresponder', () {
      const criteria = FilterCriteria(genres: {'Jazz', 'Rock'});

      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Samba'), _event(genre: 'Rock')],
        ),
        isTrue,
      );
      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Samba')],
        ),
        isFalse,
      );
    });

    test('AND entre grupos: gênero e lotação precisam casar simultaneamente', () {
      const criteria = FilterCriteria(
        genres: {'Jazz'},
        trafficStatuses: {VenueTrafficStatus.crowded},
      );

      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.crowded,
          events: [_event(genre: 'Jazz')],
        ),
        isTrue,
      );
      // Gênero casa, lotação não.
      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Jazz')],
        ),
        isFalse,
      );
      // Lotação casa, gênero não.
      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.crowded,
          events: [_event(genre: 'Samba')],
        ),
        isFalse,
      );
    });

    test('filtro de data exclui evento inteiramente fora da janela', () {
      final criteria = FilterCriteria(
        dateRange: DateTimeRange(
          start: DateTime(2026, 8, 8),
          end: DateTime(2026, 8, 8, 23, 59),
        ),
      );

      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Jazz', startAt: DateTime(2026, 8, 8, 20))],
        ),
        isTrue,
      );
      expect(
        criteria.matches(
          trafficStatus: VenueTrafficStatus.low,
          events: [_event(genre: 'Jazz', startAt: DateTime(2026, 8, 10, 20))],
        ),
        isFalse,
      );
    });

    test('caso de borda: local sem nenhum evento não passa em filtro de gênero', () {
      const criteria = FilterCriteria(genres: {'Jazz'});

      expect(
        criteria.matches(trafficStatus: VenueTrafficStatus.low, events: const []),
        isFalse,
      );
    });
  });
}
