import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/app.dart';

void main() {
  testWidgets('renders app title', (tester) async {
    await tester.pumpWidget(const BoraLaApp());

    expect(find.text('BoraLá'), findsWidgets);
  });
}
