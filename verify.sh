#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo '== FAKA acceptance verification =='
if [ -n "${FAKA_VERIFY_CMD:-}" ]; then exec bash -lc "$FAKA_VERIFY_CMD"; fi
if [ -f package.json ]; then
  has_script(){ node -e 'const p=require("./package.json"); process.exit(p.scripts&&Object.hasOwn(p.scripts,process.argv[1])?0:1)' "$1"; }
  PM=npm; [ -f pnpm-lock.yaml ] && PM=pnpm; [ -f yarn.lock ] && PM=yarn; { [ -f bun.lockb ] || [ -f bun.lock ]; } && PM=bun || true
  ran=0
  for s in test typecheck lint build; do
    if has_script "$s"; then echo "+ $PM run $s"; "$PM" run "$s"; ran=1; fi
  done
  [ "$ran" -eq 1 ] || { echo 'No standard verification scripts; edit .faka/verify.sh or set FAKA_VERIFY_CMD' >&2; exit 2; }
  exit 0
fi
if [ -f pyproject.toml ] && command -v pytest >/dev/null; then exec pytest; fi
echo 'No verifier detected; edit .faka/verify.sh or set FAKA_VERIFY_CMD' >&2
exit 2
