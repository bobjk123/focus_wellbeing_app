import 'package:flutter_test/flutter_test.dart';

import 'package:focus_wellbeing_app/main.dart';

void main() {
  testWidgets('muestra el estado inicial de la aplicación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Base de datos cifrada localmente con AES-256.'),
      findsOneWidget,
    );
  });
}
