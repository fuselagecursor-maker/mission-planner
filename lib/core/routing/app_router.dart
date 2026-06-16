import 'package:flutter/material.dart';

import '../auth/auth_session.dart';
import '../../features/airspace/presentation/screens/airspace_screen.dart';
import '../../features/camera/presentation/screens/camera_payload_screen.dart';
import '../../features/manual_control/presentation/screens/manual_control_screen.dart';
import '../../features/plugins/presentation/screens/plugin_manager_screen.dart';
import '../../features/power/presentation/screens/power_management_screen.dart';
import '../../features/replay/presentation/screens/mission_replay_screen.dart';
import '../../features/telemetry/presentation/screens/telemetry_dashboard_screen.dart';
import '../../features/vehicles/presentation/screens/multi_vehicle_screen.dart';
import '../../features/fsm/presentation/screens/fsm_viewer_screen.dart';
import '../../features/firmware/presentation/screens/firmware_flash_screen.dart';
import '../../features/flight_modes/presentation/screens/flight_mode_reference_screen.dart';
import '../../features/help/presentation/screens/help_about_screen.dart';
import '../../features/vehicle_setup/presentation/screens/agri_payload_screen.dart';
import '../../features/vehicle_setup/presentation/screens/battery_power_screen.dart';
import '../../features/vehicle_setup/presentation/screens/mission_map_core_screen.dart';
import '../../features/vehicle_setup/presentation/screens/navigation_arming_safety_screen.dart';
import '../../features/vehicle_setup/presentation/screens/ops_logging_screen.dart';
import '../../features/vehicle_setup/presentation/screens/radio_rc_screen.dart';
import '../../features/vehicle_setup/presentation/screens/sensors_calibration_screen.dart';
import '../../features/vehicle_setup/presentation/screens/vehicle_setup_hub_screen.dart';
import '../../features/mission/presentation/screens/mission_details_screen.dart';
import '../../features/mission/presentation/screens/mission_editor_screen.dart';
import '../../features/mission/presentation/screens/mission_wizard_screen.dart';
import '../../features/dashboard/presentation/screens/alerts_inbox_screen.dart';
import '../../features/auth/presentation/screens/admin_registration_requests_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../screens/gcs_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

/// Centralized route names for consistency and future deep-linking.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const register = '/register';
  static const adminRegistrationRequests = '/admin/registration-requests';
  static const shell = '/';
  static const missionDetails = '/mission-details';
  static const missionWizard = '/mission-wizard';
  static const missionEditor = '/mission-editor';
  static const manualControl = '/manual-control';
  static const cameraPayload = '/camera-payload';
  static const telemetry = '/telemetry';
  static const power = '/power';
  static const airspace = '/airspace';
  static const replay = '/replay';
  static const plugins = '/plugins';
  static const vehicles = '/vehicles';
  static const fsmViewer = '/fsm-viewer';
  static const firmwareFlash = '/firmware-flash';
  static const flightModeReference = '/flight-mode-reference';
  static const alertsInbox = '/alerts-inbox';
  static const helpAbout = '/help-about';
  static const vehicleSetup = '/vehicle-setup';
  static const vehicleSetupSensors = '/vehicle-setup-sensors';
  static const vehicleSetupRadio = '/vehicle-setup-radio';
  static const vehicleSetupBattery = '/vehicle-setup-battery';
  static const vehicleSetupNavSafety = '/vehicle-setup-nav-safety';
  static const vehicleSetupAgri = '/vehicle-setup-agri';
  static const vehicleSetupOps = '/vehicle-setup-ops';
  static const vehicleSetupMission = '/vehicle-setup-mission';
}

/// Basic, package-free routing.
///
/// Future extensions:
/// - Replace with GoRouter when adding deep-links, auth guards, or nested flows.
/// - Add typed route args and URL-based navigation.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.shell:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const GcsShell(),
        );

      case AppRoutes.auth:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );

      case AppRoutes.adminRegistrationRequests:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => AuthSession.instance.isAdmin
              ? const AdminRegistrationRequestsScreen()
              : const _AdminAccessDeniedScreen(),
        );

      case AppRoutes.missionDetails:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MissionDetailsScreen(missionId: args as String?),
        );

      case AppRoutes.missionWizard:
        return MaterialPageRoute<void>(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => const MissionWizardScreen(),
        );

      case AppRoutes.missionEditor:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MissionEditorScreen(missionId: args as String?),
        );

      case AppRoutes.manualControl:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ManualControlScreen(),
        );

      case AppRoutes.cameraPayload:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CameraPayloadScreen(),
        );

      case AppRoutes.telemetry:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TelemetryDashboardScreen(),
        );

      case AppRoutes.power:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PowerManagementScreen(),
        );

      case AppRoutes.airspace:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AirspaceScreen(),
        );

      case AppRoutes.replay:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MissionReplayScreen(),
        );

      case AppRoutes.plugins:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PluginManagerScreen(),
        );

      case AppRoutes.vehicles:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MultiVehicleScreen(),
        );

      case AppRoutes.fsmViewer:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const FsmViewerScreen(),
        );

      case AppRoutes.firmwareFlash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const FirmwareFlashScreen(),
        );

      case AppRoutes.flightModeReference:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const FlightModeReferenceScreen(),
        );

      case AppRoutes.alertsInbox:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AlertsInboxScreen(),
        );

      case AppRoutes.helpAbout:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HelpAboutScreen(),
        );

      case AppRoutes.vehicleSetup:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const VehicleSetupHubScreen(),
        );
      case AppRoutes.vehicleSetupSensors:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SensorsCalibrationScreen(),
        );
      case AppRoutes.vehicleSetupRadio:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RadioRcScreen(),
        );
      case AppRoutes.vehicleSetupBattery:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BatteryPowerScreen(),
        );
      case AppRoutes.vehicleSetupNavSafety:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NavigationArmingSafetyScreen(),
        );
      case AppRoutes.vehicleSetupAgri:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AgriPayloadScreen(),
        );
      case AppRoutes.vehicleSetupOps:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OpsLoggingScreen(),
        );
      case AppRoutes.vehicleSetupMission:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MissionMapCoreScreen(),
        );

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => _UnknownRouteScreen(routeName: settings.name),
        );
    }
  }
}

/// Shown when a non-admin opens an admin-only route (pilots never see the real admin UI).
class _AdminAccessDeniedScreen extends StatelessWidget {
  const _AdminAccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This area is only available to administrators.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Text('Route not found: ${routeName ?? '(null)'}'),
      ),
    );
  }
}

