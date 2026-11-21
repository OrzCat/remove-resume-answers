#!/usr/bin/env bash
#
# install.sh
# One-click installer for remove-resume-answers OpenCode skill.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash
#

set -euo pipefail

SKILL_NAME="remove-resume-answers"
SKILL_URL="https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/skill.yaml"
SKILL_DIR="${HOME}/.config/opencode/skills"
SKILL_FILE="${SKILL_DIR}/${SKILL_NAME}.yaml"

echo "==> Installing OpenCode skill: ${SKILL_NAME}"

# 1. Ensure skills directory exists
mkdir -p "${SKILL_DIR}"

# 2. Download skill.yaml from GitHub
echo "==> Downloading skill.yaml..."
curl -fsSL "${SKILL_URL}" -o "${SKILL_FILE}"

# 3. Register plugin in opencode.json (optional, for tracking)
if command -v opencode >/dev/null 2>&1; then
  echo "==> Registering plugin with OpenCode..."
  opencode plugin add "OrzCat/${SKILL_NAME}" 2>/dev/null || true
  opencode reload 2>/dev/null || true
fi

echo "==> Done! The skill is installed at: ${SKILL_FILE}"
echo "==> Usage in OpenCode: /remove-resume-answers"
