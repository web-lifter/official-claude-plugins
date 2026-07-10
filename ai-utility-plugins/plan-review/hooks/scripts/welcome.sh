#!/usr/bin/env bash
# Web Lifter — Utilities Plugin Welcome Hook (SessionStart)

read -r -d '' MESSAGE <<'EOF'
Web Lifter — Utilities plugin loaded.

Skills:
  - /plan-completion-audit   Audit a plan file vs implementation.
  - /audit-resolver          Close the audit -> fix loop on a prior report.

Commands:
  - /plan-review:audit-resolve  Chain plan-completion-audit -> audit-resolver.
EOF

# Emit a SessionStart system message JSON event.
ESCAPED=$(printf '%s' "$MESSAGE" | python -c 'import json,sys;print(json.dumps(sys.stdin.read()))')
printf '{"systemMessage": %s}\n' "$ESCAPED"
