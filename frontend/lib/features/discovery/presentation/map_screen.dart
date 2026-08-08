import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/di/service_locator.dart';
import '../../events/data/event_repository.dart';
import '../../search/data/search_repository.dart';
import '../../search/domain/search_result.dart';
import '../data/location_service.dart';
import '../data/venue_repository.dart';
import '../domain/map_marker_view_model.dart';
import '../domain/user_location.dart';
import 'cubit/discovery_cubit.dart';
import 'cubit/discovery_state.dart';
import 'widgets/discovery_search_bar.dart';
import 'widgets/event_detail_panel.dart';
import 'widgets/event_marker.dart';
import 'widgets/filter_panel.dart';

const double _desktopBreakpoint = 900;
const double _sidePanelWidth = 380;

/// Tela raiz do BoraLá: mapa interativo como elemento central, com busca,
/// filtros e painel de detalhes sobrepostos, responsiva entre mobile e desktop.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoveryCubit(
        venueRepository: getIt<VenueRepository>(),
        eventRepository: getIt<EventRepository>(),
        locationService: getIt<LocationService>(),
      )..initialize(),
      child: const _MapScreenBody(),
    );
  }
}

class _MapScreenBody extends StatefulWidget {
  const _MapScreenBody();

  @override
  State<_MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<_MapScreenBody> {
  final MapController _mapController = MapController();
  bool _isDetailSheetOpen = false;
  bool _isFilterPanelOpenDesktop = false;
  bool _locationNoticeDismissed = false;

  static const _fallbackZoom = 14.0;
  static const _focusZoom = 16.0;

  void _focusOn(double latitude, double longitude, {double? zoom}) {
    _mapController.move(LatLng(latitude, longitude), zoom ?? _mapController.camera.zoom);
  }

  void _handleMarkerTap(MapMarkerViewModel marker) {
    context.read<DiscoveryCubit>().selectMarker(marker.venue.id);
    _focusOn(marker.venue.latitude, marker.venue.longitude);
  }

  Future<void> _handleSearchResult(SearchResult result) async {
    final cubit = context.read<DiscoveryCubit>();
    await cubit.selectVenueById(result.venueId);
    final marker = cubit.state.selectedMarker;
    if (marker != null) {
      _focusOn(marker.venue.latitude, marker.venue.longitude, zoom: _focusZoom);
    }
  }

  Future<void> _openMobileDetailSheet() async {
    _isDetailSheetOpen = true;
    final cubit = context.read<DiscoveryCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
            builder: (context, state) {
              return DraggableScrollableSheet(
                initialChildSize: 0.42,
                minChildSize: 0.2,
                maxChildSize: 0.85,
                expand: false,
                builder: (context, scrollController) {
                  return Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _SheetHandle(),
                          EventDetailPanel(
                            marker: state.selectedMarker,
                            onClose: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
    _isDetailSheetOpen = false;
    if (!mounted) return;
    context.read<DiscoveryCubit>().clearSelection();
  }

  Future<void> _openMobileFilterSheet() async {
    final cubit = context.read<DiscoveryCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
            builder: (context, state) {
              return Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SheetHandle(),
                      FilterPanel(
                        criteria: state.filterCriteria,
                        availableGenres: _availableGenres(state),
                        onChanged: cubit.applyFilters,
                        onClose: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Set<String> _availableGenres(DiscoveryState state) {
    final genres = <String>{};
    for (final marker in state.markers) {
      for (final event in marker.activeEvents) {
        genres.add(event.genre);
      }
    }
    return genres;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DiscoveryCubit, DiscoveryState>(
        listenWhen: (previous, current) =>
            previous.selectedVenueId != current.selectedVenueId ||
            previous.userLocation != current.userLocation,
        listener: (context, state) {
          final userLocation = state.userLocation;
          if (userLocation != null && userLocation.isPermissionGranted) {
            _focusOn(userLocation.latitude, userLocation.longitude, zoom: _fallbackZoom);
          }

          final isDesktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
          if (isDesktop) return;
          if (state.selectedVenueId != null && !_isDetailSheetOpen) {
            _openMobileDetailSheet();
          } else if (state.selectedVenueId == null && _isDetailSheetOpen) {
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final isDesktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;

          // StackFit.expand: sem isso o Stack se dimensiona pelo único filho não
          // posicionado (a barra de busca) — Positioned.fill não contribui para o
          // tamanho — e o mapa ficava limitado à altura da busca.
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _DiscoveryMap(
                  mapController: _mapController,
                  onMarkerTap: _handleMarkerTap,
                ),
              ),
              if (state.status == DiscoveryStatus.loading) const _LoadingOverlay(),
              if (state.status == DiscoveryStatus.error)
                _MessageOverlay(
                  message: state.errorMessage ?? 'Não foi possível carregar os eventos.',
                  actionLabel: 'Tentar novamente',
                  onAction: () => context.read<DiscoveryCubit>().initialize(),
                ),
              if (state.status == DiscoveryStatus.loaded &&
                  state.markers.isEmpty &&
                  state.filterCriteria.isEmpty)
                const _MessageOverlay(message: 'Nenhum evento por perto no momento.'),
              if (state.hasNoResultsForFilters)
                _MessageOverlay(
                  message: 'Nenhum evento para os filtros selecionados.',
                  actionLabel: 'Limpar filtros',
                  onAction: () => context.read<DiscoveryCubit>().clearFilters(),
                ),
              if (state.isUsingFallbackLocation && !_locationNoticeDismissed)
                _LocationFallbackNotice(
                  onDismiss: () => setState(() => _locationNoticeDismissed = true),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DiscoverySearchBar(
                          searchRepository: getIt<SearchRepository>(),
                          onResultSelected: _handleSearchResult,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FilterButton(
                        isActive: !state.filterCriteria.isEmpty,
                        onPressed: () {
                          if (isDesktop) {
                            setState(() => _isFilterPanelOpenDesktop = !_isFilterPanelOpenDesktop);
                          } else {
                            _openMobileFilterSheet();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (isDesktop && (state.selectedVenueId != null || _isFilterPanelOpenDesktop))
                _DesktopSidePanel(
                  child: state.selectedVenueId != null
                      ? EventDetailPanel(
                          marker: state.selectedMarker,
                          onClose: () => context.read<DiscoveryCubit>().clearSelection(),
                        )
                      : FilterPanel(
                          criteria: state.filterCriteria,
                          availableGenres: _availableGenres(state),
                          onChanged: context.read<DiscoveryCubit>().applyFilters,
                          onClose: () => setState(() => _isFilterPanelOpenDesktop = false),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

}

/// O [FlutterMap] é construído uma única vez: reconstruir o widget (e o
/// [MapOptions]) a cada emissão do Cubit fazia a câmera perder o tamanho medido
/// no primeiro layout, e o mapa passava a desenhar tiles apenas numa faixa da tela.
/// As camadas que dependem do estado ficam em [BlocBuilder]s aninhados.
class _DiscoveryMap extends StatelessWidget {
  const _DiscoveryMap({required this.mapController, required this.onMarkerTap});

  final MapController mapController;
  final ValueChanged<MapMarkerViewModel> onMarkerTap;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(UserLocation.fallback.latitude, UserLocation.fallback.longitude),
        initialZoom: _MapScreenBodyState._fallbackZoom,
        onTap: (_, __) => context.read<DiscoveryCubit>().clearSelection(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.bora_la',
          maxNativeZoom: 20,
        ),
        BlocBuilder<DiscoveryCubit, DiscoveryState>(
          buildWhen: (previous, current) =>
              previous.visibleMarkers != current.visibleMarkers ||
              previous.selectedVenueId != current.selectedVenueId,
          builder: (context, state) {
            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 48,
                size: const Size(44, 44),
                markers: [
                  for (final marker in state.visibleMarkers)
                    Marker(
                      point: LatLng(marker.venue.latitude, marker.venue.longitude),
                      width: 96,
                      height: 56,
                      alignment: Alignment.topCenter,
                      child: EventMarker(
                        venueName: marker.venue.name,
                        trafficStatus: marker.venue.trafficStatus,
                        isSelected: marker.isSelected,
                        isFeatured: marker.isRelevant,
                        onTap: () => onMarkerTap(marker),
                      ),
                    ),
                ],
                builder: (context, markers) => _ClusterBadge(count: markers.length),
              ),
            );
          },
        ),
        BlocBuilder<DiscoveryCubit, DiscoveryState>(
          buildWhen: (previous, current) => previous.userLocation != current.userLocation,
          builder: (context, state) {
            final userLocation = state.userLocation;
            if (userLocation == null || !userLocation.isPermissionGranted) {
              return const SizedBox.shrink();
            }
            return MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(userLocation.latitude, userLocation.longitude),
                  width: 26,
                  height: 26,
                  child: const _UserLocationMarker(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sua localização',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2563EB),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterBadge extends StatelessWidget {
  const _ClusterBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.isActive, required this.onPressed});

  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            Icons.tune_rounded,
            color: isActive ? Colors.white : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DesktopSidePanel extends StatelessWidget {
  const _DesktopSidePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: _sidePanelWidth,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: Offset.zero,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }
}

/// Alça de arraste dos painéis deslizantes no mobile.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// Aviso discreto quando a localização não está disponível e o mapa caiu na
/// região padrão — o app segue utilizável, mas o usuário entende o porquê (FR-017).
class _LocationFallbackNotice extends StatelessWidget {
  const _LocationFallbackNotice({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.paddingOf(context).top + 88,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * -8), child: child),
        ),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 3,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Icon(Icons.location_off_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sem acesso à sua localização — mostrando uma região padrão.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Dispensar',
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MessageOverlay extends StatelessWidget {
  const _MessageOverlay({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel!, style: const TextStyle(color: Colors.amberAccent)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
