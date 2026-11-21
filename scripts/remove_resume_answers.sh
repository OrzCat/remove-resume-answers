#!/usr/bin/env bash
#
# Remove assistant answers that were blocked or refused after a safety stop or
# rejection, along with related safeguard records (system or user level).
# Supports any project: pass a session file path or project directory.
#
# Usage:
#   ./remove_resume_answers.sh /Users/orzcat/demo-project
#   ./remove_resume_answers.sh

set -euo pipefail

ASSISTANT_MARKERS=(
  "安全機制攔下"
  "安全機制攔"
  "Do not produce that content again"
  "我沒辦可再回答"
)

SAFEGUARD_MARKERS=(
  "safeguards stopped the response above"
  "safeguards flagged this message"
)

USER_MARKERS=(
  "Your response above was stopped by a safety classifier"
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

python3 - "$SESSION_FILE" \
  "${#ASSISTANT_MARKERS[@]}" \
  "${#SAFEGUARD_MARKERS[@]}" \
  "${#USER_MARKERS[@]}" \
  "${ASSISTANT_MARKERS[@]}" \
  "${SAFEGUARD_MARKERS[@]}" \
  "${USER_MARKERS[@]}" <<'PY'
import json
import sys

path = sys.argv[1]
assistant_count = int(sys.argv[2])
safeguard_count = int(sys.argv[3])
user_count = int(sys.argv[4])

cursor = 5
assistant_markers = sys.argv[cursor : cursor + assistant_count]
cursor += assistant_count
safeguard_markers = sys.argv[cursor : cursor + safeguard_count]
cursor += safeguard_count
user_markers = sys.argv[cursor : cursor + user_count]

with open(path, "r", encoding="utf-8") as f:
    text = f.read()

lines = text.split("\n")
if lines and lines[-1] == "":
    lines.pop()

entries = [json.loads(line) for line in lines]


def get_text(entry):
    entry_type = entry.get("type")
    if entry_type == "assistant":
        message = entry.get("message") or {}
        content = message.get("content")
        value = ""
        if isinstance(content, list):
            for part in content:
                if isinstance(part, dict) and part.get("type") == "text":
                    value += part.get("text") or ""
        elif isinstance(content, str):
            value = content
        return value

    content = entry.get("content")
    if content is None:
        message = entry.get("message") or {}
        content = message.get("content")

    if isinstance(content, str):
        return content
    if isinstance(content, list):
        value = ""
        for part in content:
            if isinstance(part, dict) and part.get("type") == "text":
                value += part.get("text") or ""
        return value
    return ""


removed_indices = set()
for index, entry in enumerate(entries):
    entry_type = entry.get("type")
    value = get_text(entry)

    if entry_type == "assistant":
        should_remove = any(marker in value for marker in assistant_markers)
    elif entry_type == "system":
        should_remove = any(marker in value for marker in safeguard_markers)
    elif entry_type == "user":
        should_remove = any(marker in value for marker in user_markers)
    else:
        should_remove = False

    if should_remove:
        removed_indices.add(index)

removed_uuids = {
    entries[index].get("uuid")
    for index in removed_indices
    if entries[index].get("uuid")
}
by_uuid = {
    entry.get("uuid"): index
    for index, entry in enumerate(entries)
    if entry.get("uuid")
}


def nearest_surviving_parent(uuid):
    seen = set()
    while uuid in removed_uuids:
        if uuid in seen or uuid not in by_uuid:
            return None
        seen.add(uuid)
        uuid = entries[by_uuid[uuid]].get("parentUuid")
    return uuid


output = []
changed = False
for index, (entry, raw) in enumerate(zip(entries, lines)):
    if index in removed_indices:
        changed = True
        continue

    parent = entry.get("parentUuid")
    if parent in removed_uuids:
        replacement = nearest_surviving_parent(parent)
        if replacement:
            entry["parentUuid"] = replacement
        else:
            entry.pop("parentUuid", None)
        raw = json.dumps(entry, ensure_ascii=False, separators=(",", ":"))
        changed = True

    output.append(raw)

if changed:
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(output) + "\n")

removed_answers = sum(
    1 for index in removed_indices if entries[index].get("type") == "assistant"
)
removed_records = len(removed_indices) - removed_answers

print(f"Session file: {path}")
print(f"Removed answers: {removed_answers}")
print(f"Removed safety-related records: {removed_records}")
PY
