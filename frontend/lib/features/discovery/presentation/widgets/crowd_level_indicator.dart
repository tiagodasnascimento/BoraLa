import 'package:flutter/material.dart';

import '../../../traffic/domain/venue_status.dart';

/// Os três níveis de movimento apresentados ao usuário (FR-006). O domínio tem
/// quatro estados; `medium` e `high` são apresentados como um único "Movimentado",
/// conforme o mapeamento definido em data-model.md.
enum CrowdLevel {
  calm(VenueTrafficStatus.low),
  busy(VenueTrafficStatus.medium),
  packed(VenueTrafficStatus.crowded);

  const CrowdLevel(this.representativeStatus);

  /// Status usado para renderizar o indicador visual deste nível.
  final VenueTrafficStatus representativeStatus;

  /// Todos os status do domínio que este nível representa.
  Set<VenueTrafficStatus> get statuses => switch (this) {
        CrowdLevel.calm => {VenueTrafficStatus.low},
        CrowdLevel.busy => {VenueTrafficStatus.medium, VenueTrafficStatus.high},
        CrowdLevel.packed => {VenueTrafficStatus.crowded},
      };

  static CrowdLevel of(VenueTrafficStatus status) => switch (status) {
        VenueTrafficStatus.low => CrowdLevel.calm,
        VenueTrafficStatus.medium || VenueTrafficStatus.high => CrowdLevel.busy,
        VenueTrafficStatus.crowded => CrowdLevel.packed,
      };
}

/// Nível visual de lotação (3 níveis), mapeado a partir de [VenueTrafficStatus]
/// conforme data-model.md: low→tranquilo, medium/high→movimentado, crowded→muito movimentado.
///
/// Comunica o nível por cor + número de barras preenchidas — nunca depende só de texto (FR-006).
class CrowdLevelIndicator extends StatelessWidget {
  const CrowdLevelIndicator({
    super.key,
    required this.status,
    this.showLabel = false,
    this.compact = false,
    this.labelColor,
  });

  final VenueTrafficStatus status;
  final bool showLabel;
  final bool compact;

  /// Sobrescreve a cor do texto quando o indicador é usado sobre um fundo
  /// colorido (ex.: chip selecionado). As barras mantêm a cor do nível.
  final Color? labelColor;

  static const _tiers = <VenueTrafficStatus, _CrowdTier>{
    VenueTrafficStatus.low: _CrowdTier(label: 'Tranquilo', color: Color(0xFF22C55E), bars: 1),
    VenueTrafficStatus.medium: _CrowdTier(label: 'Movimentado', color: Color(0xFFF59E0B), bars: 2),
    VenueTrafficStatus.high: _CrowdTier(label: 'Movimentado', color: Color(0xFFF59E0B), bars: 2),
    VenueTrafficStatus.crowded: _CrowdTier(label: 'Muito movimentado', color: Color(0xFFEF4444), bars: 3),
  };

  @override
  Widget build(BuildContext context) {
    final tier = _tiers[status]!;
    final barHeight = compact ? 6.0 : 10.0;
    final barWidth = compact ? 3.0 : 4.0;

    return Semantics(
      label: 'Nível de movimento: ${tier.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final filled = index < tier.bars;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index == 2 ? 0 : 2),
                width: barWidth,
                height: barHeight + (index * (compact ? 3 : 4)),
                decoration: BoxDecoration(
                  color: filled ? tier.color : tier.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              tier.label,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: labelColor ?? tier.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CrowdTier {
  const _CrowdTier({required this.label, required this.color, required this.bars});

  final String label;
  final Color color;
  final int bars;
}
