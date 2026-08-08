import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bora_la/core/di/service_locator.dart';
import 'package:bora_la/features/discovery/presentation/map_screen.dart';
import 'package:bora_la/features/discovery/presentation/widgets/filter_panel.dart';

/// Cobre FR-013/FR-014: a mesma tela deve recompor os controles conforme a
/// largura — painel lateral fixo no desktop, painel modal deslizante no mobile.
void main() {
  setUpAll(setupDependencies);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pump();
  }

  testWidgets('desktop width shows the filter panel inline, without a modal route', (tester) async {
    await pumpAt(tester, const Size(1400, 900));

    expect(find.byType(FilterPanel), findsNothing);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump();

    expect(find.byType(FilterPanel), findsOneWidget);
    // Painel lateral é parte da própria tela: nenhuma rota modal foi empilhada.
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('mobile width opens the filter panel as a sliding modal sheet', (tester) async {
    await pumpAt(tester, const Size(420, 900));

    await tester.tap(find.byIcon(Icons.tune_rounded));
    // pumpAndSettle não serve aqui: o mapa agenda frames continuamente e a
    // árvore nunca fica ociosa. Basta avançar além da animação do sheet.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FilterPanel), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
