#!/usr/bin/env bash
#
# remove_resume_answers.sh
# Remove assistant answers that were blocked or refused after a safety stop/reject,
# along with related safeguard records (system / user level).
# Supports any project: pass a session file path or project dir (default: current dir).
#
# Usage:
#   ./remove_resume_answers.sh /Users/orzcat/demo-project
#   ./remove_resume_answers.sh

set -euo pipefail

MARKERS=(
  "安全機制攔下"
  "安全機制攔"
  "Do not produce that content again"
  "我沒辦可再回答"
)

SAFEGUARD_MARKERS=(
  "safeguards stopped the response above"
  "safeguards flagged this message"
)

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  TARGET="$PWD"
fi

SESSION_FILE=""
if [ -f "$TARGET" ]; then
  SESSION_FILE="$TARGET"
else
  ENCODED="${TARGET//\//-}"
  SESSION_DIR="${HOME}/.claude/projects/${ENCODED}"
  if [ -d "$SESSION_DIR" ]; then
    SESSION_FILE="$(ls -t "${SESSION_DIR}"/*.jsonl 2>/dev/null | head -n 1 || true)"
  fi
fi

if [ -z "${SESSION_FILE:-}" ] || [ ! -f "$SESSION_FILE" ]; then
  echo "remove_resume_answers: session file not found (project: ${TARGET})" >&2
  exit 1
fi

python3 - "$SESSION_FILE" "${MARKERS[@]}" "${SAFEGUARD_MARKERS[@]}" <<'PY'
import json
import sys

path = sys.argv[1]
markers = sys.argv[2:]
safeguard_markers = sys.argv[3:]

with open(path, "r", encoding="utf-8") as f:
    text = f.read()
lines = text.split("\n")
if lines and lines[-1] == "":
    lines.pop()

entries = [json.loads(l) for l in lines]
by_uuid = {}
for o in entries:
    u = o.get("uuid")
    if u:
        by_uuid[u] = o


def get_text(o):
    t = o.get("type")
    if t == "assistant":
        m = o.get("message") or {}
        content = m.get("content")
        txt = ""
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get("type") == "text":
                    txt += c.get("text") or ""
        elif isinstance(content, str):
            txt = content
        return txt
    content = o.get("content")
    if content is None:
        m = o.get("message") or {}
        content = m.get("content")
    txt = ""
    if isinstance(content, str):
        txt = content
    elif isinstance(content, list):
        for c in content:
            if isinstance(c, dict) and c.get("type") == "text":
                txt += c.get("text") or ""
    return txt


removed_uuids = set()
children_rep = {}
for o in entries:
    t = o.get("type")
    rem = False
    if t == "assistant":
        rem = any(mk in get_text(o) for mk in markers)
    elif t == "system":
        rem = any(mk in get_text(o) for mk in safeguard_markers)
    elif t == "user":
        rem = any(
            mk in get_text(o)
            for mk in [
                "Your response above was stopped by a safety classifier",
                "safeguards stopped the response above",
                "safeguards flagged this message",
            ]
        )
    if rem:
        u = o.get("uuid")
        removed_uuids.add(u)
        parent = o.get("parentUuid")
        if parent and parent in by_uuid:
            children_rep[u] = by_uuid[parent].get("uuid")

out = []
for o, raw in zip(entries, lines):
    u = o.get("uuid")
    if u and u in removed_uuids:
        continue
    new_raw = raw
    if o.get("type") == "system" and o.get("parentUuid") in children_rep:
        old = o.get("parentUuid")
        new = children_rep[old]
        new_raw = raw.replace('"parentUuid":"%s"' % old, '"parentUuid":"%s"' % new)
    out.append(new_raw)

with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(out) + "\n")
PY
