import 'package:flutter/material.dart';

/// Chip do sistema visual do BoraLá — substitui `ChoiceChip`/`FilterChip` do
/// Material para manter identidade própria e estados de interação explícitos
/// (selecionado, hover, pressionado, desabilitado), per FR-015.
class SelectableChip extends StatefulWidget {
  const SelectableChip({
    super.key,
    required this.selected,
    required this.onTap,
    this.label,
    this.child,
    this.enabled = true,
  }) : assert(label != null || child != null, 'Informe label ou child');

  final bool selected;
  final VoidCallback onTap;
  final String? label;
  final Widget? child;
  final bool enabled;

  @override
  State<SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<SelectableChip> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final enabled = widget.enabled;

    final Color background;
    final Color border;
    if (!enabled) {
      background = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
      border = Colors.transparent;
    } else if (widget.selected) {
      background = accent;
      border = accent;
    } else if (_hovered) {
      background = accent.withValues(alpha: 0.08);
      border = accent.withValues(alpha: 0.5);
    } else {
      background = theme.colorScheme.surface;
      border = theme.colorScheme.outlineVariant;
    }

    final foreground = !enabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
        : widget.selected
            ? Colors.white
            : theme.colorScheme.onSurface;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onTap : null,
        child: Semantics(
          button: true,
          selected: widget.selected,
          enabled: enabled,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.95 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 1.5),
                boxShadow: widget.selected && enabled
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: foreground,
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                child: widget.child ?? Text(widget.label!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
