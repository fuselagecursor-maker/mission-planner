"""
Build PDF: uploaded UML images + full use-case catalog + system architecture (SVG).
Output: Fuselage_System_Architecture_and_Use_Cases.html|pdf in this folder.
Requires: Microsoft Edge (headless print). Python 3.9+.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
HTML_OUT = HERE / "Fuselage_System_Architecture_and_Use_Cases.html"
PDF_OUT = HERE / "Fuselage_System_Architecture_and_Use_Cases.pdf"

# Uploaded figures (long filenames stable in repo). Order: use case, then sequence diagrams.
FIGURES: list[tuple[str, str]] = [
    (
        "Figure 1 — Use case diagram (Fuselage mission planner system, repository scope)",
        "dLZDRXit4BxlKn0-j39QMVSqCEBQiMCWJbGhJYy536ftjCkOIsv9hXpr1-X3z0dx91qEToMHeeoY9sjdvXiEXyEPZtvZ7JUkRoMxxYr8NiFZdR1MQFKubrmfC8yF5XulkGLREE4aCFnc9NwpjO1dzizVVs-Xh0rGrWKecnZej1LEcmspfUw0QIKtfuLz4ghZXhUiu-KJ8XTkWvuDb8whMiAUG.png",
    ),
    (
        "Figure 2 — Sequence diagram: splash → pilot sign-in (Flutter + API)",
        "dLLBRjj84Dtp50Ml98naUpwh01x4SUma0yDHGcadG6YHDM9dcjsDxg9b8mWmgpb03Z47oqdcTLEsgB6105c9LBtwlLTLV1b51UbQGrTTPACsl2gzKR5PdTjwDTF6oUhQRRGjH8jXwetqxP-lv9EHejxOgROqkZAT20VwYSvdxsZRi2L431aGITjneJfnjclN70fLYGjqj03WY5IaHU5HXgwqL.png",
    ),
    (
        "Figure 3 — Sequence diagram: admin list / approve / reject pending pilots",
        "pLRHJjim57tFLrpnr6gqgIQUAdMYNJDWOgnhYlQmJfL9BiMGs9djqh49YQTzmBHluCFuabtRQPi2gn3IjBrKINpEyRtddZZTrOOfCyipU3FJcB4fJhffpiLaY5EkZMA6In4ORZA46B_CK2G8Et1tymiShWqPmI04LXHANY9TAJp7n4218kLY2WNFfD41cnafPla9ge0bHYhOSdo_XrHRm3HqW.png",
    ),
]


def _svg_context() -> str:
    return r"""
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340" role="img" aria-label="System context">
  <defs><style>.b{fill:#f7f9fc;stroke:#334155;stroke-width:1.5}.t{font:13px Segoe UI,sans-serif;fill:#0f172a}.e{font:11px Segoe UI,sans-serif;fill:#475569}</style></defs>
  <text x="380" y="22" text-anchor="middle" class="t" font-weight="700">System context (C4-style)</text>
  <rect class="b" x="40" y="50" width="120" height="52" rx="6"/><text x="100" y="82" text-anchor="middle" class="t">Guest</text>
  <rect class="b" x="190" y="50" width="120" height="52" rx="6"/><text x="250" y="82" text-anchor="middle" class="t">Pilot</text>
  <rect class="b" x="340" y="50" width="130" height="52" rx="6"/><text x="405" y="82" text-anchor="middle" class="t">Administrator</text>
  <rect class="b" x="500" y="50" width="130" height="52" rx="6"/><text x="565" y="82" text-anchor="middle" class="t">System operator</text>
  <rect class="b" x="200" y="140" width="360" height="72" rx="8" fill="#eff6ff"/>
  <text x="380" y="168" text-anchor="middle" class="t" font-weight="700">Fuselage — Flutter application</text>
  <text x="380" y="190" text-anchor="middle" class="e">lib/ · MaterialApp · GcsShell · feature screens · AuthApi (http)</text>
  <rect class="b" x="240" y="250" width="280" height="68" rx="8" fill="#fefce8"/>
  <text x="380" y="278" text-anchor="middle" class="t" font-weight="700">Mission Planner API — Node.js / Express</text>
  <text x="380" y="300" text-anchor="middle" class="e">backend/src/server.js · auth.js · JWT · bcrypt · /health</text>
  <rect class="b" x="310" y="232" width="140" height="40" rx="6" fill="#f0fdf4"/>
  <text x="380" y="256" text-anchor="middle" class="t" font-size="12">PostgreSQL</text>
  <path d="M100 102 L100 140 L380 140" fill="none" stroke="#64748b" marker-end="url(#arr)"/>
  <path d="M250 102 L250 130 L380 130" fill="none" stroke="#64748b"/>
  <path d="M405 102 L405 120 L380 120" fill="none" stroke="#64748b"/>
  <path d="M565 102 L565 110 L520 176" fill="none" stroke="#64748b"/>
  <path d="M380 212 L380 250" fill="none" stroke="#64748b"/>
  <defs><marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#64748b"/></marker></defs>
  <text x="380" y="330" text-anchor="middle" class="e">Operator → GET /health only. Map tiles: external OSM-style endpoints (flutter_map).</text>
</svg>
"""


def _svg_containers() -> str:
    return r"""
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 300" role="img" aria-label="Containers">
  <defs><style>.box{fill:#fff;stroke:#1e293b;stroke-width:1.5}.cap{font:13px Segoe UI,sans-serif;fill:#0f172a;font-weight:700}.sub{font:11px Segoe UI,sans-serif;fill:#475569}</style></defs>
  <text x="380" y="22" text-anchor="middle" class="cap">Container diagram</text>
  <rect class="box" x="40" y="48" width="200" height="200" rx="10"/>
  <text x="140" y="78" text-anchor="middle" class="cap">Flutter client</text>
  <text x="140" y="100" text-anchor="middle" class="sub">Dart 3.4+</text>
  <text x="50" y="130" class="sub">• presentation (screens)</text>
  <text x="50" y="152" class="sub">• core: routing, auth_session</text>
  <text x="50" y="174" class="sub">• features/*</text>
  <text x="50" y="196" class="sub">• http · flutter_map · geolocator</text>
  <text x="50" y="218" class="sub">• shared_preferences</text>
  <rect class="box" x="280" y="48" width="200" height="200" rx="10" fill="#fffbeb"/>
  <text x="380" y="78" text-anchor="middle" class="cap">API service</text>
  <text x="380" y="100" text-anchor="middle" class="sub">Express 5 · PORT 4000</text>
  <text x="290" y="130" class="sub">• /auth/*</text>
  <text x="290" y="152" class="sub">• /health</text>
  <text x="290" y="174" class="sub">• cors · dotenv</text>
  <text x="290" y="196" class="sub">• migrate on startup</text>
  <rect class="box" x="520" y="88" width="200" height="120" rx="10" fill="#f0fdf4"/>
  <text x="620" y="120" text-anchor="middle" class="cap">PostgreSQL</text>
  <text x="620" y="142" text-anchor="middle" class="sub">users · missions</text>
  <text x="620" y="164" text-anchor="middle" class="sub">indexes on missions</text>
  <path d="M240 148 L280 148" fill="none" stroke="#334155" stroke-width="2"/>
  <path d="M480 148 L520 148" fill="none" stroke="#334155" stroke-width="2"/>
  <text x="380" y="280" text-anchor="middle" class="sub">HTTPS-capable; dev default AUTH_API_URL → http://localhost:4000</text>
</svg>
"""


def _svg_layers() -> str:
    return r"""
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360" role="img" aria-label="Logical layers">
  <defs><style>.L{fill:#f8fafc;stroke:#475569;stroke-width:1.2}.t{font:12px Segoe UI,sans-serif;fill:#0f172a}</style></defs>
  <text x="380" y="22" text-anchor="middle" font-weight="700" class="t" font-size="14">Logical architecture — Flutter packages</text>
  <rect class="L" x="40" y="44" width="680" height="56" rx="6"/><text x="60" y="78" class="t">UI shell: GcsShell, MapScreen, gcs_top_bar / sidebar / telemetry widgets, MissionPlannerApp</text>
  <rect class="L" x="40" y="112" width="680" height="56" rx="6"/><text x="60" y="146" class="t">Routing &amp; session: AppRouter · AppRoutes · AuthSession · ThemeController · AppSettingsController</text>
  <rect class="L" x="40" y="180" width="680" height="72" rx="6"/><text x="60" y="206" class="t">Feature modules: auth, mission, map, dashboard, vehicle_setup, telemetry, replay, … (presentation + widgets)</text>
  <text x="60" y="228" class="t">Data: AuthApi (http); other features use placeholders / local state / simulated telemetry in-map</text>
  <rect class="L" x="40" y="264" width="680" height="72" rx="6"/><text x="60" y="290" class="t">Backend stack: server.js mounts express.json, CORS; db.js pool; auth.js router; migrate.js ensures users + missions schema</text>
  <text x="60" y="312" class="t">No REST endpoints for mission CRUD in this repo (missions table exists for future use).</text>
</svg>
"""


def _svg_deployment() -> str:
    return r"""
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260" role="img" aria-label="Deployment">
  <defs><style>.n{fill:#fff;stroke:#0f172a;stroke-width:1.5}.tx{font:12px Segoe UI,sans-serif;fill:#0f172a}</style></defs>
  <text x="380" y="22" text-anchor="middle" font-weight="700" font-size="14" class="tx">Typical deployment view (development / small team)</text>
  <rect class="n" x="60" y="50" width="200" height="100" rx="8"/><text x="160" y="82" text-anchor="middle" class="tx" font-weight="700">Device / emulator</text>
  <text x="160" y="108" text-anchor="middle" class="tx">Flutter build</text>
  <text x="160" y="132" text-anchor="middle" class="tx">Fuselage client</text>
  <rect class="n" x="300" y="50" width="200" height="100" rx="8" fill="#fffbeb"/>
  <text x="400" y="82" text-anchor="middle" class="tx" font-weight="700">Host</text>
  <text x="400" y="108" text-anchor="middle" class="tx">node server.js</text>
  <text x="400" y="132" text-anchor="middle" class="tx">:4000</text>
  <rect class="n" x="540" y="50" width="160" height="100" rx="8" fill="#f0fdf4"/>
  <text x="620" y="82" text-anchor="middle" class="tx" font-weight="700">PostgreSQL</text>
  <text x="620" y="108" text-anchor="middle" class="tx">mission_planner DB</text>
  <path d="M260 100 L300 100" fill="none" stroke="#334155" stroke-width="2"/>
  <path d="M500 100 L540 100" fill="none" stroke="#334155" stroke-width="2"/>
  <text x="380" y="200" text-anchor="middle" class="tx">Network: HTTP/JSON between client and API; TLS recommended in production (backend/README).</text>
  <text x="380" y="228" text-anchor="middle" class="tx">Map: HTTPS tile requests from device to public tile servers (flutter_map configuration in code).</text>
</svg>
"""


def _svg_data() -> str:
    return r"""
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 200" role="img" aria-label="Data model">
  <defs><style>.e{fill:#fff;stroke:#1e293b;stroke-width:1.5}.t{font:12px Segoe UI,sans-serif;fill:#0f172a}</style></defs>
  <text x="360" y="22" text-anchor="middle" font-weight="700" font-size="14" class="t">Persistent data (PostgreSQL)</text>
  <rect class="e" x="40" y="48" width="280" height="130" rx="8"/>
  <text x="180" y="76" text-anchor="middle" class="t" font-weight="700">users</text>
  <text x="55" y="100" class="t">id, name, email (unique), password_hash</text>
  <text x="55" y="120" class="t">pilot_id, role, registration_status</text>
  <text x="55" y="140" class="t">created_at</text>
  <text x="55" y="162" class="t">CHECKs on role / registration_status</text>
  <rect class="e" x="400" y="48" width="280" height="130" rx="8" fill="#f8fafc"/>
  <text x="540" y="76" text-anchor="middle" class="t" font-weight="700">missions</text>
  <text x="415" y="100" class="t">id, owner_user_id → users</text>
  <text x="415" y="120" class="t">name, description, start_at, end_at</text>
  <text x="415" y="140" class="t">priority, status, timestamps</text>
  <text x="415" y="162" class="t">indexes: owner_user_id, status</text>
  <path d="M320 110 L400 110" fill="none" stroke="#334155" stroke-width="2" marker-end="url(#m)"/>
  <defs><marker id="m" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#334155"/></marker></defs>
</svg>
"""


def _use_case_rows() -> str:
    """HTML table rows: all route-based and shell use cases from codebase."""
    rows: list[tuple[str, str, str, str]] = [
        ("UC-001", "View splash screen", "Guest", "`/splash` → SplashScreen"),
        ("UC-002", "Open pilot sign-in screen", "Guest", "`/auth` after splash; LoginScreen"),
        ("UC-003", "Open pilot registration screen", "Guest", "LoginScreen → `/register`"),
        ("UC-004", "Submit pilot registration", "Guest", "RegisterScreen → POST `/auth/register`"),
        ("UC-005", "Sign in pilot", "Guest → Pilot", "LoginScreen → POST `/auth/login` → AuthSession → `/`"),
        ("UC-006", "Use GCS map workspace", "Pilot, Admin", "GcsShell + MapScreen (map section)"),
        ("UC-007", "View GCS mission page", "Pilot, Admin", "GcsShell mission section → MissionPage"),
        ("UC-008", "Open mission load dialog", "Pilot, Admin", "MissionPage → showLoadMissionDialog"),
        ("UC-009", "Open mission save dialog", "Pilot, Admin", "MissionPage → showSaveMissionDialog"),
        ("UC-010", "Open mission wizard", "Pilot, Admin", "`/mission-wizard` (e.g. New mission, map FAB)"),
        ("UC-011", "View GCS logs page", "Pilot, Admin", "GcsShell logs → LogsPage"),
        ("UC-012", "View GCS settings page", "Pilot, Admin", "GcsShell settings → SettingsPage"),
        ("UC-013", "Open tools sheet (secondary routes)", "Pilot, Admin", "GcsShell tools modal → pushNamed routes below"),
        ("UC-014", "View admin registration requests", "Admin", "`/admin/registration-requests` (+ pending API)"),
        ("UC-015", "View mission details", "Pilot, Admin", "`/mission-details`"),
        ("UC-016", "View mission editor", "Pilot, Admin", "`/mission-editor`"),
        ("UC-017", "View telemetry dashboard", "Pilot, Admin", "`/telemetry`"),
        ("UC-018", "View camera / payload", "Pilot, Admin", "`/camera-payload`"),
        ("UC-019", "View manual control", "Pilot, Admin", "`/manual-control`"),
        ("UC-020", "View airspace", "Pilot, Admin", "`/airspace`"),
        ("UC-021", "View mission replay", "Pilot, Admin", "`/replay`"),
        ("UC-022", "View plugin manager", "Pilot, Admin", "`/plugins`"),
        ("UC-023", "View multi-vehicle", "Pilot, Admin", "`/vehicles`"),
        ("UC-024", "View vehicle setup hub", "Pilot, Admin", "`/vehicle-setup`"),
        ("UC-025", "View sensors calibration", "Pilot, Admin", "`/vehicle-setup-sensors`"),
        ("UC-026", "View radio / RC setup", "Pilot, Admin", "`/vehicle-setup-radio`"),
        ("UC-027", "View battery / power setup", "Pilot, Admin", "`/vehicle-setup-battery`"),
        ("UC-028", "View navigation, arming & safety", "Pilot, Admin", "`/vehicle-setup-nav-safety`"),
        ("UC-029", "View agri / payload setup", "Pilot, Admin", "`/vehicle-setup-agri`"),
        ("UC-030", "View ops / logging setup", "Pilot, Admin", "`/vehicle-setup-ops`"),
        ("UC-031", "View mission map core (setup)", "Pilot, Admin", "`/vehicle-setup-mission`"),
        ("UC-032", "View power management", "Pilot, Admin", "`/power`"),
        ("UC-033", "View FSM viewer", "Pilot, Admin", "`/fsm-viewer`"),
        ("UC-034", "View firmware flash", "Pilot, Admin", "`/firmware-flash`"),
        ("UC-035", "View flight mode reference", "Pilot, Admin", "`/flight-mode-reference`"),
        ("UC-036", "View alerts inbox", "Pilot, Admin", "`/alerts-inbox`"),
        ("UC-037", "View help / about", "Pilot, Admin", "`/help-about`"),
        ("UC-038", "Resolve unknown route", "Pilot, Admin", "Unregistered name → `_UnknownRouteScreen`"),
        ("UC-039", "List pending registrations (API)", "Admin", "GET `/auth/admin/pending-registrations`"),
        ("UC-040", "Approve pilot (API)", "Admin", "POST `…/pending-registrations/:id/approve`"),
        ("UC-041", "Reject pilot (API)", "Admin", "POST `…/pending-registrations/:id/reject`"),
        ("UC-042", "Check API and database health", "System operator", "GET `/health` (not called from `lib/`)"),
    ]
    tr = "".join(
        f"<tr><td>{a}</td><td>{b}</td><td>{c}</td><td>{d}</td></tr>" for a, b, c, d in rows
    )
    return tr


def _figure_html(caption: str, filename: str) -> str:
    path = HERE / filename
    if not path.is_file():
        return f'<p class="warn">Missing image file: {filename}</p>'
    return f"""
<figure class="fig">
  <img src="{filename}" alt="{caption}"/>
  <figcaption>{caption}</figcaption>
</figure>
"""


def build_html() -> str:
    figures = "\n".join(_figure_html(c, f) for c, f in FIGURES)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>Fuselage — System architecture &amp; use cases</title>
  <style>
    @page {{ size: A4; margin: 14mm; }}
    html {{ font-size: 10.5pt; }}
    body {{
      font-family: "Segoe UI", system-ui, sans-serif;
      line-height: 1.4;
      color: #0f172a;
      max-width: 210mm;
      margin: 0 auto;
      padding: 14px 18px 28px;
    }}
    h1 {{ font-size: 1.35rem; border-bottom: 2px solid #0f172a; padding-bottom: 6px; page-break-after: avoid; }}
    h2 {{ font-size: 1.1rem; margin-top: 1.5rem; page-break-after: avoid; border-bottom: 1px solid #cbd5e1; padding-bottom: 4px; }}
    h3 {{ font-size: 1rem; margin-top: 1rem; page-break-after: avoid; }}
    .meta {{ color: #475569; font-size: 0.92rem; margin-bottom: 1rem; }}
    .fig {{ margin: 1rem 0 1.5rem; page-break-inside: avoid; text-align: center; }}
    .fig img {{ max-width: 100%; height: auto; border: 1px solid #e2e8f0; border-radius: 6px; }}
    .fig figcaption {{ font-size: 0.88rem; color: #475569; margin-top: 8px; text-align: left; }}
    .svgbox {{ margin: 12px 0 20px; page-break-inside: avoid; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px; background: #fafafa; }}
    .svgbox svg {{ width: 100%; height: auto; display: block; }}
    table {{ border-collapse: collapse; width: 100%; font-size: 0.86rem; margin: 10px 0 20px; }}
    th, td {{ border: 1px solid #94a3b8; padding: 6px 8px; vertical-align: top; text-align: left; }}
    th {{ background: #e2e8f0; font-weight: 700; }}
    tr:nth-child(even) {{ background: #f8fafc; }}
    .warn {{ color: #b91c1c; font-weight: 600; }}
    ul.toc {{ line-height: 1.7; }}
    @media print {{
      body {{ padding: 0; }}
      a {{ color: #000; text-decoration: none; }}
    }}
  </style>
</head>
<body>

<h1>Fuselage Mission Planner</h1>
<p class="meta"><strong>Document:</strong> System architecture &amp; complete use-case catalog<br/>
<strong>Source:</strong> Repository <code>mission_planner_wireframe</code> + <code>backend/</code><br/>
<strong>UML figures:</strong> User-supplied PNGs in <code>docs/arch/</code> (use case + sequence diagrams)<br/>
<strong>Generated:</strong> see script <code>build_architecture_document.py</code></p>

<h2>Table of contents</h2>
<ul class="toc">
  <li><a href="#sec-uml">1. UML diagrams (uploaded)</a></li>
  <li><a href="#sec-arch">2. System architecture (diagrams)</a></li>
  <li><a href="#sec-uc">3. Complete use-case catalog</a></li>
  <li><a href="#sec-notes">4. Notes &amp; scope</a></li>
</ul>

<h2 id="sec-uml">1. UML diagrams (uploaded)</h2>
<p>These images are the authoritative UML exports you placed under <code>docs/arch/</code>. They are embedded below at print resolution.</p>
{figures}

<h2 id="sec-arch">2. System architecture</h2>
<p>The following diagrams summarize structure found in <code>lib/</code>, <code>backend/src/</code>, and <code>backend/sql/</code>. They complement the sequence diagrams in §1.</p>

<h3>2.1 System context</h3>
<div class="svgbox">{_svg_context()}</div>

<h3>2.2 Containers</h3>
<div class="svgbox">{_svg_containers()}</div>

<h3>2.3 Logical layers</h3>
<div class="svgbox">{_svg_layers()}</div>

<h3>2.4 Deployment (typical)</h3>
<div class="svgbox">{_svg_deployment()}</div>

<h3>2.5 Data persistence</h3>
<div class="svgbox">{_svg_data()}</div>

<h2 id="sec-uc">3. Complete use-case catalog</h2>
<p>Enumerates behaviors implemented in the Flutter router, GCS shell, dialogs, and Express auth/health API. <strong>Admin</strong> denotes users with <code>role == admin</code> in JWT payload. Alternate <code>AppShell</code> / drawer routes reuse many of the same named screens but are not the default post-login path (<code>MissionPlannerApp</code> uses <code>GcsShell</code> after sign-in).</p>
<table>
  <thead><tr><th>ID</th><th>Use case</th><th>Primary actor(s)</th><th>Stimulus / route / API</th></tr></thead>
  <tbody>
{_use_case_rows()}
  </tbody>
</table>

<h2 id="sec-notes">4. Notes &amp; scope</h2>
<ul>
  <li><strong>Missions table:</strong> PostgreSQL <code>missions</code> exists (see <code>init.sql</code> / <code>migrate.js</code>); no mission CRUD REST routes are implemented in this repository.</li>
  <li><strong>GCS data:</strong> Map and telemetry displays include simulated or placeholder logic unless otherwise wired.</li>
  <li><strong>Additional sequences</strong> (e.g. registration POST only) can be documented separately; Figures 2–3 cover splash/login and admin moderation.</li>
</ul>

</body>
</html>
"""


def print_pdf() -> None:
    edge_candidates = [
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
        Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
    ]
    edge = next((p for p in edge_candidates if p.is_file()), None)
    if edge is None:
        raise RuntimeError("Microsoft Edge not found; open the HTML and Print to PDF.")
    uri = HTML_OUT.as_uri()
    cmd = [str(edge), "--headless=new", "--disable-gpu", f"--print-to-pdf={PDF_OUT}", uri]
    subprocess.run(cmd, check=True, timeout=120)


def main() -> int:
    missing = [f for _, f in FIGURES if not (HERE / f).is_file()]
    if missing:
        print("Warning: missing figure files:", missing, file=sys.stderr)
    html = build_html()
    HTML_OUT.write_text(html, encoding="utf-8")
    print("Wrote", HTML_OUT)
    print_pdf()
    print("Wrote", PDF_OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
