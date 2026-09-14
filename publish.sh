#!/usr/bin/env bash
set -euo pipefail

OWNER="${1:-IFAKA}"
REPO="${2:-faka-overnight}"

command -v gh >/dev/null || {
  echo "GitHub CLI (gh) is required to publish automatically." >&2
  exit 1
}

git init
git add .
git commit -m "Initial FAKA Overnight release" || true
git branch -M main

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "Repository already exists: $OWNER/$REPO" >&2
  exit 2
fi

gh repo create "$OWNER/$REPO" \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description "Autonomous overnight coding supervisor for Pi + Ralph + local LLMs"

echo
echo "Published: https://github.com/$OWNER/$REPO"
echo "Installer:"
echo "curl -fsSL https://raw.githubusercontent.com/$OWNER/$REPO/main/install.sh | bash"
