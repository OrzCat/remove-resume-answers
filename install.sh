#!/usr/bin/env bash
#
# install.sh
# One-click installer for remove-resume-answers OpenCode plugin.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash
#

set -euo pipefail

PLUGIN="OrzCat/remove-resume-answers"

echo "==> Installing OpenCode plugin: ${PLUGIN}"

if ! command -v opencode >/dev/null 2>&1; then
  echo "❌ opencode CLI not found. Please install OpenCode first."
  exit 1
fi

opencode plugin add "${PLUGIN}"
opencode reload

echo "==> Done! Usage in OpenCode: /remove-resume-answers"
