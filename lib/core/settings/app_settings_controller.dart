import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _usePhoneGpsKey = 'use_phone_gps';

  /// Default on so the GCS map can follow the device without an extra toggle trip.
  bool _usePhoneGps = true;

  bool get usePhoneGps => _usePhoneGps;

  AppSettingsController() {
    _load();
  }

  void setUsePhoneGps(bool value) {
    if (_usePhoneGps == value) return;
    _usePhoneGps = value;
    _save();
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getBool(_usePhoneGpsKey);
      if (v != null) {
        _usePhoneGps = v;
        notifyListeners();
      }
    } catch (_) {
      // Best-effort only.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_usePhoneGpsKey, _usePhoneGps);
    } catch (_) {
      // Best-effort only.
    }
  }
}

class SettingsScope extends InheritedNotifier<AppSettingsController> {
  const SettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope not found in widget tree');
    return scope!.notifier!;
  }
}

