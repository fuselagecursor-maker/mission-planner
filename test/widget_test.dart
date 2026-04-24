import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mission_planner_wireframe/core/theme/app_theme.dart';
import 'package:mission_planner_wireframe/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Drone Mission Planner'), findsOneWidget);
  });
}
