import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/reports/presentation/pages/weekly_reports_page.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

void main() {
  testWidgets('muestra estado vacío cuando no hay límites registrados',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WeeklyReportsPage(
          initialWeeklyFocusMinutes: [0, 0, 0, 0, 0, 0, 0],
          initialUsageLimits: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0m'), findsWidgets);
    expect(
      find.text('Sin registros de aplicaciones esta semana'),
      findsOneWidget,
    );
  });

  testWidgets('renderiza totales semanales y cumplimiento de límites reales',
      (tester) async {
    final limit = UsageLimit()
      ..packageName = 'com.instagram.android'
      ..appName = 'Instagram'
      ..dailyLimitMinutes = 30
      ..currentUsageMinutes = 45
      ..isBlocked = true
      ..lastUpdated = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(
        home: WeeklyReportsPage(
          initialWeeklyFocusMinutes: const [25, 50, 0, 25, 0, 0, 0],
          initialUsageLimits: [limit],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1h 40m'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Excedido'), findsOneWidget);
    expect(find.text('Uso: 45m / Límite: 30m'), findsOneWidget);
  });
}
