import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/connection_status_banner.dart';
import '../../../../shared/widgets/section_header.dart';

enum _ConnectionKind { simulated, udp, serial }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _hapticFeedback = true;

  _ConnectionKind _connection = _ConnectionKind.simulated;
  final _udpHostController = TextEditingController(text: '127.0.0.1');
  final _udpPortController = TextEditingController(text: '14550');
  final _serialPortController = TextEditingController(text: 'COM3');

  static const _altitudeUnits = ['Metres (m)', 'Feet (ft)'];
  static const _speedUnits = ['m/s', 'km/h', 'mph'];
  static const _coordFormats = ['Decimal degrees', 'DMS'];

  String _altitudeUnit = _altitudeUnits.first;
  String _speedUnit = _speedUnits.first;
  String _coordFormat = _coordFormats.first;
  double _telemetryUiHz = 4;

  final _profileNameController = TextEditingController(text: 'Operator Name');
  final _profileEmailController = TextEditingController(text: 'role@organization');
  String _profileRole = 'Operator';

  @override
  void dispose() {
    _udpHostController.dispose();
    _udpPortController.dispose();
    _serialPortController.dispose();
    _profileNameController.dispose();
    _profileEmailController.dispose();
    super.dispose();
  }

  String get _connectionSummary => switch (_connection) {
        _ConnectionKind.simulated => 'Simulated link · no hardware',
        _ConnectionKind.udp => 'UDP · ${_udpHostController.text}:${_udpPortController.text}',
        _ConnectionKind.serial => 'Serial · ${_serialPortController.text}',
      };

  ConnectionStateLabel get _connectionBannerState => switch (_connection) {
        _ConnectionKind.simulated => ConnectionStateLabel.simulated,
        _ConnectionKind.udp => ConnectionStateLabel.connected,
        _ConnectionKind.serial => ConnectionStateLabel.connected,
      };

  void _showProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Operator profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _profileNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _profileEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email / account',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _profileRole,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                        DropdownMenuItem(value: 'Navigator', child: Text('Navigator')),
                        DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _profileRole = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile saved (wireframe)')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConnectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Connection & link',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Wireframe only — no sockets opened.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SegmentedButton<_ConnectionKind>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _ConnectionKind.simulated,
                          label: Text('Sim'),
                          tooltip: 'Simulated — local state',
                        ),
                        ButtonSegment(
                          value: _ConnectionKind.udp,
                          label: Text('UDP'),
                          tooltip: 'UDP / MAVLink',
                        ),
                        ButtonSegment(
                          value: _ConnectionKind.serial,
                          label: Text('Serial'),
                          tooltip: 'Serial device',
                        ),
                      ],
                      selected: {_connection},
                      onSelectionChanged: (Set<_ConnectionKind> next) {
                        if (next.isEmpty) return;
                        final v = next.first;
                        setModalState(() => _connection = v);
                        setState(() => _connection = v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      switch (_connection) {
                        _ConnectionKind.simulated =>
                          'Simulated: no network stack; HUD uses dummy telemetry.',
                        _ConnectionKind.udp =>
                          'UDP: set host/port for MAVLink bridge (wireframe).',
                        _ConnectionKind.serial =>
                          'Serial: device path for USB radio or FC (wireframe).',
                      },
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (_connection == _ConnectionKind.udp) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _udpHostController,
                        decoration: const InputDecoration(
                          labelText: 'Host',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _udpPortController,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                    if (_connection == _ConnectionKind.serial) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _serialPortController,
                        decoration: const InputDecoration(
                          labelText: 'Port / device',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        var biometric = false;
        var sessionTimeout = '15 min';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Security',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    title: const Text('Biometric unlock'),
                    subtitle: const Text('Require Face / fingerprint to resume session'),
                    value: biometric,
                    onChanged: (v) => setModalState(() => biometric = v),
                  ),
                  ListTile(
                    title: const Text('Session timeout'),
                    trailing: DropdownButton<String>(
                      value: sessionTimeout,
                      items: const [
                        DropdownMenuItem(value: '5 min', child: Text('5 min')),
                        DropdownMenuItem(value: '15 min', child: Text('15 min')),
                        DropdownMenuItem(value: '1 h', child: Text('1 h')),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => sessionTimeout = v);
                      },
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dropdownStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConnectionStatusBanner(
                state: _connectionBannerState,
                onTap: _showConnectionSheet,
              ),
            ),
          ),
          const SectionHeader(title: 'Profile'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(_profileNameController.text),
                subtitle: Text('$_profileRole · ${_profileEmailController.text}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showProfileSheet,
              ),
            ),
          ),
          const SectionHeader(title: 'Connection & link'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.link_outlined),
                title: const Text('Vehicle link'),
                subtitle: Text(_connectionSummary),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showConnectionSheet,
              ),
            ),
          ),
          const SectionHeader(title: 'Vehicle & preflight'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: const Text('Open feature checklist hub'),
                subtitle: const Text('Sensors, RC, battery, safety, agri, ops, mission (wireframe)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, AppRoutes.vehicleSetup),
              ),
            ),
          ),
          const SectionHeader(title: 'Preferences'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Mission alerts and reminders'),
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Haptic feedback'),
                    subtitle: const Text('Taps on critical controls (wireframe)'),
                    value: _hapticFeedback,
                    onChanged: (v) => setState(() => _hapticFeedback = v),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(
                      switch (theme.mode) {
                        ThemeMode.dark => 'Dark (default)',
                        ThemeMode.light => 'Light',
                        ThemeMode.system => 'System',
                      },
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: theme.mode,
                        dropdownColor: scheme.surfaceContainerHighest,
                        style: dropdownStyle,
                        iconEnabledColor: scheme.onSurfaceVariant,
                        items: const [
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                        ],
                        onChanged: (m) {
                          if (m == null) return;
                          theme.setMode(m);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Units & formats'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Altitude'),
                    trailing: DropdownButton<String>(
                      value: _altitudeUnit,
                      dropdownColor: scheme.surfaceContainerHighest,
                      style: dropdownStyle,
                      iconEnabledColor: scheme.onSurfaceVariant,
                      items: [
                        for (final u in _altitudeUnits)
                          DropdownMenuItem(value: u, child: Text(u)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _altitudeUnit = v);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Speed'),
                    trailing: DropdownButton<String>(
                      value: _speedUnit,
                      dropdownColor: scheme.surfaceContainerHighest,
                      style: dropdownStyle,
                      iconEnabledColor: scheme.onSurfaceVariant,
                      items: [
                        for (final u in _speedUnits)
                          DropdownMenuItem(value: u, child: Text(u)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _speedUnit = v);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Coordinates'),
                    trailing: DropdownButton<String>(
                      value: _coordFormat,
                      dropdownColor: scheme.surfaceContainerHighest,
                      style: dropdownStyle,
                      iconEnabledColor: scheme.onSurfaceVariant,
                      items: [
                        for (final u in _coordFormats)
                          DropdownMenuItem(value: u, child: Text(u)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _coordFormat = v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Telemetry UI'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard refresh (Hz)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Slider(
                      value: _telemetryUiHz,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _telemetryUiHz.toStringAsFixed(0),
                      onChanged: (v) => setState(() => _telemetryUiHz = v),
                    ),
                    Text(
                      'Placeholder — does not affect timers in this wireframe.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'System'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Security'),
                    subtitle: const Text('Biometric, session timeout'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showSecuritySheet,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About & help'),
                    subtitle: const Text('Version, SRS notes, tips'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.helpAbout);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
