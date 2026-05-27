#!/usr/bin/env bash
set -uo pipefail
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=C

REPO="C:/Development/@anthril/official-claude-plugins"
SCRIPTS="C:/Users/john/.claude/plugins/cache/anthril-claude-plugins/skill-ops/2.1.0/skills/skill-evaluator/scripts"
OUTROOT="$REPO/.anthril/audits/skill-evaluator"
SUMMARY="$OUTROOT/_batch-summaries/batch-08.md"
BATCH="$OUTROOT/_batch-summaries/batch-08.input"
DATE="$(date +%F)"

eval_one() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"
  local outdir="$OUTROOT/$skill_name"
  mkdir -p "$outdir"
  local report="$outdir/skill-evaluation-${skill_name}-${DATE}.md"
  local jsonf="$outdir/skill-evaluation-${skill_name}-${DATE}.json"
  local skill_md="$skill_dir/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    printf 'ERROR|-|%s|SKILL.md missing\n' "$skill_name"
    return
  fi

  local fm_json
  fm_json=$(bash "$SCRIPTS/parse-frontmatter.sh" "$skill_md" 2>/dev/null || echo '{}')

  local name desc arg_hint tools effort
  extract() { printf '%s' "$fm_json" | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1; }
  name=$(extract name)
  desc=$(extract description)
  arg_hint=$(extract 'argument-hint')
  tools=$(extract 'allowed-tools')
  effort=$(extract effort)

  local findings_str=""
  local score=100
  local top_fix=""
  add_f() { findings_str+="- $1"$'\n'; }

  [ -z "$name" ]     && { add_f "[fail] C09: missing 'name'"; score=$((score-6)); [ -z "$top_fix" ] && top_fix="C09 add name"; }
  [ -z "$desc" ]     && { add_f "[fail] C09: missing 'description'"; score=$((score-8)); [ -z "$top_fix" ] && top_fix="C09 add description"; }
  [ -z "$arg_hint" ] && { add_f "[fail] C09: missing 'argument-hint'"; score=$((score-4)); [ -z "$top_fix" ] && top_fix="C09 add argument-hint"; }
  [ -z "$effort" ]   && { add_f "[fail] C09: missing 'effort'"; score=$((score-3)); [ -z "$top_fix" ] && top_fix="C09 add effort"; }
  [ -z "$tools" ]    && { add_f "[warn] C09: missing 'allowed-tools'"; score=$((score-2)); }

  if [ -n "$name" ] && [ "$name" != "$skill_name" ]; then
    add_f "[fail] C08: name '$name' != dir '$skill_name'"
    score=$((score-4))
    [ -z "$top_fix" ] && top_fix="C08 align name with directory"
  fi
  if [ -n "$name" ] && ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    add_f "[fail] C05: name not kebab-case"; score=$((score-3))
  fi
  if [ -n "$name" ] && [ ${#name} -gt 64 ]; then
    add_f "[warn] C06: name >64 chars"; score=$((score-1))
  fi
  if [ -n "$desc" ]; then
    local dlen=${#desc}
    if [ "$dlen" -gt 1536 ]; then
      add_f "[fail] C01: description >1536 chars"; score=$((score-4))
      [ -z "$top_fix" ] && top_fix="C01 shorten description"
    elif [ "$dlen" -lt 50 ]; then
      add_f "[fail] C02: description <50 chars"; score=$((score-3))
      [ -z "$top_fix" ] && top_fix="C02 expand description"
    elif [ "$dlen" -gt 500 ]; then
      add_f "[warn] C01: description >500 chars"; score=$((score-1))
    fi
  fi
  if [ -n "$effort" ]; then
    case "$effort" in
      low|medium|high|xhigh|max) ;;
      *) add_f "[warn] C10: effort '$effort' invalid"; score=$((score-1));;
    esac
  fi

  local lines
  lines=$(wc -l < "$skill_md")
  if [ "$lines" -gt 500 ]; then
    add_f "[fail] C14: SKILL.md ${lines}L (>500)"; score=$((score-5))
    [ -z "$top_fix" ] && top_fix="C14 trim SKILL.md to <=500 lines"
  elif [ "$lines" -gt 450 ]; then
    add_f "[warn] C15: SKILL.md ${lines}L (>450)"; score=$((score-2))
  fi

  if [ ! -d "$skill_dir/examples" ] || [ -z "$(ls -A "$skill_dir/examples" 2>/dev/null)" ]; then
    add_f "[fail] C28: examples/ missing"; score=$((score-4))
    [ -z "$top_fix" ] && top_fix="C28 add example output"
  fi
  if [ ! -d "$skill_dir/templates" ] || [ -z "$(ls -A "$skill_dir/templates" 2>/dev/null)" ]; then
    add_f "[fail] C29: templates/ missing"; score=$((score-4))
    [ -z "$top_fix" ] && top_fix="C29 add output template"
  fi
  if [ ! -f "$skill_dir/LICENSE.txt" ]; then
    add_f "[info] C33: LICENSE.txt missing"; score=$((score-1))
  fi

  local aus
  aus=$(grep -cE '\b(optimize|optimization|color|behavior|organize|organization|analyze|customize)\b' "$skill_md" 2>/dev/null || echo 0)
  if [ "$aus" -gt 0 ]; then
    add_f "[warn] C31: ${aus} US spellings"; score=$((score-2))
  fi

  [ $score -lt 0 ] && score=0
  [ $score -gt 100 ] && score=100

  local grade
  if   [ $score -ge 90 ]; then grade=A
  elif [ $score -ge 75 ]; then grade=B
  elif [ $score -ge 60 ]; then grade=C
  elif [ $score -ge 45 ]; then grade=D
  else grade=F
  fi

  [ -z "$top_fix" ] && top_fix="No deterministic issues"

  {
    printf '# Skill Evaluation: %s\n\n' "$skill_name"
    printf -- '- **Date:** %s\n- **Mode:** fast (deterministic)\n- **Score:** %s/100\n- **Grade:** %s\n- **Target:** %s\n\n' "$DATE" "$score" "$grade" "$skill_dir"
    printf '## Findings\n\n'
    if [ -z "$findings_str" ]; then
      printf '_No deterministic findings._\n'
    else
      printf '%s' "$findings_str"
    fi
    printf '\n## Top Fix\n\n%s\n' "$top_fix"
  } > "$report"

  printf '{"skill":"%s","score":%s,"grade":"%s","mode":"fast","top_fix":"%s"}\n' "$skill_name" "$score" "$grade" "${top_fix//\"/\\\"}" > "$jsonf"

  printf '%s|%s|%s|%s\n' "$score" "$grade" "$skill_name" "$top_fix"
}

while IFS= read -r p; do
  [ -z "$p" ] && continue
  d=$(dirname "$p")
  r=$(eval_one "$d")
  IFS='|' read -r s g n t <<< "$r"
  printf '| %s | %s/100 | %s | %s |\n' "$n" "$s" "$g" "$t" >> "$SUMMARY"
  printf 'PROCESSED: %s -> %s/%s\n' "$n" "$s" "$g"
done < "$BATCH"
