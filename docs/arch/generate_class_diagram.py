"""Scan lib/ + test/ and write PlantUML class diagram to Fuselage_Class_Diagram_Complete.puml."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent / "Fuselage_Class_Diagram_Complete.puml"

DECL = re.compile(
    r"^(abstract\s+final\s+class|abstract\s+class|class|enum)\s+(\w+)",
    re.MULTILINE,
)


def scan_file(path: Path) -> list[tuple[str, str]]:
    text = path.read_text(encoding="utf-8")
    return [(m.group(1).strip(), m.group(2)) for m in DECL.finditer(text)]


def slug(s: str) -> str:
    return "".join(c if (c.isalnum() or c == "_") else "_" for c in s.replace("\\", "/"))


def main() -> int:
    chunks: list[tuple[str, list[tuple[str, str]]]] = []

    for f in sorted((ROOT / "lib").rglob("*.dart")):
        rel = f.relative_to(ROOT).as_posix()
        items = scan_file(f)
        if items:
            chunks.append((rel, items))

    for f in sorted((ROOT / "test").rglob("*.dart")):
        rel = f.relative_to(ROOT).as_posix()
        if "void main()" in f.read_text(encoding="utf-8"):
            chunks.append((rel, [("main_function", "main")]))

    chunks.append(
        (
            "lib/features/mission/presentation/widgets/mission_storage_dialogs.dart",
            [("fn", "showSaveMissionDialog"), ("fn", "showLoadMissionDialog")],
        )
    )
    chunks.append(("lib/features/map/presentation/logic/airspace_map.dart", [("fn", "isInDemoNfz")]))

    chunks.sort(key=lambda x: x[0])

    used: set[str] = set()
    alias_map: dict[tuple[str, str], str] = {}

    def alias_for(rel: str, name: str) -> str:
        cid = f"{slug(rel)}__{name}"
        while cid in used:
            cid += "_"
        used.add(cid)
        return cid

    lines: list[str] = [
        "@startuml Fuselage_Class_Diagram_Complete",
        "",
        "title Fuselage mission planner — exhaustive class diagram (generated from repo)",
        "",
        "top to bottom direction",
        "skinparam classAttributeIconSize 0",
        "skinparam packageStyle rectangle",
        "",
        "legend right",
        "  Auto-generated from lib/ and test/.",
        "  Stereotype af / fn / testEntry label Dart abstract-final, top-level func, test main.",
        "endlegend",
        "",
    ]

    for rel, decls in chunks:
        lines.append(f'package "{rel}" {{')
        for kind, name in decls:
            aid = alias_for(rel, name)
            alias_map[(rel, name)] = aid

            if kind == "main_function":
                lines.append(f'  class "void main()" <<testEntry>> as {aid}')
            elif kind == "fn":
                lines.append(f'  class "{name}(...)" <<fn>> as {aid}')
            elif kind == "enum":
                lines.append(f"  enum {aid} {{")
                lines.append("    VALUE")
                lines.append("  }")
                lines.append(f"  note bottom of {aid}")
                lines.append(f"    Dart enum: {name}")
                lines.append("  end note")
            elif "final" in kind:
                lines.append(f'  abstract class "{name}" <<af>> as {aid}')
            elif kind == "abstract class":
                lines.append(f'  abstract class "{name}" as {aid}')
            else:
                lines.append(f'  class "{name}" as {aid}')
        lines.append("}")
        lines.append("")

    def lookup_path(suffix: str, simple: str) -> str | None:
        for (r, n), aid in alias_map.items():
            if n == simple and r.endswith(suffix):
                return aid
        for (_r, n), aid in alias_map.items():
            if n == simple:
                return aid
        return None

    dm = lookup_path("dummy_mission_repository.dart", "DummyMissionRepository")
    mr = lookup_path("mission_repository.dart", "MissionRepository")
    dt = lookup_path("dummy_tasks_repository.dart", "DummyTasksRepository")
    tr = lookup_path("tasks_repository.dart", "TasksRepository")
    mp = lookup_path("lib/core/app/app.dart", "MissionPlannerApp")
    mps = lookup_path("lib/core/app/app.dart", "_MissionPlannerAppState")

    if dm and mr:
        lines.append(f"{dm} ..|> {mr}")
    if dt and tr:
        lines.append(f"{dt} ..|> {tr}")
    if mp and mps:
        lines.append(f"{mp} +-- {mps}")

    lines.append("")
    lines.append('package "backend/src (JavaScript)" {')
    lines.append('  class "Express app (server.js)" as NODE_server')
    lines.append('  class "auth router export (auth.js)" as NODE_auth')
    lines.append('  class "pg pool & query() (db.js)" as NODE_db')
    lines.append(
        '  class "ensureUserRegistrationSchema | ensureMissionsTable (migrate.js)" as NODE_migrate'
    )
    lines.append("}")
    lines.append("NODE_server --> NODE_auth")
    lines.append("NODE_server ..> NODE_migrate")
    lines.append("NODE_auth ..> NODE_db")
    lines.append("NODE_migrate ..> NODE_db")

    lines.extend(
        [
            "",
            "note bottom",
            "  Import / use dependencies not drawn.",
            "  backend/src shown as coarse Node artefacts (not Dart classes).",
            "  Regenerate: python docs/arch/generate_class_diagram.py",
            "end note",
            "",
            "@enduml",
            "",
        ]
    )

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {OUT}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
