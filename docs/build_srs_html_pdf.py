"""Build print HTML + PDF for SRS using Python markdown and Edge headless."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parent
MD = ROOT / "SRS_Fuselage_Mission_Planner.md"
HTML_OUT = ROOT / "SRS_Fuselage_Mission_Planner.html"
PDF_OUT = ROOT / "SRS_Fuselage_Mission_Planner.pdf"


def main() -> int:
    text = MD.read_text(encoding="utf-8")
    body = markdown.markdown(
        text,
        extensions=["tables", "fenced_code", "nl2br"],
        output_format="html5",
    )
    doc = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SRS — Fuselage Mission Planner</title>
  <style>
    @page {{ size: A4; margin: 18mm; }}
    html {{ font-size: 11pt; }}
    body {{
      font-family: "Segoe UI", system-ui, sans-serif;
      line-height: 1.45;
      color: #111;
      max-width: 210mm;
      margin: 0 auto;
      padding: 12px 16px 24px;
    }}
    h1 {{ font-size: 1.35rem; border-bottom: 2px solid #333; padding-bottom: 6px; }}
    h2 {{ font-size: 1.15rem; margin-top: 1.4em; page-break-after: avoid; }}
    h3 {{ font-size: 1.05rem; margin-top: 1.1em; page-break-after: avoid; }}
    table {{ border-collapse: collapse; width: 100%; margin: 0.6em 0 1em; font-size: 0.92rem; page-break-inside: avoid; }}
    th, td {{ border: 1px solid #999; padding: 6px 8px; vertical-align: top; text-align: left; }}
    th {{ background: #f0f0f0; }}
    hr {{ border: none; border-top: 1px solid #ccc; margin: 1.2em 0; }}
    code {{ font-family: Consolas, "Courier New", monospace; font-size: 0.9em; background: #f5f5f5; padding: 0 4px; }}
    @media print {{
      body {{ padding: 0; }}
      a {{ color: #000; text-decoration: none; }}
    }}
  </style>
</head>
<body>
<article>
{body}
</article>
</body>
</html>
"""
    HTML_OUT.write_text(doc, encoding="utf-8")
    print(f"Wrote {HTML_OUT}")

    candidates = [
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
        Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
    ]
    edge = next((p for p in candidates if p.is_file()), None)
    if edge is None:
        print("Microsoft Edge not found; open the HTML in a browser and Print to PDF.", file=sys.stderr)
        return 0

    uri = HTML_OUT.as_uri()
    cmd = [
        str(edge),
        "--headless=new",
        "--disable-gpu",
        f"--print-to-pdf={PDF_OUT}",
        uri,
    ]
    subprocess.run(cmd, check=True, timeout=120)
    print(f"Wrote {PDF_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
