import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:bora_la/features/discovery/data/location_service.dart';
import 'package:bora_la/features/discovery/data/venue_repository.dart';
import 'package:bora_la/features/discovery/presentation/cubit/discovery_cubit.dart';
import 'package:bora_la/features/discovery/presentation/cubit/discovery_state.dart';
import 'package:bora_la/features/discovery/presentation/widgets/event_detail_panel.dart';
import 'package:bora_la/features/discovery/presentation/widgets/event_marker.dart';
import 'package:bora_la/features/events/data/event_repository.dart';

/// Harness mínimo que replica o contrato de comportamento
/// "toque no marcador -> DiscoveryCubit.selectMarker -> EventDetailPanel exibe as
/// informações do evento" descrito em contracts/discovery-repository.md, sem
/// depender da renderização real do FlutterMap (evita tiles de rede em teste).
class _MapContractHarness extends StatelessWidget {
  const _MapContractHarness({required this.cubit});

  final DiscoveryCubit cubit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          body: BlocBuilder<DiscoveryCubit, DiscoveryState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        for (final marker in state.visibleMarkers)
                          EventMarker(
                            venueName: marker.venue.name,
                            trafficStatus: marker.venue.trafficStatus,
                            isSelected: marker.isSelected,
                            isFeatured: marker.isRelevant,
                            onTap: () => cubit.selectMarker(marker.venue.id),
                          ),
                      ],
                    ),
                  ),
                  if (state.selectedVenueId != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: EventDetailPanel(
                          marker: state.selectedMarker,
                          onClose: cubit.clearSelection,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('selecting a marker opens the detail panel with venue/event info', (tester) async {
    final cubit = DiscoveryCubit(
      venueRepository: VenueRepositoryImpl(),
      eventRepository: EventRepositoryImpl(),
      locationService: LocationService(),
    );

    // Carrega os venues mockados diretamente (bounds cobrindo o mundo todo), sem
    // passar pelo geolocator — este teste cobre o contrato marcador -> painel, não
    // a resolução de localização (sem handler de plugin em widget tests).
    // runAsync: os repositórios mockados usam Future.delayed, que não resolve sob
    // o relógio virtual padrão do widget test.
    await tester.runAsync(() async {
      await cubit.loadVenuesInBounds(
        LatLngBounds(const LatLng(-90, -180), const LatLng(90, 180)),
      );
    });

    await tester.pumpWidget(_MapContractHarness(cubit: cubit));
    await tester.pumpAndSettle();

    final markerFinder = find.byWidgetPredicate(
      (widget) => widget is EventMarker && widget.venueName == 'Bar do Bairro',
    );
    expect(markerFinder, findsOneWidget);

    await tester.tap(markerFinder);
    await tester.pumpAndSettle();

    expect(find.text('Bar do Bairro'), findsOneWidget);
    expect(find.text('Sábado de Música ao Vivo'), findsOneWidget);
    expect(find.text('MPB'), findsOneWidget);
    expect(find.textContaining('Movimentado'), findsWidgets);

    cubit.close();
  });

  testWidgets('detail panel shows a friendly error state when marker is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EventDetailPanel(marker: null)),
      ),
    );

    expect(
      find.text('Não foi possível carregar as informações deste local.'),
      findsOneWidget,
    );
  });
}
