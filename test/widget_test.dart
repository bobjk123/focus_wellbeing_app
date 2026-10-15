import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:focus_wellbeing_app/main.dart';

void main() {
  testWidgets('muestra el estado inicial de la aplicación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(
      home: Scaffold(body: Text('Focus & Wellbeing App')),
    ));

    expect(find.text('Focus & Wellbeing App'), findsOneWidget);
  });
}
