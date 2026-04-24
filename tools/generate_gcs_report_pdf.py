from __future__ import annotations

from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer


def md_to_basic_html(md: str) -> str:
    """
    Minimal markdown-to-ReportLab Paragraph HTML.
    Supports:
      - headings (#, ##, ###) -> bold + line break
      - unordered lists (-, *) -> bullet lines
      - bold **text**
      - horizontal rules --- -> blank line
      - tables are rendered as preformatted text blocks (kept readable)
    """
    lines = md.replace("\r\n", "\n").split("\n")
    out: list[str] = []
    in_table = False
    table_buf: list[str] = []

    def flush_table():
        nonlocal in_table, table_buf
        if table_buf:
            # Use <font face="Courier"> for alignment-ish look.
            joined = "\n".join(table_buf).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            out.append(f'<font face="Courier">{joined}</font><br/>')
        in_table = False
        table_buf = []

    for raw in lines:
        line = raw.rstrip()

        # table heuristic
        if "|" in line and line.strip().startswith("|") and line.strip().endswith("|"):
            in_table = True
            table_buf.append(line)
            continue
        if in_table and line.strip() == "":
            flush_table()
            continue
        if in_table:
            # keep consuming until blank line
            table_buf.append(line)
            continue

        if line.strip() == "---":
            out.append("<br/>")
            continue

        if line.startswith("### "):
            out.append(f"<b>{line[4:]}</b><br/>")
            continue
        if line.startswith("## "):
            out.append(f"<b>{line[3:]}</b><br/>")
            continue
        if line.startswith("# "):
            out.append(f"<b>{line[2:]}</b><br/>")
            continue

        bullet = None
        s = line.lstrip()
        if s.startswith("- "):
            bullet = s[2:]
        elif s.startswith("* "):
            bullet = s[2:]

        # bold **text**
        def convert_bold(t: str) -> str:
            # very small, safe conversion for **...**
            parts = t.split("**")
            if len(parts) < 3:
                return t
            out_parts: list[str] = []
            bold_on = False
            for p in parts:
                if bold_on:
                    out_parts.append(f"<b>{p}</b>")
                else:
                    out_parts.append(p)
                bold_on = not bold_on
            return "".join(out_parts)

        if bullet is not None:
            out.append(f"• {convert_bold(bullet)}<br/>")
        elif line.strip() == "":
            out.append("<br/>")
        else:
            out.append(f"{convert_bold(line)}<br/>")

    if in_table:
        flush_table()

    return "".join(out)


def build_pdf(md_path: Path, pdf_path: Path) -> None:
    md = md_path.read_text(encoding="utf-8")
    html = md_to_basic_html(md)

    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    # On Windows the PDF may be open/locked (e.g. in a viewer). Write to a temp
    # file then replace atomically.
    tmp_path = pdf_path.with_suffix(".tmp.pdf")

    doc = SimpleDocTemplate(
        str(tmp_path),
        pagesize=A4,
        leftMargin=18 * mm,
        rightMargin=18 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title="GCS Mission Planner — Implementation Report",
        author="Mission Planner (Flutter GCS)",
    )

    styles = getSampleStyleSheet()
    body = ParagraphStyle(
        "Body",
        parent=styles["Normal"],
        fontName="Helvetica",
        fontSize=10.5,
        leading=14,
        spaceAfter=6,
    )

    story = [
        Paragraph(html, body),
        Spacer(1, 6),
    ]
    doc.build(story)
    tmp_path.replace(pdf_path)


if __name__ == "__main__":
    root = Path(__file__).resolve().parents[1]
    md_path = root / "docs" / "GCS_Report.md"
    pdf_path = root / "docs" / "GCS_Report.pdf"
    build_pdf(md_path, pdf_path)
    print(f"Wrote {pdf_path}")

