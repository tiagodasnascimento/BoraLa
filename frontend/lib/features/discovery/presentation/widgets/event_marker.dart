import 'package:flutter/material.dart';

import '../../../traffic/domain/venue_status.dart';
import 'crowd_level_indicator.dart';

/// Marcador customizado de local/evento no mapa — comunica visualmente, sem
/// depender só de texto, se está selecionado e se é relevante (FR-002/FR-003).
class EventMarker extends StatelessWidget {
  const EventMarker({
    super.key,
    required this.venueName,
    required this.trafficStatus,
    this.isSelected = false,
    this.isFeatured = false,
    this.onTap,
  });

  final String venueName;
  final VenueTrafficStatus trafficStatus;
  final bool isSelected;
  final bool isFeatured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bubbleColor = isSelected ? accent : Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          selected: isSelected,
          label: isFeatured ? 'Local em destaque: $venueName' : 'Local: $venueName',
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: isSelected ? 1.18 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isFeatured
                        ? Border.all(color: const Color(0xFFF59E0B), width: 2)
                        : Border.all(color: Colors.black.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.28 : 0.14),
                        blurRadius: isSelected ? 14 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : accent,
                      ),
                      const SizedBox(width: 6),
                      CrowdLevelIndicator(status: trafficStatus, compact: true),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(12, 7),
                  painter: _MarkerTailPainter(color: bubbleColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerTailPainter extends CustomPainter {
  const _MarkerTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MarkerTailPainter oldDelegate) => oldDelegate.color != color;
}
