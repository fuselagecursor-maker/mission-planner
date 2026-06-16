# Software Requirements Specification

## Fuselage Mission Planner

| Field | Value |
|--------|--------|
| **Product name** | Fuselage (Mission Planner wireframe) |
| **Repository** | `mission_planner_wireframe` (Flutter) + `backend` (Node.js) |
| **Document version** | 1.0 |
| **SDK / runtime** | Dart `>=3.4.0 <4.0.0`, Node.js (Express 5), PostgreSQL |
| **Scope** | Requirements as implemented or explicitly present in source, SQL, and configuration files in this repository only. |

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) describes the **Fuselage** ground-control and mission-planning client application and its **companion authentication service**. It is intended for developers, testers, and stakeholders who need a single reference for **what the system currently contains**, distinguishing **implemented behavior** from **placeholder / wireframe** UI.

### 1.2 Definitions

| Term | Meaning |
|------|---------|
| **GCS** | Ground Control Station (in-app shell around map, mission, logs, settings). |
| **Wireframe** | UI and navigation present; data may be simulated, dummy repositories, or static copy. |
| **Pilot** | User account with `role = pilot` in the database. |
| **Administrator** | User account with `role = admin` in the database. |
| **JWT** | JSON Web Token returned by `POST /auth/login` and stored in `AuthSession` on the client. |

### 1.3 References (in-repository)

| ID | Document / location |
|----|---------------------|
| R1 | `README.md` (project root) |
| R2 | `backend/README.md` |
| R3 | `docs/FLIGHT_FEATURES_CHECKLIST.md` |
| R4 | `pubspec.yaml` |
| R5 | `backend/package.json`, `backend/sql/init.sql`, `backend/src/*.js` |
| R6 | `lib/core/routing/app_router.dart`, `lib/core/app/app.dart` |

---

## 2. Overall Description

### 2.1 Product perspective

The system consists of:

1. **Flutter application** (`lib/`) — cross-platform client branded **Fuselage**; default entry is splash, then pilot sign-in, then primary **GCS shell** (`GcsShell`) with map-centric layout, sidebar sections, tools sheet, and optional push routes to additional screens.
2. **HTTP authentication API** (`backend/`) — Express application on configurable `PORT` (default **4000**), backed by **PostgreSQL**, exposing registration, login, admin registration review, and a database health probe.

There is **no** implemented REST API in this repository for **mission CRUD** against the `missions` table; the table and indexes exist in SQL and migration scripts for future use.

### 2.2 User classes

| Class | Description |
|-------|-------------|
| **Guest** | User before successful login; may use splash, sign-in, and registration screens. |
| **Pilot** | Authenticated user with approved registration (or admin logging in); uses GCS shell and routed feature screens. |
| **Administrator** | Authenticated user with `role === admin`; may access admin registration review UI and corresponding API endpoints. |
| **System operator** | Human or tool invoking `GET /health` (not called from Dart in this repo). |

### 2.3 Operating constraints

- Flutter **Material** themes (light/dark) via `MissionPlannerApp` and `ThemeController`.
- Auth API base URL from `AuthApi`: compile-time `String.fromEnvironment('AUTH_API_URL', defaultValue: 'http://localhost:4000')`.
- Backend requires `JWT_SECRET` (or dev default in code), PostgreSQL connection per `backend/.env.example`, CORS from `CORS_ORIGIN` or `*`.

---

## 3. Functional Requirements

### 3.1 Application bootstrap and navigation

| ID | Requirement |
|----|----------------|
| **FR-APP-01** | On launch, `MaterialApp` shall use `initialRoute` **`/splash`** (`AppRoutes.splash`). |
| **FR-APP-02** | `SplashScreen` shall run a timed boot simulation and then navigate to **`/auth`** (login). |
| **FR-APP-03** | `AppRouter.onGenerateRoute` shall resolve all route names defined in `AppRoutes` to the corresponding screen widgets (see Appendix A). |
| **FR-APP-04** | Unknown route names shall display `_UnknownRouteScreen` with the attempted route name. |

### 3.2 Pilot authentication (client)

| ID | Requirement |
|----|----------------|
| **FR-AUTH-01** | `LoginScreen` shall collect email and password, validate non-empty email (contains `@`) and password minimum length **4**, and submit via `AuthApi.login`. |
| **FR-AUTH-02** | On successful login response containing `token` and `user`, the client shall call `AuthSession.instance.setSession` and navigate with **`pushReplacementNamed`** to **`/`** (`GcsShell`). |
| **FR-AUTH-03** | On failure, the client shall display decoded error text from the API response body. |
| **FR-AUTH-04** | From login, user shall navigate to **`/register`** via outlined button. |

### 3.3 Pilot registration (client + server)

| ID | Requirement |
|----|----------------|
| **FR-REG-01** | `RegisterScreen` shall collect name, email, **pilot ID** (required by form validators; minimum **4** characters), and password (minimum **4** characters). |
| **FR-REG-02** | On submit, the client shall call `AuthApi.register` with JSON body fields aligned with backend expectations. |
| **FR-REG-03** | Success shall display server `message` or a default approval-pending message. |
| **FR-REG-04** | `POST /auth/register` shall create a `pilot` row with `registration_status = pending` unless validation fails, email conflicts, or rejected-email policy applies (see `backend/src/auth.js`). |
| **FR-REG-05** | Passwords shall be stored only as **bcrypt** hashes (cost factor **10** in implementation). |

### 3.4 Session and role (client)

| ID | Requirement |
|----|----------------|
| **FR-SES-01** | `AuthSession` shall hold nullable `token` and `user` map. |
| **FR-SES-02** | `isLoggedIn` shall be true when `token` is non-null and non-empty. |
| **FR-SES-03** | `isAdmin` shall be true when `user['role']` (lowercased) equals **`admin`**. |

### 3.5 Administrator registration review (client + server)

| ID | Requirement |
|----|----------------|
| **FR-ADM-01** | Route **`/admin/registration-requests`** shall render `AdminRegistrationRequestsScreen` when `AuthSession.instance.isAdmin` is true; otherwise `_AdminAccessDeniedScreen`. |
| **FR-ADM-02** | On load and refresh, the admin screen shall call `GET /auth/admin/pending-registrations` with `Authorization: Bearer <token>`. |
| **FR-ADM-03** | Approve shall `POST .../pending-registrations/:userId/approve`; reject shall confirm via dialog then `POST .../reject`. |
| **FR-ADM-04** | After approve/reject, the UI shall reload the pending list and show snack bar feedback. |
| **FR-ADM-05** | Backend shall enforce JWT validation and **`requireAdmin`** on admin routes. |

### 3.6 GCS shell (primary post-login experience)

| ID | Requirement |
|----|----------------|
| **FR-GCS-01** | `GcsShell` shall keep **map** as the base layer when the map section is active; `MapScreen` receives `GcsStatusModel` for top bar and right telemetry panel updates. |
| **FR-GCS-02** | Sidebar shall switch sections: **map**, **mission** (`MissionPage`), **logs** (`LogsPage`), **settings** (`SettingsPage`). |
| **FR-GCS-03** | **Tools** modal shall list navigation targets: registration requests (admin only), telemetry, camera, manual control, airspace, replay, plugins, vehicles, vehicle setup hub — each `pushNamed` to the corresponding `AppRoutes` value. |
| **FR-GCS-04** | Top bar shall expose tools, telemetry panel toggle, and close overlay when not on map section. |
| **FR-GCS-05** | Right **telemetry** strip shall show collapsible panel with fields bound to `GcsStatusModel` (altitude, speed, battery, GPS, EKF/IMU/compass status lines as implemented in `MapScreen` / model). |

### 3.7 Mission page (client)

| ID | Requirement |
|----|----------------|
| **FR-MIS-01** | `MissionPage` shall provide **Load** and **Save** actions opening `showLoadMissionDialog` / `showSaveMissionDialog` (placeholder persistence messaging). |
| **FR-MIS-02** | **New mission** shall navigate to **`/mission-wizard`**. |

### 3.8 Map workspace (client)

| ID | Requirement |
|----|----------------|
| **FR-MAP-01** | `MapScreen` shall render `flutter_map` with simulated vehicle motion, optional airspace layer, mission waypoint markers, map layers sheet, zoom rail, bottom dock, HUD, manual control panel entry, RTH feedback, mission progress widget, and emergency stop control as implemented in source. |
| **FR-MAP-02** | When **Use phone GPS** is enabled in app settings, the map shall use `geolocator` stream per implementation in `MapScreen` and `AppSettingsController`. |
| **FR-MAP-03** | Map primary FAB flow shall include navigation to **mission wizard** for new mission. |

### 3.9 Settings (GCS tactical settings page)

| ID | Requirement |
|----|----------------|
| **FR-SET-01** | `SettingsPage` shall allow toggling **force light mode** via `ThemeController`. |
| **FR-SET-02** | Shall allow toggling **use phone GPS** via `AppSettingsController`. |
| **FR-SET-03** | Shall show a **Connection** list tile (simulated link copy). |
| **FR-SET-04** | If `isAdmin`, shall provide navigation to admin registration requests route. |

### 3.10 Routed feature screens (wireframe)

Each of the following shall be reachable via `Navigator.pushNamed` with the route name in Appendix A and shall present the UI implemented in its screen file (placeholder content unless otherwise noted):

Mission wizard, mission editor, mission details; manual control; camera/payload; telemetry dashboard; power management; airspace; mission replay; plugin manager; multi-vehicle; FSM viewer; firmware flash; flight mode reference; alerts inbox; help/about; vehicle setup hub and seven subsection screens (sensors, radio, battery, navigation/arming/safety, agri payload, ops logging, mission map core).

### 3.11 Alternate shell (legacy / wide-layout wireframe)

| ID | Requirement |
|----|----------------|
| **FR-ALT-01** | `AppShell` with bottom tabs and `DashboardScreen`, `MissionsScreen`, `MapScreen`, `TasksScreen`, `SettingsScreen` remains in the codebase with drawer navigation to overlapping feature set; it is **not** the default route after login in `MissionPlannerApp`. |

### 3.12 Backend HTTP API

| ID | Requirement |
|----|----------------|
| **FR-API-01** | `GET /health` shall execute `SELECT 1` against PostgreSQL and return JSON `{ status, db }` or error JSON with `detail` / `code` on failure. |
| **FR-API-02** | `POST /auth/register` and `POST /auth/login` shall behave as implemented in `backend/src/auth.js` (status codes 200/201/400/401/403/409/500 as applicable). |
| **FR-API-03** | Admin endpoints shall require `Authorization: Bearer <JWT>`. |
| **FR-API-04** | JWT payload shall include at minimum `sub`, `email`, `role` (see `signToken` in `auth.js`). |

### 3.13 Data persistence (database)

| ID | Requirement |
|----|----------------|
| **FR-DB-01** | Schema shall support `users` with fields and checks per `backend/sql/init.sql` (including `registration_status` and `role`). |
| **FR-DB-02** | Schema shall support `missions` with owner FK, time range constraint, priority and status enums, timestamps, and indexes on `owner_user_id` and `status` as in `init.sql` / `migrate.js`. |
| **FR-DB-03** | Server startup shall run `ensureUserRegistrationSchema` and `ensureMissionsTable` before listening (see `server.js`). |

---

## 4. Non-functional requirements

| ID | Requirement |
|----|----------------|
| **NFR-01** | Client shall declare dependencies in `pubspec.yaml` (Flutter, `http`, `shared_preferences`, `flutter_map`, `latlong2`, `geolocator`, `camera`, `google_fonts`, etc.). |
| **NFR-02** | Backend shall declare runtime dependencies in `backend/package.json` (`express`, `pg`, `jsonwebtoken`, `bcryptjs`, `cors`, `dotenv`). |
| **NFR-03** | `backend/README.md` shall document production guidance: strong `JWT_SECRET`, restricted `CORS_ORIGIN`, HTTPS, and future refresh-token work. |
| **NFR-04** | Root `README.md` describes the Flutter layer as **wireframe** with dummy repositories replaceable by APIs later. |

---

## 5. External interface requirements

### 5.1 Client ↔ Auth API

- **Protocol:** HTTPS-capable HTTP client (`package:http`); default URL `http://localhost:4000` unless overridden by `--dart-define=AUTH_API_URL=...`.
- **Content-Type:** `application/json` for POST bodies.
- **Admin requests:** `Authorization: Bearer <token>`.

### 5.2 Client ↔ map / location / camera

- **Maps:** OpenStreetMap-style tiles via `flutter_map` (see `MapScreen` and related logic files).
- **Location:** `geolocator` permission and stream handling as coded.
- **Camera:** `camera` package available to project; individual screens determine usage.

---

## 6. Traceability: checklist IDs (documentation only)

`docs/FLIGHT_FEATURES_CHECKLIST.md` defines **S01–M03** checklist IDs for future completeness against a K++/agri-style GCS. Rows are **documentation placeholders**; the app’s vehicle setup hub screens reference these IDs in copy. Implementation status per ID is **not** asserted in this SRS unless verified in code separately.

---

## Appendix A — Flutter route catalog (`AppRoutes`)

| Route constant | Path string | Screen |
|----------------|--------------|--------|
| `splash` | `/splash` | `SplashScreen` |
| `shell` | `/` | `GcsShell` |
| `auth` | `/auth` | `LoginScreen` |
| `register` | `/register` | `RegisterScreen` |
| `adminRegistrationRequests` | `/admin/registration-requests` | `AdminRegistrationRequestsScreen` or access denied |
| `missionDetails` | `/mission-details` | `MissionDetailsScreen` |
| `missionWizard` | `/mission-wizard` | `MissionWizardScreen` |
| `missionEditor` | `/mission-editor` | `MissionEditorScreen` |
| `manualControl` | `/manual-control` | `ManualControlScreen` |
| `cameraPayload` | `/camera-payload` | `CameraPayloadScreen` |
| `telemetry` | `/telemetry` | `TelemetryDashboardScreen` |
| `power` | `/power` | `PowerManagementScreen` |
| `airspace` | `/airspace` | `AirspaceScreen` |
| `replay` | `/replay` | `MissionReplayScreen` |
| `plugins` | `/plugins` | `PluginManagerScreen` |
| `vehicles` | `/vehicles` | `MultiVehicleScreen` |
| `fsmViewer` | `/fsm-viewer` | `FsmViewerScreen` |
| `firmwareFlash` | `/firmware-flash` | `FirmwareFlashScreen` |
| `flightModeReference` | `/flight-mode-reference` | `FlightModeReferenceScreen` |
| `alertsInbox` | `/alerts-inbox` | `AlertsInboxScreen` |
| `helpAbout` | `/help-about` | `HelpAboutScreen` |
| `vehicleSetup` | `/vehicle-setup` | `VehicleSetupHubScreen` |
| `vehicleSetupSensors` | `/vehicle-setup-sensors` | `SensorsCalibrationScreen` |
| `vehicleSetupRadio` | `/vehicle-setup-radio` | `RadioRcScreen` |
| `vehicleSetupBattery` | `/vehicle-setup-battery` | `BatteryPowerScreen` |
| `vehicleSetupNavSafety` | `/vehicle-setup-nav-safety` | `NavigationArmingSafetyScreen` |
| `vehicleSetupAgri` | `/vehicle-setup-agri` | `AgriPayloadScreen` |
| `vehicleSetupOps` | `/vehicle-setup-ops` | `OpsLoggingScreen` |
| `vehicleSetupMission` | `/vehicle-setup-mission` | `MissionMapCoreScreen` |

---

## Appendix B — REST endpoints implemented

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| GET | `/health` | No | Liveness + DB connectivity |
| POST | `/auth/register` | No | Create pending pilot |
| POST | `/auth/login` | No | Issue JWT for approved/relevant users |
| GET | `/auth/admin/pending-registrations` | Admin JWT | List pending pilots |
| POST | `/auth/admin/pending-registrations/:userId/approve` | Admin JWT | Approve pilot |
| POST | `/auth/admin/pending-registrations/:userId/reject` | Admin JWT | Reject pilot |

---

## Appendix C — Explicit out-of-scope (not in repository)

- Mission persistence **HTTP API** against `missions` table.
- Refresh tokens, token revocation lists.
- Live MAVLink / drone link integration (simulated / placeholder UI only).
- Push notifications, email delivery, or SMS.

---

*End of SRS document.*
