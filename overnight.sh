#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(cd "$HERE/.." && pwd)"
TASK="$HERE/task/RALPH.md"
HOURS="${FAKA_HOURS:-8}"
cd "$PROJECT"
[ -d .git ] || { echo 'Requires a git repository' >&2; exit 2; }
command -v pi >/dev/null || { echo 'Pi missing; install first' >&2; exit 2; }
mkdir -p "$HERE/logs" "$HERE/task"
if [ "$#" -gt 0 ]; then printf '# Current FAKA Goal\n\n%s\n' "$*" > "$HERE/task/GOAL.md"; fi
if [ ! -s "$HERE/task/GOAL.md" ]; then
cat > "$HERE/task/GOAL.md" <<'EOF2'
# Current FAKA Goal

Finish the current project according to the existing repository requirements, documentation, tests, and current implementation state.
EOF2
fi
set +e
"$HERE/verify.sh" >"$HERE/logs/preflight-verify.log" 2>&1
set -e
"$HERE/watchdog.py" >>"$HERE/logs/watchdog-console.log" 2>&1 &
WPID=$!
trap 'kill "$WPID" 2>/dev/null || true' EXIT INT TERM
python3 "$HERE/run_with_timeout.py" "$HOURS" "$TASK"
