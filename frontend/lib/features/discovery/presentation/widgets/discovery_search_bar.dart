import 'package:flutter/material.dart';

import '../../../search/data/search_repository.dart';
import '../../../search/domain/search_result.dart';

/// Busca por eventos e locais com resultados em tempo real (FR-007/FR-008).
class DiscoverySearchBar extends StatefulWidget {
  const DiscoverySearchBar({
    super.key,
    required this.searchRepository,
    required this.onResultSelected,
  });

  final SearchRepository searchRepository;
  final ValueChanged<SearchResult> onResultSelected;

  @override
  State<DiscoverySearchBar> createState() => _DiscoverySearchBarState();
}

class _DiscoverySearchBarState extends State<DiscoverySearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<SearchResult> _results = const [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String query) async {
    final results = await widget.searchRepository.searchEvents(query);
    if (!mounted) return;
    setState(() {
      _results = query.trim().isEmpty ? const [] : results;
      _hasSearched = query.trim().isNotEmpty;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _results = const [];
      _hasSearched = false;
    });
  }

  void _selectResult(SearchResult result) {
    widget.onResultSelected(result);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _results = const [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showPanel = _focusNode.hasFocus && _hasSearched;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar eventos ou locais',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _clear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: showPanel ? _buildResultsPanel(theme) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel(ThemeData theme) {
    if (_results.isEmpty) {
      return Padding(
        key: const ValueKey('empty'),
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 3,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhum resultado encontrado.'),
          ),
        ),
      );
    }

    // Os itens ficam dentro de um Material (e não de um Container decorado) para
    // que o ListTile pinte fundo e ripple sobre a superfície correta.
    return Padding(
      key: const ValueKey('results'),
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = _results[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(result.name),
                subtitle: Text('${result.venueName} • ${result.category}'),
                onTap: () => _selectResult(result),
              );
            },
          ),
        ),
      ),
    );
  }
}
