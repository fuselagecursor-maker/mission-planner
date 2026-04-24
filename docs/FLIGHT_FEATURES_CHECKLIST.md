# Flight & preflight feature checklist

**In the app (wireframe):** open the **drawer** → **Vehicle & preflight (checklist)**, or **Settings** → **Open feature checklist hub**. The hub has seven sections; each section screen lists the same **IDs** (S01, R01, …) as below — tap a row for a placeholder until the feature is real.

Use this to track work toward **K++ / Agri Assistant–style** and general GCS capabilities.  
**Tick a line** when something exists in the repo (wireframe, partial, or full integration). Add **location** in italics on the same line or the line below.

**IDs** are stable for issues/PRs (e.g. `S01`).

**Last reviewed:** _add date when you pass through this file_

---

## 1. Sensors & calibration (must-haves)

- [ ] **S01** — Accelerometer / IMU level calibration — _e.g. screen, route_
- [ ] **S02** — Magnetic compass (mag) calibration
- [ ] **S03** — Gyro / additional IMU cal (if your stack exposes it)
- [ ] **S04** — Compass / accel quality or interference shown in UI
- [ ] **S05** — Level / attitude sanity in pre-arm checklist

---

## 2. Radio / RC (must-haves)

- [ ] **R01** — RC / stick calibration wizard
- [ ] **R02** — Channel mapping (arm, mode, E-stop, etc.)
- [ ] **R03** — Stick / transmitter mode (e.g. mode 1–4)
- [ ] **R04** — Failsafe: loss of RC → RTL / land / hover (or FC-equivalent)
- [ ] **R05** — “Continue on link loss” (if offered; should be off by default + warnings)
- [ ] **R06** — Link quality / RC RSSI in HUD (or best proxy you have)

---

## 3. Power & battery (must-haves)

- [ ] **P01** — Low-voltage **alarm** (visual; optional sound)
- [ ] **P02** — Low / critical **battery protection** + action (RTL / land / hover)
- [ ] **P03** — Cell / pack model (cell count, pack V, or smart battery)
- [ ] **P04** — Voltage display calibration (measured vs reported)
- [ ] **P05** — Discharge or current-related protections (as FC provides)

---

## 4. Navigation, arming & safety (must-haves for GPS / mission use)

- [ ] **N01** — Pre-arm / pre-flight check list (sensors, RC, battery, EKF/GPS)
- [ ] **N02** — GPS or position **fix + quality** indication
- [ ] **N03** — Home / RTL height & speed; status of home position
- [ ] **N04** — Geofence and/or max altitude / distance limits
- [ ] **N05** — Disarm, motor interlock, **emergency stop**
- [ ] **N06** — Current flight **mode** display + command feedback

---

## 5. Agri & payload (product-specific; add rows as needed)

- [ ] **A01** — Spray / pump or payload parameters
- [ ] **A02** — Flowmeter calibration
- [ ] **A03** — Obstacle / radar related speed or attitude limits
- [ ] **A04** — Mission or spray behavior on signal loss (field-appropriate)

---

## 6. Ops & data (recommended)

- [ ] **O01** — Log download / list / viewer path
- [ ] **O02** — Parameters or tuning review (read/modify as allowed)
- [ ] **O03** — KML / export or replay in app scope

---

## 7. Map & mission (core “Mission Planner”)

- [ ] **M01** — Map with vehicle (live or mock)
- [ ] **M02** — Waypoint mission create / edit / send to vehicle
- [ ] **M03** — In-mission progress (e.g. active WP, distance to home)

---

## Conventions

| Tag | Meaning when checked |
|-----|------------------------|
| Wireframe | UI/flow only, no real vehicle I/O |
| Partial | Some params or one link real |
| Done | Meets your acceptance test for that ID |

**Tip:** in commits, use `S02: add mag cal placeholder` to grep history by ID.
