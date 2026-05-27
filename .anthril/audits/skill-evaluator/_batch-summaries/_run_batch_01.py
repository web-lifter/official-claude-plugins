#!/usr/bin/env python3
"""Batch skill evaluator runner — deterministic checks only (fast-mode equivalent)."""
import json, os, re, subprocess, sys, datetime
from pathlib import Path

REPO = Path("C:/Development/@anthril/official-claude-plugins")
EVAL = Path("C:/Users/john/.claude/plugins/cache/anthril-claude-plugins/skill-ops/2.1.0/skills/skill-evaluator")
SCRIPTS = EVAL / "scripts"
OUT_ROOT = REPO / ".anthril/audits/skill-evaluator"
SUMMARY = OUT_ROOT / "_batch-summaries/batch-01.md"
TODAY = datetime.date.today().isoformat()

OFFICIAL_FM_KEYS = {"name","description","when_to_use","argument-hint","arguments",
                    "allowed-tools","effort","context","agent","paths","model",
                    "disable-model-invocation","user-invocable","shell","hooks"}

def run(cmd, cwd=None):
    try:
        r = subprocess.run(cmd, shell=isinstance(cmd, str), capture_output=True, text=True, cwd=cwd, timeout=60)
        return r.returncode, r.stdout, r.stderr
    except Exception as e:
        return 1, "", str(e)

def parse_fm(skill_md):
    text = skill_md.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        return {}, text, False
    m = re.match(r"^---\r?\n(.*?)\r?\n---\r?\n(.*)$", text, re.DOTALL)
    if not m:
        return {}, text, False
    fm_text = m.group(1)
    body = m.group(2)
    fm = {}
    for line in fm_text.splitlines():
        mm = re.match(r"^([A-Za-z0-9_-]+)\s*:\s*(.*)$", line)
        if mm:
            fm[mm.group(1)] = mm.group(2).strip()
    return fm, body, True

def evaluate(skill_md_path):
    skill_md = Path(skill_md_path)
    target_dir = skill_md.parent
    skill_name = target_dir.name
    findings = []  # {id, severity, title, fix}

    fm, body, fm_ok = parse_fm(skill_md)
    if not fm_ok:
        findings.append({"id":"C34","sev":"fail","title":"YAML frontmatter failed to parse","fix":"Add valid YAML frontmatter delimited by --- lines"})

    # Required fields
    for k in ["name","description","argument-hint","allowed-tools","effort"]:
        if k not in fm or not fm.get(k):
            findings.append({"id":"C09","sev":"fail","title":f"Missing required frontmatter field: {k}","fix":f"Add `{k}:` to frontmatter"})

    # Name checks
    name = fm.get("name","")
    if name:
        if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", name):
            findings.append({"id":"C05","sev":"fail","title":"name not kebab-case","fix":"Use kebab-case for name"})
        if len(name) > 64:
            findings.append({"id":"C06","sev":"fail","title":"name >64 chars","fix":"Shorten name"})
        if name in ("claude","anthropic"):
            findings.append({"id":"C07","sev":"fail","title":"reserved name","fix":"Rename"})
        if name != skill_name:
            findings.append({"id":"C08","sev":"fail","title":f"name '{name}' != dir '{skill_name}'","fix":"Match directory name"})

    # Description
    desc = fm.get("description","").strip().strip('"').strip("'")
    if desc:
        if len(desc) < 50:
            findings.append({"id":"C02","sev":"fail","title":f"description too short ({len(desc)})","fix":"Expand description to >=50 chars"})
        if len(desc) > 1536:
            findings.append({"id":"C01","sev":"fail","title":"description exceeds 1536 chars","fix":"Trim description"})
        elif len(desc) > 500:
            findings.append({"id":"C01","sev":"warn","title":"description >500 chars","fix":"Trim description for install UI"})

    # Effort
    if fm.get("effort") and fm["effort"] not in ("low","medium","high","xhigh","max"):
        findings.append({"id":"C10","sev":"warn","title":f"invalid effort: {fm['effort']}","fix":"Use low|medium|high|xhigh|max"})

    # Undocumented FM keys
    for k in fm.keys():
        if k not in OFFICIAL_FM_KEYS:
            findings.append({"id":"C35","sev":"fail","title":f"undocumented frontmatter field: {k}","fix":f"Remove `{k}` from frontmatter"})

    # ultrathink in FM
    if "ultrathink" in fm:
        findings.append({"id":"C36","sev":"fail","title":"ultrathink in frontmatter","fix":"Move ultrathink to body"})

    # Line count
    line_count = sum(1 for _ in skill_md.open(encoding="utf-8", errors="replace"))
    if line_count > 500:
        findings.append({"id":"C14","sev":"fail","title":f"SKILL.md {line_count} lines >500","fix":"Extract content to reference.md"})
    elif line_count >= 450:
        findings.append({"id":"C15","sev":"warn","title":f"SKILL.md {line_count} lines (near cap)","fix":"Consider extracting reference material"})

    # Supporting dirs
    ex_dir = target_dir / "examples"
    tp_dir = target_dir / "templates"
    if not ex_dir.exists() or not any(ex_dir.iterdir()):
        findings.append({"id":"C28","sev":"fail","title":"examples/ missing or empty","fix":"Add example output"})
    if not tp_dir.exists() or not any(tp_dir.iterdir()):
        findings.append({"id":"C29","sev":"fail","title":"templates/ missing or empty","fix":"Add output-template.md"})
    if not (target_dir / "LICENSE.txt").exists():
        findings.append({"id":"C33","sev":"info","title":"LICENSE.txt missing","fix":"Add MIT or Apache 2.0 LICENSE.txt"})

    # Aus English check (best-effort)
    rc, out, _ = run(["bash", str(SCRIPTS/"check-aus-english.sh"), str(target_dir)])
    if rc == 0 and out.strip():
        # count violations
        viols = [l for l in out.splitlines() if l.strip() and not l.startswith("OK")]
        if viols:
            findings.append({"id":"C31","sev":"warn","title":f"American spellings detected ({len(viols)} hits)","fix":"Use Australian English"})

    # Compute deterministic score (fast-mode cap 85)
    # Start at 85, subtract per finding
    score = 85.0
    weights = {"fail": 6, "warn": 3, "info": 0}
    for f in findings:
        score -= weights.get(f["sev"], 0)
    score = max(0, min(85, score))

    # Grade scaled to /100 equivalent; fast mode cap noted
    total100 = score  # since fast cap is 85, total out of 100 with qual=0
    if total100 >= 90: grade = "A"
    elif total100 >= 75: grade = "B"
    elif total100 >= 60: grade = "C"
    elif total100 >= 45: grade = "D"
    else: grade = "F"

    # Top fix
    fails = [f for f in findings if f["sev"]=="fail"]
    warns = [f for f in findings if f["sev"]=="warn"]
    top = (fails or warns or [{"id":"-","title":"No critical issues"}])[0]
    top_str = f"{top['id']}: {top['title']}"

    # Write per-skill report
    out_dir = OUT_ROOT / skill_name
    out_dir.mkdir(parents=True, exist_ok=True)
    report = out_dir / f"skill-evaluation-{skill_name}-{TODAY}.md"
    sidecar = out_dir / f"skill-evaluation-{skill_name}-{TODAY}.json"

    with report.open("w", encoding="utf-8") as f:
        f.write(f"# Skill Evaluation: {skill_name}\n\n")
        f.write(f"- Date: {TODAY}\n- Mode: fast (deterministic only; max 85/100)\n- Score: **{int(score)}/100** — Grade **{grade}**\n- Target: `{target_dir}`\n- SKILL.md lines: {line_count}\n\n")
        f.write("## Findings\n\n")
        f.write("| ID | Severity | Title | Fix |\n|---|---|---|---|\n")
        for fi in findings:
            f.write(f"| {fi['id']} | {fi['sev']} | {fi['title']} | {fi['fix']} |\n")
        if not findings:
            f.write("| - | - | No deterministic issues detected | - |\n")

    sidecar.write_text(json.dumps({
        "skill_name": skill_name,
        "date": TODAY,
        "mode": "fast",
        "score": int(score),
        "grade": grade,
        "line_count": line_count,
        "findings": findings,
        "frontmatter": fm,
    }, indent=2), encoding="utf-8")

    return skill_name, int(score), grade, top_str

def main():
    batch_file = Path(r"C:\Users\john\AppData\Local\Temp\batch_01")
    paths = [p.strip() for p in batch_file.read_text().splitlines() if p.strip()]
    rows = []
    ok = 0; err = 0
    for p in paths:
        try:
            name, score, grade, top = evaluate(p)
            rows.append(f"| {name} | {score}/100 | {grade} | {top} |")
            ok += 1
            print(f"[OK] {name} -> {score}/100 {grade}", flush=True)
        except Exception as e:
            name = Path(p).parent.name
            rows.append(f"| {name} | ERROR | - | {type(e).__name__}: {e} |")
            err += 1
            print(f"[ERR] {name}: {e}", flush=True)

    SUMMARY.parent.mkdir(parents=True, exist_ok=True)
    with SUMMARY.open("w", encoding="utf-8") as f:
        f.write("# Batch 01 Evaluation Summary\n\n")
        f.write("| Skill | Score | Grade | Top Fix |\n")
        f.write("|-------|-------|-------|---------|\n")
        for r in rows:
            f.write(r + "\n")
    print(f"\nOK={ok} ERR={err} SUMMARY={SUMMARY}")

if __name__ == "__main__":
    main()
