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
! grep -nHE ";[[:space:]]*Codex asks you to trust" Formula/vibead.rb README.md || { echo "caveat: the approved sentence is joined to the one before by a semicolon"; exit 1; }
old=$(git ls-files -z | grep -zv '^scripts/check-caveat.sh$' | xargs -0 grep -nHIF -e "trust VibeAd's hooks; choose Trust" -e "hooks; choose Trust" || true)
[ -z "$old" ] || { echo "caveat: the old trust line is back:"; echo "$old"; exit 1; }
# RC3b (CLI Tester #4c): also by meaning, any case, quoting, markdown or wrapping: an instruction
# to pick a bare "Trust" ("...hooks. Choose Trust."), not the approved statement "after you choose
# Trust" or 'Choose "Trust all and continue"'. Same pattern as vibead/vibead oldTrustLines.
meaning() { perl -0777 -ne 'my $t = lc $_; $t =~ s/\xe2\x80[\x98\x99\x9c\x9d]|[*_`"\x27]//g; $t =~ s/\s+/ /g;
  while ($t =~ /(?:^|[.;:!?(] ?|\bthen |\band )(?:choose|select|pick|press|click|hit) +(?:the +)?trust(?! +all)(?![\w-])/g) { print "$ARGV: ", substr($t, $-[0] > 50 ? $-[0] - 50 : 0, 80), "\n" }' "$@"; }
sample=$(mktemp); trap 'rm -f "$sample"' EXIT
printf '%s\n' "Codex will ask you to trust VibeAd's hooks. Choose Trust." > "$sample"; [ -n "$(meaning "$sample")" ] || { echo "caveat: the meaning check misses a reworded old line"; exit 1; }
printf '%s\n' "$approved" 'Choose "Trust all and continue" to see ads.' > "$sample"; [ -z "$(meaning "$sample")" ] || { echo "caveat: the meaning check flags the approved copy"; exit 1; }
old=$(git ls-files | grep -v '^scripts/check-caveat.sh$' | while IFS= read -r f; do grep -qI . "$f" 2>/dev/null && meaning "$f"; done || true)
[ -z "$old" ] || { echo "caveat: the old trust line is back (reworded):"; echo "$old"; exit 1; }
echo "ok: the Formula caveat and README carry the approved Codex sentence; the old line, in any wording, is in no tracked file"
