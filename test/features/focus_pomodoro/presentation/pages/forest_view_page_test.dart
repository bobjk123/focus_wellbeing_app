import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/pages/forest_view_page.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

void main() {
  testWidgets('muestra estado vacío sin NaN cuando no hay árboles plantados',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForestViewPage(initialTrees: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Tu bosque está esperando su primer árbol'),
      findsOneWidget,
    );
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 Árboles'), findsOneWidget);
  });

  testWidgets('renderiza árboles sembrados y calcula efectividad correctamente',
      (tester) async {
    final now = DateTime.now();
    final trees = [
      PlantTree()
        ..uuid = 't1'
        ..species = 'Roble Nobilis'
        ..status = TreeStatus.completed
        ..plantedAt = now
        ..growthDurationMinutes = 25,
      PlantTree()
        ..uuid = 't2'
        ..species = 'Bonsai Zen'
        ..status = TreeStatus.withered
        ..plantedAt = now
        ..growthDurationMinutes = 10,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ForestViewPage(initialTrees: trees),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Roble Nobilis'), findsOneWidget);
    expect(find.text('1 Árboles'), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });
}
