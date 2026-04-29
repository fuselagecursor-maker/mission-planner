import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory theme mode controller.
///
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  // Default to dark so the GCS "tactical" UI looks consistent across devices.
  // Users can still switch to Light/System in Settings and it will persist.
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;

  ThemeController() {
    _load();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _save(mode);
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      final loaded = _decode(raw);
      if (loaded != null && loaded != _mode) {
        _mode = loaded;
        notifyListeners();
      }
    } catch (_) {
      // Best-effort only; keep default.
    }
  }

  Future<void> _save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(mode));
    } catch (_) {
      // Best-effort only.
    }
  }

  static ThemeMode? _decode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  static String _encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found in widget tree');
    return scope!.notifier!;
  }
}

