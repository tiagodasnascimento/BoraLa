import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bora_la/features/discovery/presentation/widgets/discovery_search_bar.dart';
import 'package:bora_la/features/search/data/search_repository.dart';
import 'package:bora_la/features/search/domain/search_result.dart';

void main() {
  testWidgets('search with a match shows results and selecting one notifies the caller', (tester) async {
    SearchResult? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoverySearchBar(
            searchRepository: SearchRepository(),
            onResultSelected: (result) => selected = result,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Jazz');
    // Os repositórios mockados usam Future.delayed; pumpAndSettle sozinho não
    // avança esses timers (só espera frames), então adianta-se o relógio aqui.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Noite de Jazz'), findsOneWidget);

    await tester.tap(find.text('Noite de Jazz'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.venueId, 'venue_003');
    expect(find.text('Noite de Jazz'), findsNothing);
  });

  testWidgets('search without a match shows a clear empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoverySearchBar(
            searchRepository: SearchRepository(),
            onResultSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'zzzznotfound');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum resultado encontrado.'), findsOneWidget);
  });
}
