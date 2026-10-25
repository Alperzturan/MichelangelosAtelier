import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MichelangelosAtelierApp());
    expect(find.text("Michelangelo's Atelier"), findsWidgets);
  });
}

