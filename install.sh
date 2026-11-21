#!/usr/bin/env bash
#
# One-line installer for the remove-resume-answers OpenCode plugin.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash

set -euo pipefail

PLUGIN="OrzCat/remove-resume-answers"

echo "==> Installing OpenCode plugin: ${PLUGIN}"

if ! command -v opencode >/dev/null 2>&1; then
  echo "opencode CLI not found. Please install OpenCode first."
  exit 1
fi

PLUGIN_LIST="$(opencode plugin list)"
if grep -Fq "${PLUGIN}" <<<"${PLUGIN_LIST}"; then
  echo "==> Plugin is already installed"
else
  opencode plugin add "${PLUGIN}"
fi

opencode reload

echo "==> Done. Run /remove-resume-answers in OpenCode"
