# Mission Planner (Wireframe Exoskeleton)

This project is a **wireframe-only** Flutter foundation for a scalable Mission Planner mobile application.

## Docs

- **[Flight & preflight feature checklist](docs/FLIGHT_FEATURES_CHECKLIST.md)** — track GCS / drone features (K++-style) as you add them to the app.
- **In-app:** drawer → *Vehicle & preflight (checklist)*, or *Settings* → *Open feature checklist hub* — one screen per checklist section (S, R, P, N, A, O, M).

## What’s included

- Clean, modular `lib/` structure (`core/`, `features/`, `shared/`)
- Bottom navigation shell with 5 tabs
- Proper routing for details screens (e.g., Mission Details)
- Placeholder UI with consistent spacing, Cards, ListTiles, Containers
- Dummy models + dummy repositories (ready to swap with APIs later)
- Lightweight skeleton loading placeholders (no extra packages)

## Getting started (local)

1. Install Flutter (stable).
2. From this folder:

```bash
flutter pub get
flutter run
```

## Architecture notes

- **UI**: `features/*/presentation/` contains screens + widgets.
- **Domain**: `features/*/domain/` contains simple models and repository contracts.
- **Data**: `features/*/data/` contains dummy repositories (replace with API/DB later).
- **Core**: app shell, routing, theme, and common utilities.

