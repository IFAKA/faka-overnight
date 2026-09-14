#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PROJECT="$(cd "$HERE/.." && pwd)"; TASK="$HERE/task/RALPH.md"; HOURS="${FAKA_HOURS:-8}"
cd "$PROJECT"
[ -d .git ] || { echo 'Requires a git repository' >&2; exit 2; }
command -v pi >/dev/null || { echo 'Pi missing; install first' >&2; exit 2; }
grep -q 'REPLACE THIS WITH YOUR PROJECT SPEC' "$HERE/task/SPEC.md" && { echo 'Edit .faka/task/SPEC.md first' >&2; exit 2; }
mkdir -p "$HERE/logs"
set +e; "$HERE/verify.sh" >"$HERE/logs/preflight-verify.log" 2>&1; PRE=$?; set -e
[ "$PRE" -ne 2 ] || { echo 'No usable verifier. See .faka/logs/preflight-verify.log' >&2; exit 2; }
"$HERE/watchdog.py" >>"$HERE/logs/watchdog-console.log" 2>&1 & WPID=$!
trap 'kill "$WPID" 2>/dev/null || true' EXIT INT TERM
python3 "$HERE/run_with_timeout.py" "$HOURS" "$TASK"
