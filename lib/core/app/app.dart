import 'package:flutter/material.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class MissionPlannerApp extends StatefulWidget {
  const MissionPlannerApp({super.key});

  @override
  State<MissionPlannerApp> createState() => _MissionPlannerAppState();
}

class _MissionPlannerAppState extends State<MissionPlannerApp> {
  final ThemeController _theme = ThemeController();

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _theme,
      child: AnimatedBuilder(
        animation: _theme,
        builder: (context, _) {
          return MaterialApp(
            title: 'Mission Planner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _theme.mode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }
}

