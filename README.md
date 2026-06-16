# Fuselage — Ground Control & Mission Planner

**Fuselage** is a cross-platform **Ground Control Station (GCS)** and **mission planning** client built with Flutter, paired with a **Node.js + PostgreSQL** authentication API. The product is branded **Fuselage** and targets agricultural and general drone operations workflows (map-centric GCS, waypoint missions, vehicle setup, telemetry, and preflight checklists).

> **Current maturity:** The Flutter app is a **wireframe exoskeleton** — navigation, UI flows, and simulated data are in place; most vehicle/telemetry features use placeholder or dummy repositories. **Authentication and admin registration approval are fully implemented** end-to-end against the backend. The `missions` database table exists but **mission CRUD over HTTP is not yet implemented**.

| | |
|---|---|
| **Repository** | [github.com/fuselagecursor-maker/mission-planner](https://github.com/fuselagecursor-maker/mission-planner) |
| **Client version** | `0.1.0+1` |
| **Dart SDK** | `>=3.4.0 <4.0.0` |
| **Backend** | Node.js 20, Express 5, PostgreSQL |

---

## Table of contents

- [Overview](#overview)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
- [Configuration](#configuration)
- [API reference](#api-reference)
- [Database schema](#database-schema)
- [User roles & authentication flow](#user-roles--authentication-flow)
- [Deployment](#deployment)
- [Development notes](#development-notes)
- [Documentation](#documentation)
- [Roadmap & known limitations](#roadmap--known-limitations)

---

## Overview

The system has two main parts:

1. **Flutter client (`lib/`)** — Runs on Android, iOS, Web, Windows, Linux, and macOS. After splash and sign-in, pilots land in the **GCS shell**: a map-first layout with sidebar sections (Map, Mission, Logs, Settings), a tools sheet for deep feature screens, and a collapsible telemetry panel.

2. **Auth API (`backend/`)** — Express HTTP service on port **4000** (default) with JWT authentication, bcrypt password hashing, pilot registration with **admin approval**, and PostgreSQL persistence. Schema migrations run automatically on server startup.

```text
┌─────────────────────┐         HTTP (JWT)          ┌──────────────────────┐
│  Flutter client     │  ─────────────────────────► │  Node.js API         │
│  (Fuselage GCS)     │   /auth/login, /register    │  (Express + pg)      │
│                     │   /auth/admin/*             │                      │
└─────────────────────┘                             └──────────┬───────────┘
                                                               │
                                                               ▼
                                                    ┌──────────────────────┐
                                                    │  PostgreSQL          │
                                                    │  users, missions     │
                                                    └──────────────────────┘
```

---

## Features

### Implemented (production-ready path)

| Area | Description |
|------|-------------|
| **Pilot sign-in / registration** | Email + password login; new pilots register with name, email, pilot ID, and password. |
| **Admin approval workflow** | New pilot accounts start as `pending`; admins approve or reject via UI and API. |
| **JWT sessions** | Token stored in `AuthSession`; role-based UI (e.g. admin registration screen). |
| **Health check** | `GET /health` probes database connectivity. |
| **Auto schema migration** | Server ensures `registration_status` column and `missions` table on boot. |

### Wireframe / in-progress (UI present, simulated or dummy data)

| Area | Description |
|------|-------------|
| **Interactive map** | `flutter_map` with simulated vehicle motion, airspace layer, waypoint markers, zoom rail, HUD, layers sheet, optional phone GPS (`geolocator`). |
| **Mission planning** | Mission wizard, editor with waypoint property sheet, agri waypoint kinds, waypoint nudge pad; load/save dialogs (placeholder persistence). |
| **GCS shell** | Map overlay layout, telemetry deck, emergency stop, RTH feedback, mission progress widget, manual control panel entry. |
| **Vehicle & preflight** | Hub plus seven subsection screens (sensors, radio, battery, nav/arming/safety, agri payload, ops logging, mission map core). |
| **Tools & extras** | Telemetry dashboard, camera/payload, airspace, replay, plugins, multi-vehicle, FSM viewer, firmware flash, flight mode reference, alerts inbox, help/about. |
| **Themes & settings** | Light/dark mode toggle, “use phone GPS” setting, simulated connection status. |

Track detailed GCS capability progress in [`docs/FLIGHT_FEATURES_CHECKLIST.md`](docs/FLIGHT_FEATURES_CHECKLIST.md) (K++/Agri Assistant–style checklist with stable IDs like `S01`, `M02`).

---

## Tech stack

### Client (Flutter)

| Package | Purpose |
|---------|---------|
| `flutter_map` + `latlong2` | Map rendering and coordinates |
| `geolocator` | Optional device GPS for map centering |
| `http` | Auth API calls |
| `shared_preferences` | Local settings persistence |
| `camera` | Camera/payload screen wireframe |
| `google_fonts` | Typography |

### Backend

| Package | Purpose |
|---------|---------|
| `express` | HTTP server |
| `pg` | PostgreSQL connection pool |
| `jsonwebtoken` | JWT sign/verify |
| `bcryptjs` | Password hashing (cost factor 10) |
| `cors` | Cross-origin configuration |
| `dotenv` | Environment variables |

### Platforms

- **Mobile / desktop:** Standard Flutter targets (`android/`, `ios/`, `windows/`, `linux/`, `macos/`)
- **Web:** Build with `flutter build web`; optional CI deploy to Vercel
- **API hosting:** Docker image at repo root (`Dockerfile`) for Railway or similar

---

## Architecture

### Client layering

The Flutter codebase follows a **feature-first** layout:

```text
lib/
├── core/           # App shell, routing, theme, auth session, settings
├── features/       # One folder per domain (auth, map, mission, telemetry, …)
│   └── <feature>/
│       ├── domain/         # Models, repository contracts
│       ├── data/           # Dummy repositories (swap for APIs later)
│       └── presentation/   # Screens and widgets
├── screens/        # GCS shell pages (mission, logs, settings)
├── shared/         # Reusable widgets (GCS deck, skeletons, emergency stop)
└── widgets/        # GCS chrome (sidebar, top bar, telemetry panel)
```

**Routing** is centralized in `lib/core/routing/app_router.dart` using named `MaterialPageRoute`s. Future work may adopt GoRouter for deep links and auth guards.

**Post-login flow:** `SplashScreen` → `LoginScreen` → `GcsShell` (`/`). An alternate `AppShell` with bottom tabs remains in the codebase but is not the default entry after login.

### Backend layering

```text
backend/
├── src/
│   ├── server.js    # Express app, /health, startup migrations
│   ├── auth.js      # /auth/* routes and JWT middleware
│   ├── db.js        # PostgreSQL pool (DATABASE_URL or PG* vars)
│   └── migrate.js   # Idempotent schema guards
└── sql/
    ├── init.sql                        # Full schema + seed users
    ├── migration_002_registration_status.sql
    └── migration_003_missions.sql
```

---

## Project structure

```text
mission-planner/
├── lib/                    # Flutter application
├── backend/                # Node.js auth API
├── android/ ios/ web/ …    # Flutter platform runners
├── docs/                   # SRS, architecture PDFs, checklists, reports
├── test/                   # Flutter widget tests
├── Dockerfile              # API-only production image
├── .github/workflows/      # Optional Vercel web deploy
└── pubspec.yaml
```

---

## Prerequisites

- **Flutter** (stable channel) — [flutter.dev](https://flutter.dev)
- **Node.js** 18+ (20 recommended for Docker parity)
- **PostgreSQL** 14+ (local or hosted, e.g. Railway)
- **Git**

For this development machine, tooling may be configured under `D:\dev\` (pub cache, Android SDK, JDK, etc.) — see workspace rules if applicable.

---

## Getting started

### 1. Clone the repository

```bash
git clone https://github.com/fuselagecursor-maker/mission-planner.git
cd mission-planner
```

### 2. Start the backend

```bash
cd backend
cp .env.example .env
# Edit .env with your PostgreSQL credentials
```

Create the database (example name: `mission_planner`), then apply the schema:

```bash
psql -U postgres -d mission_planner -f sql/init.sql
```

Install dependencies and run:

```bash
npm install
npm start
```

The API listens at **http://localhost:4000**. On startup you should see: `Database schema (users + missions) is up to date.`

**Default admin account** (from `init.sql`):

| Field | Value |
|-------|-------|
| Email | `admin@gmail.com` |
| Password | `admin` |

Change these credentials before any production deployment.

### 3. Run the Flutter client

From the repository root:

```bash
flutter pub get
flutter run
```

Point the client at your API when not using localhost defaults:

```bash
flutter run --dart-define=AUTH_API_URL=http://localhost:4000
```

For **web release builds**:

```bash
flutter build web --release --dart-define=AUTH_API_URL=https://your-api.example.com
```

### 4. Typical local workflow

1. Start PostgreSQL and the backend (`npm start` in `backend/`).
2. Run the Flutter app on your target device or emulator.
3. Sign in as **admin** to approve pending pilot registrations, or register a new pilot account and approve it from **Settings → Registration requests** (admin only) or the Tools sheet.

---

## Configuration

### Backend (`backend/.env`)

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | HTTP listen port | `4000` |
| `DATABASE_URL` | Full PostgreSQL URL (preferred on Railway) | — |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Discrete connection settings | localhost / postgres |
| `DB_SSL` | `true` / `false` — auto-detected for Railway public proxy | auto |
| `JWT_SECRET` | Signing secret (**required in production**) | dev fallback in code |
| `JWT_EXPIRES_IN` | Token lifetime | `12h` |
| `CORS_ORIGIN` | Allowed origin(s) or `*` | `*` |

The backend also reads Railway-style `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, and `PGPASSWORD` when `DATABASE_URL` is unset.

### Client

| Mechanism | Description |
|-----------|-------------|
| `--dart-define=AUTH_API_URL=...` | Auth API base URL (compile-time) |
| `AppSettingsController` | “Use phone GPS”, persisted via `shared_preferences` |
| `ThemeController` | Light / dark / system theme |

---

## API reference

Base URL: `http://localhost:4000` (or your deployed host).

### Health

```http
GET /health
```

**200** — `{ "status": "ok", "db": "up" }`  
**500** — `{ "status": "error", "db": "down", "detail": "..." }`

### Authentication

```http
POST /auth/register
Content-Type: application/json

{
  "name": "Jane Pilot",
  "email": "jane@example.com",
  "password": "secret",
  "pilotId": "PILOT-042"
}
```

**201** — Registration submitted (`registration_status: pending`).  
**409** — Email already registered or previously rejected.

```http
POST /auth/login
Content-Type: application/json

{
  "email": "jane@example.com",
  "password": "secret"
}
```

**200** — `{ "token": "<jwt>", "user": { ... } }`  
**403** — Account pending approval or rejected.

### Admin (requires `Authorization: Bearer <token>`, admin role)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/auth/admin/pending-registrations` | List pilots awaiting approval |
| `POST` | `/auth/admin/pending-registrations/:userId/approve` | Approve a pending pilot |
| `POST` | `/auth/admin/pending-registrations/:userId/reject` | Reject a pending pilot |

---

## Database schema

### `users`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `BIGSERIAL` | Primary key |
| `name` | `TEXT` | Display name |
| `email` | `TEXT` | Unique, normalized to lowercase |
| `password_hash` | `TEXT` | bcrypt |
| `pilot_id` | `TEXT` | Optional operator ID |
| `role` | `TEXT` | `pilot` or `admin` |
| `registration_status` | `TEXT` | `pending`, `approved`, `rejected` |
| `created_at` | `TIMESTAMPTZ` | Auto-set |

### `missions` (schema ready; API not yet exposed)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `BIGSERIAL` | Primary key |
| `owner_user_id` | `BIGINT` | FK → `users.id` |
| `name`, `description` | `TEXT` | Mission metadata |
| `start_at`, `end_at` | `TIMESTAMPTZ` | `end_at >= start_at` |
| `priority` | `TEXT` | `low`, `medium`, `high`, `critical` |
| `status` | `TEXT` | `draft`, `active`, `completed` |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | Timestamps |

Indexes: `owner_user_id`, `status`.

---

## User roles & authentication flow

```text
Register (pilot)          Admin reviews              Login (approved pilot)
      │                         │                            │
      ▼                         ▼                            ▼
 registration_status      approve / reject              JWT issued
     = pending            updates status              GcsShell (/)
```

| Role | Capabilities |
|------|----------------|
| **Guest** | Splash, login, registration screens |
| **Pilot** | GCS shell and all routed feature screens after `registration_status = approved` |
| **Administrator** | Same as pilot plus **Registration requests** UI and admin API endpoints |

Client session state lives in `lib/core/auth/auth_session.dart` (`token`, `user`, `isLoggedIn`, `isAdmin`).

---

## Deployment

### API (Docker / Railway)

The root `Dockerfile` builds an API-only image:

```bash
docker build -t fuselage-api .
docker run -p 4000:4000 --env-file backend/.env fuselage-api
```

On Railway, link a PostgreSQL plugin so `DATABASE_URL` or `PG*` variables are injected. Set a strong `JWT_SECRET` and restrict `CORS_ORIGIN` to your web client origin.

### Flutter web (Vercel via GitHub Actions)

Workflow: [`.github/workflows/deploy-web-vercel.yml`](.github/workflows/deploy-web-vercel.yml) (manual `workflow_dispatch`).

**Required GitHub secrets:**

| Secret | Example |
|--------|---------|
| `AUTH_API_URL` | `https://your-api.up.railway.app` |
| `VERCEL_TOKEN` | From [vercel.com/account/tokens](https://vercel.com/account/tokens) |

After the first deploy, set the API’s `CORS_ORIGIN` to your Vercel URL.

### Mobile builds

Use standard Flutter release commands (`flutter build apk`, `flutter build ios`, etc.). Configure signing via `android/key.properties.example` as a template.

---

## Development notes

- **Replace dummy repositories** in `lib/features/*/data/` when wiring real vehicle, mission, or telemetry APIs.
- **Mission persistence** — UI dialogs exist; connect to forthcoming `missions` REST endpoints.
- **Routing** — `AppRouter` lists all named routes in `AppRoutes`; unknown routes show a not-found screen.
- **Linting** — `flutter analyze` with `flutter_lints`.
- **Tests** — `flutter test` (see `test/widget_test.dart`).

### Key routes (selection)

| Route | Screen |
|-------|--------|
| `/splash` | Boot splash |
| `/auth`, `/register` | Login, registration |
| `/` | GCS shell (map home) |
| `/mission-wizard`, `/mission-editor` | Mission flows |
| `/admin/registration-requests` | Admin approval (admin only) |
| `/vehicle-setup` | Preflight / vehicle hub |
| `/help-about` | About Fuselage |

Full list: `lib/core/routing/app_router.dart`.

---

## Documentation

| Document | Description |
|----------|-------------|
| [`docs/SRS_Fuselage_Mission_Planner.md`](docs/SRS_Fuselage_Mission_Planner.md) | Software Requirements Specification (implemented vs wireframe) |
| [`docs/FLIGHT_FEATURES_CHECKLIST.md`](docs/FLIGHT_FEATURES_CHECKLIST.md) | GCS / preflight feature tracking checklist |
| [`docs/GCS_User_Manual.md`](docs/GCS_User_Manual.md) | User-facing manual |
| [`docs/GCS_Report.md`](docs/GCS_Report.md) | Project report |
| [`docs/arch/`](docs/arch/) | Architecture diagrams, class diagrams, tooling docs (HTML/PDF) |
| [`backend/README.md`](backend/README.md) | Backend quick-start (subset of this file) |

---

## Roadmap & known limitations

- [ ] REST API for **mission CRUD** against the `missions` table
- [ ] Refresh tokens and token revocation
- [ ] Live vehicle link (MAVLink, DDS, or vendor SDK) — currently simulated telemetry
- [ ] Persist missions from client load/save dialogs to backend
- [ ] GoRouter / deep linking and route-level auth guards
- [ ] Production hardening: rate limiting, audit logs, email notifications for registration

**Security reminders for production:**

- Set a strong `JWT_SECRET`
- Restrict `CORS_ORIGIN` to known client domains
- Enforce HTTPS on API and web client
- Remove or rotate default seeded accounts in `init.sql`
- Do not commit `backend/.env` (use `.env.example` as template)

---

## License

See repository settings for license terms. If no `LICENSE` file is present, contact the repository owner before redistribution.

---

**Fuselage** — Ground control and mission planning wireframe with real authentication, built for scalable GCS development.
