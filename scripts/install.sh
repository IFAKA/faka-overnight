#!/usr/bin/env bash
set -euo pipefail
command -v node >/dev/null || { echo 'Node.js required' >&2; exit 1; }
node -e 'const [a,b,c]=process.versions.node.split(".").map(Number); if(a<22 || (a===22 && (b<22 || (b===22 && c<1)))) process.exit(1)' || { echo 'Need Node.js >= 22.22.1' >&2; exit 1; }
npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.85.1
pi install npm:@lnilluv/pi-ralph-loop
echo 'Verify: pi list | grep @lnilluv/pi-ralph-loop'
