import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/ui/app_spacing.dart';

/// Startup loading screen (wireframe).
///
/// Future:
/// - Perform real initialization here (local DB, cached missions, module registry, auth).
/// - Replace the simulated steps with real services and error handling.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _steps = <String>[
    'Booting GCS UI…',
    'Loading vehicle profiles…',
    'Loading cached missions…',
    'Initializing modules…',
    'Starting map workspace…',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Wireframe: simulate app init sequence.
    _timer = Timer.periodic(const Duration(milliseconds: 420), (t) {
      if (!mounted) return;
      if (_index >= _steps.length - 1) {
        t.cancel();
        _goNext();
        return;
      }
      setState(() => _index += 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goNext() async {
    // Tiny delay to avoid jarring transition.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.flight, size: 64, color: scheme.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Drone Mission Planner',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ground Control Station • Loading',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (_index + 1) / _steps.length,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.memory_outlined, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(_steps[_index])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: const Text('Drone silhouette / splash artwork (placeholder)'),
              ),
              const Spacer(),
              Text(
                'v0.1 • Wireframe foundation',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

