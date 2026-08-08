import 'package:flutter/material.dart';

import '../../../events/domain/event.dart';
import '../../domain/map_marker_view_model.dart';
import 'crowd_level_indicator.dart';

/// Painel de detalhes de um local/evento selecionado — exibido como bottom
/// sheet (mobile) ou painel lateral (desktop) sem ocultar o mapa (FR-004/FR-005).
class EventDetailPanel extends StatelessWidget {
  const EventDetailPanel({super.key, required this.marker, this.onClose});

  /// `null` representa o estado de erro (venue não encontrado — contracts/discovery-repository.md).
  final MapMarkerViewModel? marker;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final marker = this.marker;
    if (marker == null) {
      return _PanelScaffold(
        onClose: onClose,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, size: 32, color: Colors.redAccent),
              SizedBox(height: 8),
              Text(
                'Não foi possível carregar as informações deste local.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final venue = marker.venue;
    final events = marker.activeEvents;
    final theme = Theme.of(context);
    final now = DateTime.now();

    return _PanelScaffold(
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            venue.name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CrowdLevelIndicator(status: venue.trafficStatus, showLabel: true),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...events.map((event) => _EventTile(event: event, isHappeningNow: event.isHappeningAt(now))),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.isHappeningNow});

  final EventItem event;
  final bool isHappeningNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (isHappeningNow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Agora',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(event.genre, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.schedule_rounded, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(formatEventDateTime(event.startAt), style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelScaffold extends StatelessWidget {
  const _PanelScaffold({required this.child, this.onClose});

  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Fechar',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

const _weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
const _months = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', //
];

String formatEventDateTime(DateTime dateTime) {
  final weekday = _weekdays[dateTime.weekday - 1];
  final month = _months[dateTime.month - 1];
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$weekday, ${dateTime.day} $month • $hour:$minute';
}
