# GCS Mission Planner - User Manual

## 1. Purpose
This manual explains how to use the current Flutter Ground Control Station (GCS) Mission Planner UI:
- what each area does
- where controls are located
- how to access each feature
- what is demo/simulated vs real drone-connected behavior

---

## 2. Main Screen Layout (Where Everything Is)

When you open the GCS shell, the screen is split into functional zones:

1. **Top Bar** (full width, top)
   - Link, latency, GPS, battery, mode/system state
   - Quick actions (Tools, telemetry toggle, close overlay page)

2. **Left Sidebar** (always collapsed)
   - Vertical icon navigation:
     - Map
     - Mission
     - Logs
     - Settings
     - Tools

3. **Center Map Area** (primary workspace)
   - Map tiles, vehicle marker, waypoints, overlays
   - Floating map action buttons (waypoint + more actions)
   - Zoom rail (right side of map)

4. **Right Telemetry Panel** (collapsible)
   - Card-based telemetry details (altitude, speed, battery, GPS, health, heading)

5. **Bottom Dock** (mission controls + logs)
   - Compact/expanded states
   - Mission control buttons, logs list, graph placeholder

---

## 3. Top Bar Guide

### 3.1 What you see
- **LINK**: connection state + signal percentage (simulated)
- **LAT**: estimated latency and link type (simulated)
- **GPS**: summary label
- **PWR**: battery summary label
- **MODE/System**: flight mode and system state pill

### 3.2 Buttons on the right
- **Tools icon**: opens tools sheet
- **Telemetry panel icon**: opens/closes right telemetry panel
- **Close icon**: closes current non-map page and returns to map

### 3.3 Typical use
1. Watch status indicators for quick health checks
2. Open tools from top bar for secondary workflows
3. Toggle telemetry panel if you need more or less map space

---

## 4. Left Sidebar (Always Collapsed)

### 4.1 Current behavior
- Sidebar is intentionally fixed in **collapsed mode**
- No expand/collapse arrow is shown

### 4.2 Icon navigation order
From top to bottom:
1. Map
2. Mission
3. Logs
4. Settings
5. Tools

### 4.3 What each icon does
- **Map**: shows the main GCS map workspace
- **Mission**: opens mission page overlay
- **Logs**: opens logs page overlay
- **Settings**: opens settings page overlay
- **Tools**: opens tools sheet

---

## 5. Map Area Guide

## 5.1 Core interactions
- Pan/zoom map with mouse/touch gestures
- Long-press map to add waypoint (demo behavior)
- Use map action buttons for quick mission operations

## 5.2 Floating map buttons
- **Add waypoint button**: prompts waypoint add flow hint
- **More actions button**: opens map actions sheet

## 5.3 Zoom rail
- Located on right side of map
- Includes zoom in/out and recenter support

## 5.4 Optional map overlays (toggle from Map Layers)
- Airspace/NFZ overlay
- Mission geometry (route and waypoints)
- Vehicle marker visibility
- Flight trail
- Map HUD
- Manual control panel

---

## 6. Map Actions Sheet (More Actions)

Open using the three-dot floating button.

Available actions:
- Add waypoint
- Map layers
- Arm/Disarm (demo UI state)
- Flight mode change dialog (AUTO/LOITER/RTH/LAND/MANUAL)
- New mission wizard (route target)
- Survey grid (placeholder)
- Import mission (placeholder)

Notes:
- Arm/disarm and mode changes update UI simulation state.
- They are not currently sent to a real flight controller.

---

## 7. Right Telemetry Panel

### 7.1 Access
- Toggle from top bar telemetry icon
- Panel opens on the right side; handle remains available

### 7.2 What it contains
- Altitude MSL
- Speed
- Climb rate
- Battery %
- Voltage, current, estimated time remaining
- GNSS sats + HDOP
- GPS fix/accuracy labels
- EKF/IMU/Compass health labels
- Heading

### 7.3 Reading telemetry
- Values update continuously from simulator state
- Use this panel for detailed status while keeping map visible

---

## 8. Bottom Dock (Mission Controls + Logs)

### 8.1 States
- **Compact**: quick controls row
- **Expanded**: controls + logs + graph placeholder

### 8.2 Main controls
- Start Mission
- Load
- Save
- Pause (placeholder)
- RTH (mode switch placeholder)
- Waypoints
- Summary
- Track (camera follow toggle)
- KILL / EMERGENCY STOP (UI flow)

### 8.3 Logs and graph area
- Logs list is scrollable in expanded mode
- Graph area is a UI placeholder for live altitude graph

---

## 9. Mission and Pre-Arm Flow

### 9.1 Waypoint flow (demo)
1. Long-press map to add waypoint
2. Open Waypoints panel from dock or actions
3. Review mission summary

### 9.2 Start gating
Mission start can be blocked by simulated checks:
- pre-arm checklist status
- airspace violation/demo NFZ conditions

### 9.3 Pre-arm checklist sheet
Checklist includes:
- GPS lock
- Battery OK
- Sensors calibrated (UI proxy)
- EKF healthy (UI proxy)
- RC signal OK (UI proxy)

---

## 10. Alerts, HUD, and Flight Feedback

### 10.1 Alerts
- Alert banner surfaces critical states from shared status model
- Examples: low battery, GPS lost, link degraded/lost, EKF/compass issues

### 10.2 Map HUD overlay
- Compass + heading
- Home direction indication
- Speed / altitude / home-distance chips (space-adaptive)

### 10.3 RTH and mission progress widgets
- RTH feedback: phase and distance remaining
- Mission progress: current waypoint and completion percent

---

## 11. Tools Sheet and Secondary Pages

Open via:
- top bar Tools icon
- sidebar Tools icon

Available entries:
- Telemetry
- Camera
- Manual control
- Airspace
- Replay
- Plugins
- Vehicles
- Vehicle setup

These pages are available as routes; some are currently UI scaffolds/placeholders.

---

## 12. What Is Simulated vs Real

### 12.1 Simulated/UI-only at present
- Vehicle movement and telemetry values
- Link quality/latency labels
- Arm/disarm and flight mode switching
- Most mission command actions
- Sensor/health checks in pre-arm panel

### 12.2 Not yet integrated
- MAVLink transport and real FC communication
- Mission upload/download protocol to vehicle
- Real calibration and parameter workflows
- Real failsafe command/ack pipelines

---

## 13. Quick Access Cheat Sheet

- **Open tools**: Top bar tools icon or sidebar Tools icon
- **Toggle telemetry panel**: Top bar telemetry icon
- **Return to map from overlays**: Top bar close icon
- **Add waypoint**: Floating add-waypoint button or long-press map
- **Map layers**: Floating more-actions button -> Map layers
- **Mission summary**: Bottom dock -> Summary
- **Manual control panel**: Map layers -> Manual control panel
- **Toggle tracking**: Bottom dock -> Track

---

## 14. Troubleshooting

### 14.1 If map controls feel crowded
- Close telemetry panel from top bar
- Collapse bottom dock (if expanded)
- Disable optional overlays in Map layers

### 14.2 If values look unrealistic
- Current values are simulation-driven
- Real-world accuracy depends on future MAVLink backend integration

### 14.3 If a page is mostly placeholder
- Route exists, but feature may be scaffold-only in current build

---

## 15. Version Note

This manual matches the current workspace state where:
- left sidebar is permanently collapsed
- sidebar collapse arrow is removed
- map-first GCS shell is active with simulated telemetry/features

