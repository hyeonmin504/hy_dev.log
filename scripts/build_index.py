#!/usr/bin/env python3
"""log/ 와 notes/ 를 훑어 index.md 를 생성한다. 손으로 고치지 말 것."""
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ["log", "notes", "retro"]
DATE_RE = re.compile(r"(\d{4}-\d{2}-\d{2})")
RECENT = 30


def parse(path: Path):
    text = path.read_text(encoding="utf-8")
    title = next((l[2:].strip() for l in text.splitlines() if l.startswith("# ")), path.stem)
    m = re.search(r"^날짜:\s*(\d{4}-\d{2}-\d{2})", text, re.M) or DATE_RE.search(path.name)
    date = m.group(1) if m else ""
    tags = re.findall(r"#([a-z0-9][a-z0-9-]*)", "".join(re.findall(r"^태그:.*$", text, re.M)))
    rel = path.relative_to(ROOT)
    kind = rel.parts[0] if rel.parts[0] != "notes" else f"notes/{rel.parts[1]}"
    return {"path": rel.as_posix(), "title": title, "date": date, "tags": tags, "kind": kind}


def main():
    entries = [parse(p) for s in SOURCES for p in (ROOT / s).rglob("*.md")]
    entries.sort(key=lambda e: (e["date"], e["path"]), reverse=True)

    by_tag = defaultdict(list)
    for e in entries:
        for t in e["tags"]:
            by_tag[t].append(e)

    out = ["# 색인", "", f"총 {len(entries)}편 · 태그 {len(by_tag)}개 · `scripts/build_index.py` 생성", ""]
    out += ["## 최근", ""]
    out += [f"- {e['date']} [{e['title']}]({e['path']}) `{e['kind']}`" for e in entries[:RECENT]]
    out += ["", "## 태그별", ""]
    for tag in sorted(by_tag, key=lambda t: (-len(by_tag[t]), t)):
        out.append(f"### #{tag} ({len(by_tag[tag])})")
        out += [f"- {e['date']} [{e['title']}]({e['path']})" for e in by_tag[tag]]
        out.append("")

    (ROOT / "index.md").write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
    print(f"index.md: {len(entries)} entries, {len(by_tag)} tags")


if __name__ == "__main__":
    main()
