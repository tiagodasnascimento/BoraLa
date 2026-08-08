import 'package:flutter/material.dart';

import '../../../traffic/domain/venue_status.dart';
import '../../domain/filter_criteria.dart';
import 'crowd_level_indicator.dart';
import 'selectable_chip.dart';

/// Painel de filtros combináveis: gênero musical + nível de movimento (FR-009/FR-010).
class FilterPanel extends StatelessWidget {
  const FilterPanel({
    super.key,
    required this.criteria,
    required this.availableGenres,
    required this.onChanged,
    this.onClose,
  });

  final FilterCriteria criteria;
  final Set<String> availableGenres;
  final ValueChanged<FilterCriteria> onChanged;
  final VoidCallback? onClose;

  void _toggleGenre(String genre) {
    final updated = Set<String>.from(criteria.genres);
    if (!updated.remove(genre)) updated.add(genre);
    onChanged(criteria.copyWith(genres: updated));
  }

  void _toggleCrowdLevel(CrowdLevel level) {
    final updated = Set<VenueTrafficStatus>.from(criteria.trafficStatuses);
    if (updated.containsAll(level.statuses)) {
      updated.removeAll(level.statuses);
    } else {
      updated.addAll(level.statuses);
    }
    onChanged(criteria.copyWith(trafficStatuses: updated));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Filtros',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (!criteria.isEmpty)
                TextButton(
                  onPressed: () => onChanged(FilterCriteria.none),
                  child: const Text('Limpar'),
                ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Gênero musical', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          if (availableGenres.isEmpty)
            Text(
              'Nenhum gênero disponível na área atual.',
              style: theme.textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableGenres.map((genre) {
                return SelectableChip(
                  label: genre,
                  selected: criteria.genres.contains(genre),
                  onTap: () => _toggleGenre(genre),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          Text('Nível de movimento', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CrowdLevel.values.map((level) {
              final selected = criteria.trafficStatuses.containsAll(level.statuses);
              return SelectableChip(
                selected: selected,
                onTap: () => _toggleCrowdLevel(level),
                child: CrowdLevelIndicator(
                  status: level.representativeStatus,
                  showLabel: true,
                  compact: true,
                  labelColor: selected ? Colors.white : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
