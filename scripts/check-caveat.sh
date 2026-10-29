#!/usr/bin/env bash
# beta.36 RC3 QA (03:48 AEDT Oct 30): the Formula caveat carries the approved Codex sentence
# (Nina 02:29 AEDT Oct 30) byte-exact on one line, the same sentence as vibead/cli BETA.md
# and README.md, and the old "choose Trust" line is gone from every tracked file except
# this script. Offline, no secrets.
set -euo pipefail
cd "$(dirname "$0")/.."
approved="Codex asks you to trust VibeAd's hooks; ads show after you choose Trust. It asks again each time you turn VibeAd off and back on."
[ "$(grep -cxF "      $approved" Formula/vibead.rb)" = 1 ] || { echo "caveat: Formula/vibead.rb must carry the approved Codex sentence once, byte-exact"; exit 1; }
[ "$(grep -cF "$approved" README.md)" = 1 ] || { echo "caveat: README.md must carry the approved Codex sentence once"; exit 1; }
old=$(git ls-files -z | grep -zv '^scripts/check-caveat.sh$' | xargs -0 grep -nHIF -e "trust VibeAd's hooks; choose Trust" -e "hooks; choose Trust" || true)
[ -z "$old" ] || { echo "caveat: the old trust line is back:"; echo "$old"; exit 1; }
echo "ok: the Formula caveat and README carry the approved Codex sentence; the old line is in no tracked file"
