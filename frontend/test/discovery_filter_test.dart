import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bora_la/features/discovery/domain/filter_criteria.dart';
import 'package:bora_la/features/discovery/presentation/widgets/filter_panel.dart';
import 'package:bora_la/features/discovery/presentation/widgets/selectable_chip.dart';

/// Harness que guarda o [FilterCriteria] localmente, replicando como o
/// DiscoveryCubit reconstruiria o FilterPanel a cada mudança de estado.
class _FilterHarness extends StatefulWidget {
  const _FilterHarness();

  @override
  State<_FilterHarness> createState() => _FilterHarnessState();
}

class _FilterHarnessState extends State<_FilterHarness> {
  FilterCriteria criteria = FilterCriteria.none;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FilterPanel(
          criteria: criteria,
          availableGenres: const {'Jazz', 'Eletrônica'},
          onChanged: (updated) => setState(() => criteria = updated),
        ),
      ),
    );
  }
}

/// Recupera o [SelectableChip] que contém o texto informado, para inspecionar
/// seu estado `selected`.
SelectableChip _chipWith(WidgetTester tester, String label) {
  return tester.widget<SelectableChip>(
    find.ancestor(of: find.text(label), matching: find.byType(SelectableChip)),
  );
}

void main() {
  testWidgets('selecting a single genre filter marks it as selected', (tester) async {
    await tester.pumpWidget(const _FilterHarness());

    expect(_chipWith(tester, 'Jazz').selected, isFalse);

    await tester.tap(find.text('Jazz'));
    await tester.pumpAndSettle();

    expect(_chipWith(tester, 'Jazz').selected, isTrue);
  });

  testWidgets('combining genre + traffic filters keeps both active (AND across groups)', (tester) async {
    await tester.pumpWidget(const _FilterHarness());

    await tester.tap(find.text('Jazz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tranquilo'));
    await tester.pumpAndSettle();

    expect(_chipWith(tester, 'Jazz').selected, isTrue);
    expect(_chipWith(tester, 'Tranquilo').selected, isTrue);
  });

  testWidgets('clearing filters resets every active criterion', (tester) async {
    await tester.pumpWidget(const _FilterHarness());

    await tester.tap(find.text('Jazz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tranquilo'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar'), findsOneWidget);

    await tester.tap(find.text('Limpar'));
    await tester.pumpAndSettle();

    expect(_chipWith(tester, 'Jazz').selected, isFalse);
    expect(_chipWith(tester, 'Tranquilo').selected, isFalse);
    expect(find.text('Limpar'), findsNothing);
  });
}
