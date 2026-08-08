import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/app.dart';
import 'package:bora_la/core/di/service_locator.dart';

void main() {
  setUpAll(setupDependencies);

  testWidgets('renders the discovery map screen with search bar', (tester) async {
    await tester.pumpWidget(const BoraLaApp());
    // Um pump (sem pumpAndSettle) evita aguardar o carregamento de tiles de rede,
    // que não completa no ambiente de teste.
    await tester.pump();

    expect(find.text('Buscar eventos ou locais'), findsOneWidget);
  });
}
