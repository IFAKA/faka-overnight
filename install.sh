#!/usr/bin/env bash
set -euo pipefail

OWNER="${FAKA_GITHUB_OWNER:-IFAKA}"
REPO="${FAKA_GITHUB_REPO:-faka-overnight}"
REF="${FAKA_REF:-main}"
PROJECT="${FAKA_PROJECT:-$PWD}"

say() { printf '\033[1;36m[FAKA]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[FAKA]\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || die "curl is required"
command -v git >/dev/null || die "git is required"
command -v node >/dev/null || die "Node.js is required (>= 22.22.1)"
command -v npm >/dev/null || die "npm is required"

node -e '
const [a,b,c]=process.versions.node.split(".").map(Number);
if (a<22 || (a===22 && (b<22 || (b===22 && c<1)))) process.exit(1)
' || die "Need Node.js >= 22.22.1; found $(node -v)"

PROJECT="$(cd "$PROJECT" && pwd)"
say "Project: $PROJECT"

if [ ! -d "$PROJECT/.git" ]; then
  say "No Git repository found; initializing a local Git repository."
  git -C "$PROJECT" init >/dev/null
fi

say "Installing/upgrading Pi..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.85.1

say "Installing Pi Ralph..."
pi install npm:@lnilluv/pi-ralph-loop

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

ARCHIVE="https://github.com/${OWNER}/${REPO}/archive/${REF}.tar.gz"
say "Downloading ${OWNER}/${REPO}@${REF}..."
curl -fsSL "$ARCHIVE" -o "$TMP/repo.tgz" || die "Could not download $ARCHIVE"
mkdir -p "$TMP/unpack"
tar -xzf "$TMP/repo.tgz" -C "$TMP/unpack"

ROOT="$(find "$TMP/unpack" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[ -n "$ROOT" ] || die "Downloaded archive was empty"

DEST="$PROJECT/.faka"
mkdir -p "$DEST/task" "$DEST/logs"

for f in overnight.sh verify.sh watchdog.py run_with_timeout.py; do
  cp "$ROOT/$f" "$DEST/$f"
done
cp "$ROOT/task/RALPH.md" "$DEST/task/RALPH.md"

# Preserve user-edited project state on reinstall.
for f in SPEC.md IMPLEMENTATION_PLAN.md OPEN_QUESTIONS.md; do
  if [ ! -e "$DEST/task/$f" ]; then
    cp "$ROOT/task/$f" "$DEST/task/$f"
  fi
done

chmod +x "$DEST/overnight.sh" "$DEST/verify.sh" "$DEST/watchdog.py" "$DEST/run_with_timeout.py"

# Ignore runtime state without clobbering the project's existing .gitignore.
touch "$PROJECT/.gitignore"
for rule in ".faka/logs/" ".faka/watchdog.jsonl" ".faka/backend.stdout.log" ".faka/backend.stderr.log" ".faka/task/.ralph-runner/"; do
  grep -qxF "$rule" "$PROJECT/.gitignore" || printf '%s\n' "$rule" >> "$PROJECT/.gitignore"
done

say "Installed."
printf '\n'
printf 'Next:\n'
printf '  1. Edit .faka/task/SPEC.md\n'
printf '  2. Verify .faka/verify.sh matches your project\n'
printf '  3. Run: .faka/overnight.sh\n'
printf '\n'
printf 'Ralph: '
if pi list 2>/dev/null | grep -q '@lnilluv/pi-ralph-loop'; then
  printf 'OK\n'
else
  printf 'NOT DETECTED — run: pi install npm:@lnilluv/pi-ralph-loop\n'
fi
