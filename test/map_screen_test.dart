import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission_planner_wireframe/features/map/presentation/screens/map_screen.dart';

void main() {
  testWidgets('MapScreen renders without exception', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pumpAndSettle();
  });
}
