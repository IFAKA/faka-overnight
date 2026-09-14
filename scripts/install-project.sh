#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
[ -n "$PROJECT" ] || { echo "usage: $0 /path/to/project" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"
DEST="$PROJECT/.faka"
mkdir -p "$DEST/task"
cp "$ROOT/overnight.sh" "$DEST/"
cp "$ROOT/verify.sh" "$DEST/"
cp "$ROOT/watchdog.py" "$DEST/"
cp "$ROOT/task/"*.md "$DEST/task/"
chmod +x "$DEST/overnight.sh" "$DEST/verify.sh" "$DEST/watchdog.py"
echo "Installed into $DEST"
echo "Next: edit $DEST/task/SPEC.md and $DEST/verify.sh"
