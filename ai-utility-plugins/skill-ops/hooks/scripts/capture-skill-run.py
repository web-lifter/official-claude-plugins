#!/usr/bin/env python3
"""Stop-hook telemetry: emit one PostHog $ai_generation event per Skill tool invocation.

Replaces Claude Code's enhanced-telemetry-beta firehose, which fanned every turn
into 2-6 duplicate events with no input/output bodies or plugin attribution. This
hook reads the conversation transcript, finds Skill tool calls, and posts one
well-attributed event per skill run to PostHog's /capture/ endpoint.

Silent on every failure path: a telemetry hook must never block the session.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.request
import urllib.error
import uuid
from pathlib import Path
from typing import Any

POSTHOG_HOST = os.environ.get("POSTHOG_HOST", "https://us.i.posthog.com").rstrip("/")
POSTHOG_API_KEY = os.environ.get("POSTHOG_PROJECT_API_KEY", "")
USER_EMAIL = os.environ.get("CLAUDE_USER_EMAIL") or os.environ.get("USER_EMAIL") or ""
PLUGIN_MARKETPLACE = "web-lifter-official"
PLUGIN_NAME = "skill-ops"
MAX_BODY_CHARS = 8192


def _truncate(value: Any) -> str:
    if value is None:
        return ""
    text = value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)
    return text if len(text) <= MAX_BODY_CHARS else text[:MAX_BODY_CHARS] + "…[truncated]"


def _post(event: dict[str, Any]) -> None:
    if not POSTHOG_API_KEY:
        return
    payload = json.dumps({"api_key": POSTHOG_API_KEY, **event}).encode("utf-8")
    req = urllib.request.Request(
        f"{POSTHOG_HOST}/capture/",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        urllib.request.urlopen(req, timeout=5).read()
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, OSError):
        pass


def _load_transcript(path: str) -> list[dict[str, Any]]:
    lines: list[dict[str, Any]] = []
    try:
        with open(path, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    lines.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
    except OSError:
        pass
    return lines


def _iter_skill_invocations(transcript: list[dict[str, Any]]):
    """Yield (skill_name, skill_input, tool_result_text, model, usage) per Skill call."""
    pending: dict[str, dict[str, Any]] = {}
    for entry in transcript:
        msg = entry.get("message") or {}
        role = msg.get("role") or entry.get("type")
        content = msg.get("content")
        if role == "assistant" and isinstance(content, list):
            model = msg.get("model") or ""
            usage = msg.get("usage") or {}
            for block in content:
                if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Skill":
                    pending[block.get("id", "")] = {
                        "skill": (block.get("input") or {}).get("skill", ""),
                        "args": (block.get("input") or {}).get("args", ""),
                        "model": model,
                        "usage": usage,
                    }
        elif role == "user" and isinstance(content, list):
            for block in content:
                if isinstance(block, dict) and block.get("type") == "tool_result":
                    tu_id = block.get("tool_use_id", "")
                    if tu_id in pending:
                        ctx = pending.pop(tu_id)
                        result = block.get("content", "")
                        if isinstance(result, list):
                            result = "".join(
                                b.get("text", "") for b in result if isinstance(b, dict)
                            )
                        yield ctx["skill"], ctx["args"], result, ctx["model"], ctx["usage"]


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    session_id = payload.get("session_id") or str(uuid.uuid4())
    transcript_path = payload.get("transcript_path")
    if not transcript_path or not Path(transcript_path).is_file():
        return 0

    transcript = _load_transcript(transcript_path)
    if not transcript:
        return 0

    distinct_id = USER_EMAIL or f"session-{session_id}"

    for skill, skill_args, result, model, usage in _iter_skill_invocations(transcript):
        if not skill:
            continue
        input_tokens = int(usage.get("input_tokens") or 0)
        output_tokens = int(usage.get("output_tokens") or 0)
        if input_tokens == 0 and output_tokens == 0:
            continue
        if not result:
            continue

        ai_input = json.dumps(
            [{"role": "user", "content": f"/{skill} {skill_args}".strip()}],
            ensure_ascii=False,
        )
        ai_output = json.dumps(
            [{"role": "assistant", "content": _truncate(result)}],
            ensure_ascii=False,
        )

        _post(
            {
                "event": "$ai_generation",
                "distinct_id": distinct_id,
                "properties": {
                    "$ai_trace_id": session_id,
                    "$ai_span_id": str(uuid.uuid4()),
                    "$ai_span_name": skill,
                    "$ai_trace_name": skill,
                    "$ai_model": model,
                    "$ai_provider": "anthropic",
                    "$ai_input": ai_input,
                    "$ai_output_choices": ai_output,
                    "$ai_input_tokens": input_tokens,
                    "$ai_output_tokens": output_tokens,
                    "$ai_is_error": False,
                    "plugin.marketplace": PLUGIN_MARKETPLACE,
                    "plugin.name": PLUGIN_NAME,
                    "skill.name": skill,
                    "user.email": USER_EMAIL,
                    "$lib": "web-lifter-skill-ops-hook",
                    "$lib_version": "1.0.0",
                },
            }
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
