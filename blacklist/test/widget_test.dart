import 'package:flutter_test/flutter_test.dart';
import 'package:blacklist/main.dart';

void main() {
  testWidgets('App loads LoginScreen test', (WidgetTester tester) async {
    await tester.pumpWidget(const CotejoNotarialApp());
    expect(find.text('Ingreso al Sistema'), findsOneWidget);
  });
}
